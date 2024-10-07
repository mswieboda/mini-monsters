require "./movable"

module MiniMonsters
  class Player < Movable
    getter animations : GSF::Animations
    getter animations_flame : GSF::Animations
    getter health : Int32
    getter? dead
    getter death_timer : Timer

    Size = 96
    Speed = 448
    VisibilityRadius = 512
    SpriteWidth = 96
    SpriteHeight = 128
    Sheet = "./assets/sprites/player.png"
    FramesIdle = 1
    FramesRun = 12
    FramesFlamesIdle = 4
    SheetFlamesIdle = "./assets/sprites/flames_idle.png"
    SheetFlamesRun = "./assets/sprites/flames_run.png"
    AnimationDuration = 42
    TorchMaxAlpha = 32
    TorchSegments = 8
    TorchSegmentDuration = 5.seconds
    TorchXOffset = 12
    TorchYOffset = 16
    MonsterRadiusMin = 64
    MonsterRadiusMax = 256
    MonsterRadiusColor = SF::Color.new(255, 251, 0, 7)
    MonsterFollowRadius = VisibilityRadius - 128
    CollisionRadius = 24
    CollisionXOffset = 24
    CollisionYOffset = 96
    MaxHealth = 100
    DeadDarkenMin = 63
    DeathAnimationDuration = 300.milliseconds

    @torch_duration_alpha : Int32
    @last_dx : Int32

    def initialize(row = 0, col = 0)
      super

      @torch_duration_alpha = TorchMaxAlpha - 1
      @torch_segment_timer = Timer.new(TorchSegmentDuration)
      @torch_segment_timer.start
      @last_dx = 0
      @health = MaxHealth
      @dead = false
      @death_timer = Timer.new(DeathAnimationDuration)

      @animations = GSF::Animations.new(:idle_left)
      @animations_flame = GSF::Animations.new(:idle_flame_left)

      init_animations
    end

    def init_animations
      add_animation(Sheet, animations, :idle_left, FramesIdle, loops: false)
      add_animation(Sheet, animations, :idle_right, FramesIdle, loops: false, flip_horizontal: true)

      add_animation(Sheet, animations, :run_left, FramesRun)
      add_animation(Sheet, animations, :run_right, FramesRun, flip_horizontal: true)

      add_animation(SheetFlamesIdle, animations_flame, :idle_flame_left, FramesFlamesIdle)
      add_animation(SheetFlamesIdle, animations_flame, :idle_flame_right, FramesFlamesIdle, flip_horizontal: true)

      add_animation(SheetFlamesRun, animations_flame, :run_flame_left, FramesRun)
      add_animation(SheetFlamesRun, animations_flame, :run_flame_right, FramesRun, flip_horizontal: true)
    end

    def add_animation(sheet, animations, name, frames, loops = true, flip_horizontal = false)
      animation = GSF::Animation.new(loops)

      frames.times do |i|
        animation.add(
          filename: sheet,
          x: i * SpriteWidth,
          y: 0,
          width: SpriteWidth,
          height: SpriteHeight,
          duration_ms: AnimationDuration
        )
      end

      animations.add(name, animation, flip_horizontal: flip_horizontal)
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
      if @last_dx <= 0
        x + TorchXOffset
      else
        x + Size - TorchXOffset
      end
    end

    def torch_cy
      y + TorchYOffset
    end

    def torch_left_percent
      @torch_duration_alpha / (TorchMaxAlpha - 1)
    end

    def torch_out?
      @torch_duration_alpha <= 0
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
      update_movement(frame_time, level_width: level_width, level_height: level_height, collidable_tiles: collidable_tiles)

      play_animations

      animations.update(frame_time)
      animations_flame.update(frame_time)

      update_torch_segements
    end

    def update_movement_dx_input(keys, joysticks)
      @dx = 0

      return if dead?

      @dx -= 1 if keys.pressed?([Keys::A]) || joysticks.left_stick_moved_left? || joysticks.d_pad_moved_left?
      @dx += 1 if keys.pressed?([Keys::D]) || joysticks.left_stick_moved_right? || joysticks.d_pad_moved_right?
    end

    def update_movement_dy_input(keys, joysticks)
      @dy = 0

      return if dead?

      @dy -= 1 if keys.pressed?([Keys::W]) || joysticks.left_stick_moved_up? || joysticks.d_pad_moved_up?
      @dy += 1 if keys.pressed?([Keys::S]) || joysticks.left_stick_moved_down? || joysticks.d_pad_moved_down?
    end

    def move(dx, dy)
      super(dx, dy)

      @last_dx = dx.sign if dx.abs > 0
    end

    def play_animations
      run = dx.abs > 0 || dy.abs > 0

      if @last_dx > 0
        animations.play(run ? :run_right : :idle_right)
        animations_flame.play(run ? :run_flame_right : :idle_flame_right)
      else
        animations.play(run ? :run_left : :idle_left)
        animations_flame.play(run ? :run_flame_left : :idle_flame_left)
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

    def torch_refill!
      @torch_duration_alpha = TorchMaxAlpha - 1
    end

    def take_damage(damage : Int32)
      return if dead?

      @health -= damage

      if @health <= 0
        @health = 0
        die!
      end
    end

    def die!
      @death_timer.start unless dead?
      @dead = true
    end

    def draw(window : SF::RenderWindow)
      draw_monster_radius(window) if @torch_duration_alpha > 0

      color = nil

      if dead?
        darken = DeadDarkenMin + (255 - DeadDarkenMin) * (1 - @death_timer.percent.clamp(0, 1))
        color = SF::Color.new((DeadDarkenMin + darken.to_i).clamp(0, 255), darken.to_i, darken.to_i)
      end

      animations.draw(window, x + SpriteWidth / 2, y + SpriteHeight / 2, color: color)

      draw_flame(window) if @torch_duration_alpha > 0

      draw_health(window) if health < MaxHealth

      draw_player_borders(window) if Debug
    end

    def draw_flame(window)
      flame_color = SF::Color.new(255, 255, 255, 256 - (TorchMaxAlpha - @torch_duration_alpha))

      animations_flame.draw(window, x + SpriteWidth / 2, y + SpriteHeight / 2, color: flame_color)
    end

    def draw_health(window)
      margin = 4
      height = 16
      health_percent = (health / MaxHealth)
      width = size * health_percent
      color = SF::Color::Green

      if health_percent < 0.3
        color = SF::Color::Red
      elsif health_percent < 0.60
        color = SF::Color.new(255, 127, 0) # orange
      elsif health_percent < 0.75
        color = SF::Color::Yellow
      end

      rectangle = SF::RectangleShape.new({width, height})
      rectangle.position = {x, y - height - margin}
      rectangle.fill_color = color

      window.draw(rectangle)
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
