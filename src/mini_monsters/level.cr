require "json"
require "./tile_map"
require "./visibility"
require "./monster"
require "./oil_pool"

module MiniMonsters
  class Level
    getter player : Player
    getter rows : Int32
    getter cols : Int32
    getter tiles : Array(Array(Int32))
    getter monsters : Array(Monster)
    getter oil_pools : Array(OilPool)
    getter sound : SF::Sound

    @visibilities : Array(Array(Visibility))
    @tile_map : TileMap
    @collidable_tile_types : Array(Int32)
    @player_collidable_tiles : Array(TileData)
    @sound_buffer_oil_dip : SF::SoundBuffer
    @oil_fill_sprite : SF::Sprite

    VisibilitySize = 16
    VisibilitySizeFactor = TileSize // VisibilitySize
    EmptyString = ""
    TileSheetFile = "./assets/tiles/tiles.png"
    TileSheetDataFile = "./assets/tiles/tiles.json"
    OilFillSheetFile = "./assets/tiles/oil_fill.png"
    SoundOilDip = "./assets/sounds/oil_dip.ogg"

    def initialize(@player : Player, @rows = 1, @cols = 1)
      @tile_map = TileMap.new
      @tiles = [] of Array(Int32)
      @monsters = [] of Monster
      @visibilities = [] of Array(Visibility)
      @collidable_tile_types = [] of Int32
      @player_collidable_tiles = [] of TileData
      @oil_pools = [] of OilPool
      @sound = SF::Sound.new
      @sound_buffer_oil_dip = SF::SoundBuffer.new
      @oil_fill_sprite = SF::Sprite.new
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
      init_sounds
      init_sprites

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
      player.jump_to_tile(json["player_start_row"].as_i, json["player_start_col"].as_i)

      return if tile_sheet_data_file.empty?

      json = JSON.parse(File.open(tile_sheet_data_file))

      # sets tiles that are collidable from tile_sheet_data_file json
      if raw_ranges = json.dig("collidables", "ranges")
        # this file is 0-indexed
        ranges = raw_ranges.as_a.map(&.as_a.map(&.as_i))

        ranges.each do |range|
          min, max = range

          @collidable_tile_types += (min..max).to_a
        end
      end

      # this file is 0-indexed from tile_sheet_data_file json
      oil_pool_tile = json["oil_pool_tile"].as_i

      init_oil_pools(oil_pool_tile)
    end

    def init_oil_pools(oil_pool_tile)
      @tiles.each_with_index do |cols, row|
        cols.each_with_index do |tile, col|
          @oil_pools << OilPool.new(row: row, col: col) if tile == oil_pool_tile
        end
      end
    end

    def init_visibilities
      visibilities_flat = Array(Visibility).new(size: v_rows * v_cols, value: Visibility::None)
      @visibilities = visibilities_flat.in_slices_of(v_cols)
    end

    def init_monsters
    end

    def init_sounds
      @sound_buffer_oil_dip = SF::SoundBuffer.from_file(SoundOilDip)
    end

    def init_sprites
      texture = SF::Texture.from_file(OilFillSheetFile, SF::IntRect.new(0, 0, tile_size, tile_size))

      @oil_fill_sprite = SF::Sprite.new(texture)
    end

    def play_sound(buffer : SF::SoundBuffer)
      @sound.buffer = buffer
      @sound.play
    end

    def close_collidable_tiles(movable : Movable)
      tiles = [] of TileData

      size = movable.collision_radius * 2
      lx = movable.collision_cx - size
      ly = movable.collision_cy - size
      rx = movable.collision_cx + size
      ry = movable.collision_cy + size

      min_row = (ly // tile_size - 1).clamp(0, rows - 1).to_i
      min_col = (lx // tile_size - 1).clamp(0, cols - 1).to_i
      max_row = (ry // tile_size + 1).clamp(0, rows - 1).to_i
      max_col = (rx // tile_size + 1).clamp(0, cols - 1).to_i

      @tiles[min_row..max_row].each_with_index do |cols, row_index|
        row = min_row + row_index

        cols[min_col..max_col].each_with_index do |tile, col_index|
          col = min_col + col_index

          next unless @collidable_tile_types.includes?(tile)

          tiles << {tile, row, col}
        end
      end

      tiles
    end

    def close_collidable_movables(movable : Movable)
      @monsters.select do |monster|
        next false if movable == monster

        size = monster.size * 2

        next false if movable.cx < monster.cx - size
        next false if movable.cx > monster.cx + size
        next false if movable.cy < monster.cy - size
        next false if movable.cy > monster.cy + size

        true
      end
    end

    def close_oil_pools(movable : Movable)
      @oil_pools.select do |oil_pool|
        next false if oil_pool.empty?

        size = oil_pool.radius * 2

        next false if movable.cx < oil_pool.cx - size
        next false if movable.cx > oil_pool.cx + size
        next false if movable.cy < oil_pool.cy - size
        next false if movable.cy > oil_pool.cy + size

        true
      end
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks)
      oil_pools = [] of OilPool

      if player.moved?
        @player_collidable_tiles = close_collidable_tiles(player)
        oil_pools = close_oil_pools(player)

        @monsters
          .select(&.follow_range?(player))
          .each(&.follow_player!)
      end

      player.update(frame_time, keys, joysticks, width, height, @player_collidable_tiles)

      oil_pools.each do |oil_pool|
        if player.collides?(Circle.new(oil_pool.radius), oil_pool.cx, oil_pool.cy)
          play_sound(@sound_buffer_oil_dip)
          oil_pool.dip!
          player.torch_refill!
        end
      end

      monsters.select(&.following?).each do |monster|
        tiles = close_collidable_tiles(monster)
        movables = close_collidable_movables(monster)

        monster.update_following(frame_time, player.cx, player.cy, player.monster_radius, tiles, movables)
      end

      update_visibility if player.moved?
    end

    def update_visibility
      # get all tiles within rectangle of player visibility radius
      pvx = player.torch_cx - player.visibility_radius
      pvy = player.torch_cy - player.visibility_radius
      size = player.visibility_radius * 2

      min_row = (pvy // tile_size - 1).clamp(0, rows - 1).to_i
      min_col = (pvx // tile_size - 1).clamp(0, cols - 1).to_i
      max_row = (((pvy + size) // tile_size) + 1).clamp(0, rows - 1).to_i
      max_col = (((pvx + size) // tile_size) + 1).clamp(0, cols - 1).to_i

      # check these tiles against player visibility circle
      (min_row..max_row).each do |row|
        (min_col..max_col).each do |col|
          reset_visibility(row, col)

          next unless collision_with_circle?(col * tile_size, row * tile_size, tile_size)

          update_tile_visibility(row, col)
        end
      end
    end

    def reset_visibility(tile_row, tile_col)
      visibilities_from_tile(tile_row, tile_col).each do |visibility, row, col|
        next unless visibility.clear?
        @visibilities[row][col] = Visibility::Fog
      end
    end

    def visibilities_from_tile(tile_row, tile_col) : Array(VisibilityData)
      visibilities = [] of VisibilityData

      min_row = tile_row * VisibilitySizeFactor
      min_col = tile_col * VisibilitySizeFactor
      max_row = min_row + VisibilitySizeFactor
      max_col = min_col + VisibilitySizeFactor

      @visibilities[min_row...max_row].each_with_index do |cols, row_index|
        row = min_row + row_index

        cols[min_col...max_col].each_with_index do |visibility, col_index|
          col = min_col + col_index

          visibilities << {visibility, row, col}
        end
      end

      visibilities
    end

    def update_tile_visibility(tile_row, tile_col)
      size = VisibilitySize

      visibilities_from_tile(tile_row, tile_col).each do |visibility, row, col|
        if !visibility.clear? && collision_with_circle?(col * size, row * size, size)
          @visibilities[row][col] = Visibility::Clear
        end
      end
    end

    def collision_with_circle?(x, y, size)
      Box.collides?(size, x, y, player.visibility_radius, player.torch_cx, player.torch_cy)
    end

    def draw(window : SF::RenderWindow)
      window.draw(@tile_map)

      monsters.each(&.draw(window))

      oil_pools.each(&.draw(window, @oil_fill_sprite))

      player.draw(window)

      draw_visibility(window)

      player.draw_torch_visibility(window)

      return unless Debug

      draw_collision_tiles(window)
      player.draw_monster_follow_radius(window)
    end

    def draw_collision_tiles(window)
      rectangle = SF::RectangleShape.new({tile_size, tile_size})
      rectangle.fill_color = SF::Color::Transparent
      rectangle.outline_color = SF::Color::Cyan
      rectangle.outline_thickness = 2

      @player_collidable_tiles.each do |_tile, row, col|
        rectangle.position = {col * tile_size, row * tile_size}

        window.draw(rectangle)
      end
    end

    def draw_visibility(window)
      size = VisibilitySize
      min_row = (Screen.y // size).clamp(0, v_rows - 1).to_i
      min_col = (Screen.x // size).clamp(0, v_cols - 1).to_i
      max_row = (((Screen.y + Screen.height) // size) + 1).clamp(0, v_rows - 1).to_i
      max_col = (((Screen.x + Screen.width) // size) + 1).clamp(0, v_cols - 1).to_i

      @visibilities[min_row..max_row].each_with_index do |cols, row_index|
        row = min_row + row_index

        cols[min_col..max_col].each_with_index do |visibility, col_index|
          col = min_col + col_index

          visibility.draw(window, col * size, row * size, size, player.torch_left_percent)
        end
      end
    end
  end
end
