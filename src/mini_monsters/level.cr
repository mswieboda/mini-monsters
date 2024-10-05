require "./tile"
require "./monster"

module MiniMonsters
  class Level
    alias Tiles = Hash(Int32, Hash(Int32, Tile))

    getter player : Player
    getter rows : Int32
    getter cols : Int32
    getter tile_sprite : SF::Sprite
    getter monsters : Array(Monster)

    @tiles : Tiles

    Debug = true
    TileSize = 128

    def initialize(@player : Player, @rows = 9, @cols = 9)
      @tiles = Tiles.new
      @tile_sprite = SF::Sprite.new
      @monsters = [] of Monster
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

    def init
      init_tiles
      init_monsters
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

    def init_monsters
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks)
      player.update(frame_time, keys, joysticks, width, height)

      update_visibility(player) if player.moved?
    end

    def update_visibility(player : Player)
      # get all tiles within rectangle of player visibility radius
      x = player.torch_cx - player.visibility_radius
      y = player.torch_cy - player.visibility_radius
      size = player.visibility_radius * 2

      min_row = (y / Tile.size).to_i - 1
      min_col = (x / Tile.size).to_i - 1
      max_row = ((y + size) / Tile.size).ceil.to_i
      max_col = ((x + size) / Tile.size).ceil.to_i

      # check these tiles against player visibility circle
      (min_row..max_row).each do |row|
        next unless @tiles.has_key?(row)

        (min_col..max_col).each do |col|
          next unless @tiles[row].has_key?(col)

          if tile = @tiles[row][col]
            tile.reset_visibility
            update_tile_visibility(tile, row, col, player)
          end
        end
      end
    end

    def update_tile_visibility(tile, row, col, player)
      x = col * tile.size
      y = row * tile.size

      if tile.collision_with_circle?(x, y, tile.size, player.torch_cx, player.torch_cy, player.visibility_radius)
        tile.update_visibility(x, y, player)
      end
    end

    def draw(window : SF::RenderWindow)
      draw_tiles(window)

      monsters.each(&.draw(window))

      player.draw(window)

      draw_visibility(window)

      player.draw_monster_attack_radius(window) if Debug
    end

    def draw_tiles(window)
      @tiles.each do |row, tiles|
        tiles.each do |col, tile|
          tile.draw(window, row, col, tile_sprite)
        end
      end
    end

    def draw_visibility(window)
      @tiles.each do |row, tiles|
        tiles.each do |col, tile|
          tile.draw_visibility(window, row, col, player.torch_left_percent)
        end
      end

      player.draw_torch_visibility(window)
    end
  end
end
