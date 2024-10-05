require "./tile"

module MiniMonsters
  class Level
    alias Tiles = Hash(Int32, Hash(Int32, Tile))

    getter player : Player
    getter rows : Int32
    getter cols : Int32

    @tiles : Tiles

    TileSize = 64

    def initialize(@player : Player, @rows = 9, @cols = 9)
      @tiles = Tiles.new
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

    def to_tile(col, row)
      {col * tile_size, row * tile_size}
    end

    def start
      init_tiles
      reset_visibility
      player_jump_to_start
      update_visibility(player)
    end

    def player_jump_to_start
      player.jump_to_tile(0, 0, tile_size)
    end

    def init_tiles
      @tiles = Tiles.new

      rows.times do |row|
        @tiles[row] = Hash(Int32, Tile).new

        cols.times do |col|
          @tiles[row][col] = Tile.new
        end
      end
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks)
      player.update(frame_time, keys, joysticks, width, height)

      if player.moved?
        reset_visibility
        update_visibility(player)
      end
    end

    def reset_visibility
      @tiles.each do |_row, tiles|
        tiles.each do |_col, tile|
          tile.reset_visibility
        end
      end
    end

    def update_visibility(player : Player)
      # get all tiles within rectangle of player visibility radius
      x = player.x - player.visibility_radius
      y = player.y - player.visibility_radius
      size = player.visibility_radius * 2

      min_row = (y / Tile.size).to_i
      min_col = (x / Tile.size).to_i
      max_row = ((y + size) / Tile.size).ceil.to_i
      max_col = ((x + size) / Tile.size).ceil.to_i

      # check these tiles against player visibility circle
      (min_row..max_row).each do |row|
        next unless @tiles.has_key?(row)

        (min_col..max_col).each do |col|
          next unless @tiles[row].has_key?(col)

          if tile = @tiles[row][col]
            explore_tile_check(tile, row, col, player)
          end
        end
      end
    end

    def explore_tile_check(tile, row, col, player)
      if tile.collision_with_circle?(row, col, player.center_x, player.center_y, player.visibility_radius)
        tile.explore
      end
    end

    def draw(window : SF::RenderWindow)
      draw_tiles(window)
      player.draw(window)

      draw_visibility(window)
    end

    def draw_tiles(window)
      @tiles.each do |row, tiles|
        tiles.each do |col, tile|
          tile.draw(window, col, row)
        end
      end
    end

    def draw_visibility(window)
      @tiles.each do |row, tiles|
        tiles.each do |col, tile|
          tile.draw_visibility(window, col, row)
        end
      end
    end
  end
end
