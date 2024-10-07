require "./movable"

module MiniMonsters
  class Player < Movable
    getter animations : GSF::Animations
    getter animations_flame : GSF::Animations

    Size = 128
    Speed = 448
    VisibilityRadius = 512
    SpriteWidth = 96
    SpriteHeight = 128
    Sheet = "./assets/sprites/player.png"
    SheetFlamesIdle = "./assets/sprites/flames_idle.png"
    SheetFlamesRun = "./assets/sprites/flames_run.png"
    AnimationDuration = 42
    TorchMaxAlpha = 32
    TorchSegments = 8
    TorchSegmentDuration = 1.seconds
    MonsterRadiusMin = 64
    MonsterRadiusMax = 256
    MonsterRadiusColor = SF::Color.new(255, 251, 0, 7)
    MonsterFollowRadius = VisibilityRadius - 128
    CollisionRadius = 24
    CollisionXOffset = 24
    CollisionYOffset = 96

    @torch_duration_alpha : Int32

    def initialize(row = 0, col = 0)
      super

      @torch_duration_alpha = TorchMaxAlpha - 1
      @torch_segment_timer = Timer.new(TorchSegmentDuration)
      @torch_segment_timer.start

      # player animations
      idle = GSF::Animation.new(loops: true)
      idle.add(Sheet, 0, 0, SpriteWidth, SpriteHeight, duration_ms: AnimationDuration)

      frames_run = 12
      run = GSF::Animation.new(loops: true)

      frames_run.times do |i|
        run.add(Sheet, i * SpriteWidth, 0, SpriteWidth, SpriteHeight, duration_ms: AnimationDuration)
      end

      @animations = GSF::Animations.new(:idle_left, idle)
      # animations.add(:idle_right, idle, flip_horizontal: true)
      animations.add(:run_left, run)
      animations.add(:run_right, run, flip_horizontal: true)

      # flame animations
      frames_idle_flame = 4
      idle_flame = GSF::Animation.new(loops: true)
      idle_flame.add(SheetFlamesIdle, 0, 0, SpriteWidth, SpriteHeight, duration_ms: AnimationDuration)

      frames_idle_flame.times do |i|
        idle_flame.add(SheetFlamesIdle, i * SpriteWidth, 0, SpriteWidth, SpriteHeight, duration_ms: AnimationDuration)
      end

      run_flame = GSF::Animation.new(loops: true)

      frames_run.times do |i|
        run_flame.add(SheetFlamesRun, i * SpriteWidth, 0, SpriteWidth, SpriteHeight, duration_ms: AnimationDuration)
      end

      @animations_flame = GSF::Animations.new(:idle_flame_left, idle_flame)
      animations_flame.add(:run_flame_left, run_flame)
    end

    def size
      Size
    end

    def speed
      Speed
    end

    def collision_radius
      CollisionRadius
    end

    def cx
      x + Size // 2
    end

    def cy
      y + Size // 2
    end

    def collision_x
      x + CollisionXOffset
    end

    def collision_y
      y + CollisionYOffset
    end

    def visibility_radius
      VisibilityRadius
    end

    def torch_cx
      x + 12
    end

    def torch_cy
      y + 16
    end

    def torch_left_percent
      @torch_duration_alpha / (TorchMaxAlpha - 1)
    end

    def monster_radius
      MonsterRadiusMin + (torch_left_percent * (MonsterRadiusMax - MonsterRadiusMin)).to_i
    end

    def monster_follow_radius
      MonsterFollowRadius
    end

    def init
      @torch_duration_alpha = TorchMaxAlpha - 1
      @torch_segment_timer.start
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks, level_width, level_height, collidable_tiles : Tiles)
      update_movement_dx_input(keys, joysticks)
      update_movement_dy_input(keys, joysticks)
      update_movement(frame_time, level_width, level_height, collidable_tiles)
      play_animations
      animations.update(frame_time)
      animations_flame.update(frame_time)
      update_torch_segements
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

    def play_animations
      # TODO: use run_right and idle_right too, based on last movement
      if dx.abs > 0 || dy.abs > 0
        animations.play(:run_left)
        animations_flame.play(:run_flame_left)
      else
        animations.play(:idle_left)
        animations_flame.play(:idle_flame_left)
      end
    end

    def update_torch_segements
      if @torch_segment_timer.done?
        @torch_duration_alpha -= TorchMaxAlpha // TorchSegments

        if @torch_duration_alpha < 0
          @torch_duration_alpha = 0
          @torch_segment_timer.stop
        else
          @torch_segment_timer.restart
        end
      end
    end

    def jump_to_tile(row, col)
      x = col * TileSize + TileSize // 2 - CollisionXOffset - collision_radius
      y = row * TileSize + TileSize // 2 - CollisionYOffset - collision_radius

      jump(x, y)
    end

    def draw(window : SF::RenderWindow)
      draw_monster_radius(window) if @torch_duration_alpha > 0

      animations.draw(window, x + SpriteWidth / 2, y + SpriteHeight / 2)

      draw_flame(window) if @torch_duration_alpha > 0
      draw_player_borders(window) if Debug
    end

    def draw_flame(window)
      flame_color = SF::Color.new(255, 255, 255, 256 - (TorchMaxAlpha - @torch_duration_alpha))

      animations_flame.draw(window, x + SpriteWidth / 2, y + SpriteHeight / 2, color: flame_color)
    end

    def draw_player_borders(window)
      rectangle = SF::RectangleShape.new({size, size})
      rectangle.position = {x, y}
      rectangle.fill_color = SF::Color::Transparent
      rectangle.outline_color = SF::Color::Green
      rectangle.outline_thickness = 2

      window.draw(rectangle)

      collision_circle.draw(window, collision_cx, collision_cy)
    end

    def draw_circle_from_torch(window, radius, color)
      circle = SF::CircleShape.new(radius)
      circle.origin = {radius, radius}
      circle.position = {torch_cx, torch_cy}
      circle.fill_color = color

      window.draw(circle)
    end

    def draw_monster_follow_radius(window : SF::RenderWindow)
      draw_circle_from_torch(window, monster_follow_radius, SF::Color.new(255, 0, 255, 7))
    end

    def draw_monster_radius(window : SF::RenderWindow)
      draw_circle_from_torch(window, monster_radius, MonsterRadiusColor)
    end

    def draw_torch_visibility(window : SF::RenderWindow)
      alpha = @torch_duration_alpha

      [
        {radius: 64, color: SF::Color.new(255, 170, 0, alpha)},
        {radius: 32, color: SF::Color.new(255, 102, 0, alpha)}
      ].each do |light|
        draw_circle_from_torch(window, light[:radius], light[:color])
      end
    end
  end
end
