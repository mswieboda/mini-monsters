require "./box"
require "./circle"

module MiniMonsters
  class Movable
    getter x  : Int32 | Float32
    getter y : Int32 | Float32
    getter dx : Int32 | Float32
    getter dy : Int32 | Float32
    getter? moved
    getter collision_circle : Circle

    Size = 64
    Radius = Size // 2
    Speed = 256

    def initialize(row = 0, col = 0)
      @x = 0
      @y = 0
      @dx = 0
      @dy = 0
      @moved = false
      @collision_circle = Circle.new(collision_radius)

      jump_to_tile(row, col)
    end

    def size
      Size
    end

    def speed
      Speed
    end

    def collision_radius
      Radius
    end

    def cx
      collision_x + collision_radius
    end

    def cy
      collision_y + collision_radius
    end

    def collision_x
      x + (size - collision_radius * 2) / 2
    end

    def collision_y
      y + (size - collision_radius * 2) / 2
    end

    def collision_cx
      collision_x + collision_radius
    end

    def collision_cy
      collision_y + collision_radius
    end

    def update_movement(
      frame_time,
      level_width = 0,
      level_height = 0,
      collidable_tiles = [] of TileData,
      movables = [] of Movable
    )
      @moved = false

      update_with_direction_and_speed(frame_time)
      move_with_level(level_width, level_height)

      return if dx == 0 && dy == 0

      move_with_collidable_tiles(collidable_tiles) unless collidable_tiles.empty?

      return if dx == 0 && dy == 0

      move_with_movables(movables) unless movables.empty?

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
        @dx = 0 if collision_x + dx < 0 || collision_cx + collision_radius + dx > level_width
      end

      if level_height > 0
        @dy = 0 if collision_y + dy < 0 || collision_cy + collision_radius + dy > level_height
      end
    end

    def move_with_collidable_tiles(tiles)
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

    def move_with_movables(movables)
      movables.each do |movable|
        if collides?(dx, 0, movable)
          @dx = 0
          break
        end
      end

      return if dx == 0 && dy == 0

      movables.each do |movable|
        if collides?(0, dy, movable)
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

    def collides?(movable : Movable)
      collides?(movable.collision_circle, movable.collision_cx, movable.collision_cy)
    end

    def collides?(circle : Circle, cx, cy)
      collision_circle.collides?(collision_cx, collision_cy, circle, cx, cy)
    end

    def collides?(dx, dy, movable : Movable)
      collides?(dx, dy, movable.collision_circle, movable.collision_cx, movable.collision_cy)
    end

    def collides?(dx, dy, box : Box, box_x, box_y)
      collision_circle.collides?(collision_cx + dx, collision_cy + dy, box, box_x, box_y)
    end

    def collides?(dx, dy, circle : Circle, cx, cy)
      collision_circle.collides?(collision_cx + dx, collision_cy + dy, circle, cx, cy)
    end

    def draw(window : SF::RenderWindow)
    end
  end
end
