module MiniMonsters
  class Player
    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter animations

    AnimationDuration = 125
    Size = 128
    Speed = 640
    Sheet = "./assets/player.png"

    def initialize(x = 0, y = 0)
      # sprite size
      @x = x
      @y = y

      # init animations
      # idle
      idle = GSF::Animation.new(loops: false)
      idle.add(Sheet, 0, 0, size, size)

      # fire animation
      fire_frames = 3
      fire = GSF::Animation.new(loops: false)

      fire_frames.times do |i|
        fire.add(Sheet, i * size, 0, size, size, duration_ms: AnimationDuration)
      end

      @animations = GSF::Animations.new(:idle, idle)
      animations.add(:fire, fire)
    end

    def size
      Size
    end

    def update(frame_time, keys : Keys)
      animations.update(frame_time)

      update_movement(frame_time, keys)
    end

    def update_movement(frame_time, keys : Keys)
      dx = 0
      dy = 0

      dy -= 1 if keys.pressed?([Keys::W])
      dx -= 1 if keys.pressed?([Keys::A])
      dy += 1 if keys.pressed?([Keys::S])
      dx += 1 if keys.pressed?([Keys::D])

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
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y)
    end
  end
end
