module MiniMonsters
  class Player
    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter dx : Int32 | Float32
    getter dy : Int32 | Float32
    getter? moved
    getter circle : SF::CircleShape

    Size = 128
    Radius = Size / 2
    Speed = 640
    VisibilityRadius = 256

    def initialize(@x = 0, @y = 0)
      @dx = 0
      @dy = 0
      @moved = false

      @circle = SF::CircleShape.new(radius)
      @circle.position = {x, y}
    end

    def radius
      Radius
    end

    def size
      Size
    end

    def visibility_radius
      VisibilityRadius
    end

    def center_x
      x + size / 2
    end

    def center_y
      y + size / 2
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks, level_width, level_height)
      update_movement_dx_input(keys, joysticks)
      update_movement_dy_input(keys, joysticks)
      update_movement(frame_time, level_width, level_height)
    end

    def update_movement_dx_input(keys, joysticks)
      @dx = 0

      @dx -= 1 if keys.pressed?([Keys::A]) || joysticks.left_stick_moved_left? || joysticks.d_pad_moved_left?
      @dx += 1 if keys.pressed?([Keys::D]) || joysticks.left_stick_moved_right? || joysticks.d_pad_moved_right?
    end

    def update_movement_dy_input(keys, joysticks)
      @dy = 0

      @dy -= 1 if keys.pressed?([Keys::W]) || joysticks.left_stick_moved_up? || joysticks.d_pad_moved_up?
      @dy += 1 if keys.pressed?([Keys::S]) || joysticks.left_stick_moved_down? || joysticks.d_pad_moved_down?
    end

    def update_movement(frame_time, level_width, level_height)
      @moved = false

      return if dx == 0 && dy == 0

      return if dx == 0 && dy == 0

      update_with_direction_and_speed(frame_time)
      move_with_level(level_width, level_height)

      return if dx == 0 && dy == 0

      move(dx, dy)
    end

    def update_with_direction_and_speed(frame_time)
      directional_speed = dx != 0 && dy != 0 ? Speed / 1.4142 : Speed
      @dx *= (directional_speed * frame_time).to_f32
      @dy *= (directional_speed * frame_time).to_f32
    end

    def move_with_level(level_width, level_height)
      @dx = 0 if x + dx < 0 || x + size + dx > level_width
      @dy = 0 if y + dy < 0 || y + size + dy > level_height
    end

    def move(dx, dy)
      jump(x + dx, y + dy)
    end

    def jump(x, y)
      @x = x
      @y = y

      @moved = true
      @circle.position = {x, y}
    end

    def jump_to_tile(col, row, tile_size)
      jump(col * tile_size, row * tile_size)
    end

    def draw(window : SF::RenderWindow)
      window.draw(circle)
    end
  end
end
