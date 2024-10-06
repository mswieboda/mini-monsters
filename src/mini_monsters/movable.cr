require "./box"

module MiniMonsters
  class Movable
    getter x  : Int32 | Float32
    getter y : Int32 | Float32
    getter dx : Int32 | Float32
    getter dy : Int32 | Float32
    getter? moved
    getter collision_box : Box

    Size = 64
    Speed = 256

    def initialize(row = 0, col = 0)
      @x = 0
      @y = 0
      @dx = 0
      @dy = 0
      @moved = false
      @collision_box = Box.new(collision_box_size)

      jump_to_tile(row, col)
    end

    def size
      Size
    end

    def speed
      Speed
    end

    def collision_box_size
      size
    end

    def cx
      x + Size // 2
    end

    def cy
      y + Size // 2
    end

    def collision_box_x
      x
    end

    def collision_box_y
      y
    end

    def update_movement(frame_time, level_width = 0, level_height = 0, collidable_tiles = [] of TileData)
      @moved = false

      update_with_direction_and_speed(frame_time)
      move_with_level(level_width, level_height)

      return if dx == 0 && dy == 0

      move_with_collidables(collidable_tiles) unless collidable_tiles.empty?

      return if dx == 0 && dy == 0

      move(dx, dy)
    end

    def update_with_direction_and_speed(frame_time)
      directional_speed = dx != 0 && dy != 0 ? speed / 1.4142 : speed
      @dx *= (directional_speed * frame_time).to_f32
      @dy *= (directional_speed * frame_time).to_f32
    end

    def move_with_level(level_width, level_height)
      if level_width > 0
        @dx = 0 if collision_box_x + dx < 0 || collision_box_x + collision_box.size + dx > level_width
      end

      if level_height > 0
        @dy = 0 if collision_box_y + dy < 0 || collision_box_y + collision_box.size + dy > level_height
      end
    end

    def move_with_collidables(tiles)
      t_c_box = Box.new(TileSize)

      tiles.each do |_tile, row, col|
        if collides?(dx, 0, t_c_box, col * TileSize, row * TileSize)
          @dx = 0
          break
        end
      end

      return if dx == 0 && dy == 0

      tiles.each do |_tile, row, col|
        if collides?(0, dy, t_c_box, col * TileSize, row * TileSize)
          @dy = 0
          break
        end
      end
    end

    def move(dx, dy)
      jump(x + dx, y + dy)
    end

    def jump(x, y)
      @x = x
      @y = y

      @moved = true
    end

    def jump_to_tile(row, col)
      jump(col * TileSize, row * TileSize)
    end

    def collides?(dx, dy, other : Box, other_x, other_y)
      collision_box.collides?(collision_box_x + dx, collision_box_y + dy, other, other_x, other_y)
    end

    def draw(window : SF::RenderWindow)
    end
  end
end
