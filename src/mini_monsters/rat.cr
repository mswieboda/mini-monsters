require "./monster"

module MiniMonsters
  class Rat < Monster
    getter animations : GSF::Animations

    SpriteSheet = "./assets/sprites/rat.png"
    Frames = 3

    def initialize(row = 0, col = 0)
      super

      @following = false

      # animations
      idle_right = GSF::Animation.new
      idle_right.add(SpriteSheet, 0, 0, size, size)

      @animations = GSF::Animations.new(:idle_right, idle_right)

      init_animations
    end

    def init_animations
      [:move_right, :move_up, :move_right_up, :move_right_down].each_with_index do |name, row|
        add_animation(name, row)
      end

      add_animation(:move_left, row: 0, flip_horizontal: true)
      add_animation(:move_down, row: 1, flip_vertical: true)
      add_animation(:move_left_up, row: 2, flip_horizontal: true)
      add_animation(:move_left_down, row: 3, flip_horizontal: true)
    end

    def add_animation(name, row, flip_horizontal = false, flip_vertical = false)
      animation = GSF::Animation.new

      Frames.times do |i|
        animation.add(
          filename: SpriteSheet,
          x: i * size,
          y: row * size,
          width: size,
          height: size
        )
      end

      animations.add(name, animation, flip_horizontal: flip_horizontal, flip_vertical: flip_vertical)
    end

    def update(frame_time)
      animations.update(frame_time)
      play_animation
    end

    def play_animation
      if dx == 0
        if dy < 0
          animations.play(:move_up)
        elsif dy > 0
          animations.play(:move_down)
        else
          animations.pause
        end
      elsif dx < 0
        if dy < 0
          animations.play(:move_left_up)
        elsif dy > 0
          animations.play(:move_left_down)
        else
          animations.play(:move_left)
        end
      elsif dx > 0
        if dy < 0
          animations.play(:move_right_up)
        elsif dy > 0
          animations.play(:move_right_down)
        else
          animations.play(:move_right)
        end
      end
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, cx, cy)

      return unless Debug

      collision_circle.draw(window, collision_cx, collision_cy)
    end
  end
end
