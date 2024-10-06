require "json"
require "./tile_map"
require "./visibility"
require "./monster"

module MiniMonsters
  class Level
    alias TileData = Tuple(Int32, Int32, Int32)
    alias Tiles = Array(TileData) # tile_type, row, col

    getter player : Player
    getter rows : Int32
    getter cols : Int32
    getter tiles : Array(Array(Int32))
    getter monsters : Array(Monster)

    @visibilities : Array(Visibility)
    @tile_map : TileMap
    @collidable_tile_types : Array(Int32)
    @collidable_tiles : Array(TileData)

    VisibilitySize = 16
    VisibilitySizeFactor = TileSize // VisibilitySize
    EmptyString = ""
    TileSheetFile = "./assets/tiles.png"
    TileSheetDataFile = "./assets/tiles.json"

    def initialize(@player : Player, @rows = 1, @cols = 1)
      @tile_map = TileMap.new
      @tiles = [] of Array(Int32)
      @monsters = [] of Monster
      @visibilities = [] of Visibility
      @collidable_tile_types = [] of Int32
      @collidable_tiles = [] of TileData
    end

    def tile_size
      TileSize
    end

    def width
      tile_size * cols
    end

    def height
      tile_size * rows
    end

    def v_rows
      rows * VisibilitySizeFactor
    end

    def v_cols
      cols * VisibilitySizeFactor
    end

    def init
      init_tiles
      init_visibilities
      init_monsters
      update_visibility
    end

    def tile_map_file
      EmptyString
    end

    def tile_sheet_file
      TileSheetFile
    end

    def tile_sheet_data_file
      TileSheetDataFile
    end

    def init_tiles
      return if tile_map_file.empty? || tile_sheet_file.empty?

      json = JSON.parse(File.open(tile_map_file))
      @rows = json["height"].as_i
      @cols = json["width"].as_i

      # tile data is 1-indexed not 0-indexed so subtract 1
      tiles = json["data"].as_a.map { |j| j.as_i - 1 }
      @tile_map = TileMap.new(tile_sheet_file, tile_size, tiles, rows, cols)
      @tiles = tiles.in_slices_of(cols)

      # player_start_row and player_start_row are 0-indexed
      player.jump_to_tile(json["player_start_row"].as_i, json["player_start_col"].as_i, tile_size)

      return if tile_sheet_data_file.empty?

      # sets tiles that are collidable from json
      json = JSON.parse(File.open(tile_sheet_data_file))

      if raw_ranges = json.dig("collidables", "ranges")
        ranges = raw_ranges.as_a.map(&.as_a.map(&.as_i))

        ranges.each do |range|
          min, max = range
          @collidable_tile_types += (min..max).to_a
        end
      end
    end

    def init_visibilities
      size = rows * VisibilitySizeFactor * v_cols
      @visibilities = Array(Visibility).new(size: size, value: Visibility::None)
    end

    def init_monsters
    end

    def collidable_tiles : Tiles
      collidable_tiles = [] of TileData

      px = player.collision_box_x - player.collision_box.size / 2
      py = player.collision_box_y - player.collision_box.size / 2
      size = player.collision_box.size * 2

      min_row = (py // tile_size - 1).clamp(0, rows - 1).to_i
      min_col = (px // tile_size - 1).clamp(0, cols - 1).to_i
      max_row = (((py + size) // tile_size) + 1).clamp(0, rows - 1).to_i
      max_col = (((px + size) // tile_size) + 1).clamp(0, cols - 1).to_i

      # check these tiles against player visibility circle
      @tiles[min_row..max_row].each_with_index do |cols, row_index|
        row = min_row + row_index

        cols[min_col..max_col].each_with_index do |tile, col_index|
          col = min_col + col_index

          next unless @collidable_tile_types.includes?(tile)

          collidable_tiles << {tile, row, col}
        end
      end

      collidable_tiles
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks)
      @collidable_tiles = collidable_tiles if player.moved?

      player.update(frame_time, keys, joysticks, width, height, @collidable_tiles, tile_size)

      update_visibility if player.moved?
    end

    def reset_visibility(tile_row, tile_col)
      visibility_indexes = visibility_indexes(tile_row, tile_col)

      visibility_indexes.each do |i|
        reset_visibility(i)
      end
    end

    def reset_visibility(index)
      if visibility = @visibilities[index]
        return unless visibility.clear?
        @visibilities[index] = Visibility::Fog
      end
    end

    def update_visibility
      # get all tiles within rectangle of player visibility radius
      pvx = player.torch_cx - player.visibility_radius
      pvy = player.torch_cy - player.visibility_radius
      size = player.visibility_radius * 2

      min_row = (pvy // tile_size - 1).clamp(0, rows - 1)
      min_col = (pvx // tile_size - 1).clamp(0, cols - 1)
      max_row = (((pvy + size) // tile_size) + 1).clamp(0, rows - 1)
      max_col = (((pvx + size) // tile_size) + 1).clamp(0, cols - 1)

      # check these tiles against player visibility circle
      (min_row.to_i..max_row.to_i).each do |row|
        (min_col.to_i..max_col.to_i).each do |col|
          reset_visibility(row, col)

          next unless collision_with_circle?(col * tile_size, row * tile_size, tile_size)

          update_tile_visibility(row, col)
        end
      end
    end

    def visibility_indexes(tile_row, tile_col) : Array(Int32)
      factor = VisibilitySizeFactor
      v_tiles = factor * factor
      indexes = [] of Int32

      factor.times do |v_row|
        factor.times do |v_col|
          indexes << tile_row * cols * v_tiles + v_row * (factor * cols) + tile_col * factor + v_col
        end
      end

      indexes
    end

    def update_tile_visibility(tile_row, tile_col)
      size = VisibilitySize
      visibility_indexes = visibility_indexes(tile_row, tile_col)

      visibility_indexes.each do |i|
        row = i // v_cols
        col = i % v_cols

        if collision_with_circle?(col * size, row * size, size)
          @visibilities[i] = Visibility::Clear
        end
      end
    end

    def collision_with_circle?(x, y, size)
      cx, cy, radius = {player.torch_cx, player.torch_cy, player.visibility_radius}

      # temporary variables to set edges for testing
      test_x = cx
      test_y = cy

      # which edge is closest?
      if cx < x
        # test left edge
        test_x = x
      elsif cx > x + size
        # right edge
        test_x = x + size
      end

      if cy < y
        # top edge
        test_y = y
      elsif cy > y + size
        # bottom edge
        test_y = y + size
      end

      # get distance from closest edges
      dist_x = cx - test_x
      dist_y = cy - test_y

      # if distance is less than radius, it collides
      Math.sqrt(dist_x ** 2 + dist_y ** 2) <= radius
    end

    def draw(window : SF::RenderWindow)
      window.draw(@tile_map)

      monsters.each(&.draw(window))

      player.draw(window)

      draw_visibility(window)

      player.draw_torch_visibility(window)

      return unless Debug

      draw_collision_tiles(window)
      player.draw_monster_attack_radius(window)
    end

    def draw_collision_tiles(window)
      rectangle = SF::RectangleShape.new({tile_size, tile_size})
      rectangle.fill_color = SF::Color::Transparent
      rectangle.outline_color = SF::Color::Cyan
      rectangle.outline_thickness = 2

      @collidable_tiles.each do |_tile, row, col|
        rectangle.position = {col * tile_size, row * tile_size}

        window.draw(rectangle)
      end
    end

    def draw_visibility(window)
      min_row = (Screen.y // VisibilitySize).clamp(0, v_rows - 1)
      min_col = (Screen.x // VisibilitySize).clamp(0, v_cols - 1)
      max_row = (((Screen.y + Screen.height) // VisibilitySize) + 1).clamp(0, v_rows - 1)
      max_col = (((Screen.x + Screen.width) // VisibilitySize) + 1).clamp(0, v_cols - 1)

      (min_row.to_i..max_row.to_i).each do |row|
        (min_col.to_i..max_col.to_i).each do |col|
          if visibility = @visibilities[row * v_cols + col]
            vx = col * VisibilitySize
            vy = row * VisibilitySize

            visibility.draw(window, vx, vy, VisibilitySize, player.torch_left_percent)
          end
        end
      end
    end
  end
end
