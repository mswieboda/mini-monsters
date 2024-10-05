module MiniMonsters
  class Level
    getter player : Player
    getter rows : Int32
    getter cols : Int32

    TileSize = 64

    def initialize(@player : Player, @rows = 9, @cols = 9)
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
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks)
      player.update(frame_time, keys, joysticks, width, height)
    end

    def draw(window : SF::RenderWindow)
      draw_tiles(window)
      player.draw(window)
    end

    def draw_tiles(window)
      rows.times do |row|
        cols.times do |col|
          draw_tile(window, col * tile_size, row * tile_size)
        end
      end
    end

    def draw_tile(window, x, y)
    end
  end
end
