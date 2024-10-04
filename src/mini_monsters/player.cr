module MiniMonsters
  class Player
    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter circle : SF::CircleShape

    Size = 128
    Radius = Size / 2
    Speed = 640

    def initialize(@x = 0, @y = 0)
      @circle = SF::CircleShape.new(radius)
      @circle.position = {x, y}
    end

    def radius
      Radius
    end

    def size
      Size
    end

    def update(frame_time, keys : Keys)
      update_movement(frame_time, keys)
    end

    def update_movement(frame_time, keys : Keys)
      dx = 0
      dy = 0

      dy -= 1 if keys.pressed?(Keys::W)
      dx -= 1 if keys.pressed?(Keys::A)
      dy += 1 if keys.pressed?(Keys::S)
      dx += 1 if keys.pressed?(Keys::D)

      return if dx == 0 && dy == 0

      dx, dy = move_with_speed(frame_time, dx, dy)
      dx, dy = move_with_level(dx, dy)

      return if dx == 0 && dy == 0

      move(dx, dy)
    end

    def move_with_speed(frame_time, dx, dy)
      speed = Speed
      directional_speed = dx != 0 && dy != 0 ? speed / 1.4142 : speed
      dx *= (directional_speed * frame_time).to_f32
      dy *= (directional_speed * frame_time).to_f32

      {dx, dy}
    end

    def move_with_level(dx, dy)
      # screen collisions
      dx = 0 if x + dx < 0 || x + dx + size > Screen.width
      dy = 0 if y + dy < 0 || y + dy + size > Screen.height

      {dx, dy}
    end

    def move(dx, dy)
      @x += dx
      @y += dy

      @circle.position = {x, y}
    end

    def draw(window : SF::RenderWindow)
      window.draw(circle)
    end
  end
end
