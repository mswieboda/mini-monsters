require "./movable"

module MonsterMaze
  class Monster < Movable
    getter animations : GSF::Animations
    getter? following
    getter? attacking
    getter? attacked
    getter next_attack_timer : Timer

    CollisionRadius = 16
    Speed = 256
    AnimationFrames = 1
    EmptyString = ""
    AttackSpeed = Speed * 3
    NextAttackDurationMin = 300 # milliseconds
    NextAttackDurationMax = 500 # milliseconds
    Damage = 5
    SkipPathingRatio = 1.25

    def initialize(row = 0, col = 0)
      super

      @following = false
      @attacking = false
      @attacked = false
      @next_attack_timer = Timer.new(NextAttackDurationMax.milliseconds, true)

      # animations
      idle_right = GSF::Animation.new
      idle_right.add(sprite_sheet, 0, 0, size, size)

      @animations = GSF::Animations.new(:idle_right, idle_right)

      init_animations
    end

    def speed
      Speed
    end

    def collision_radius
      CollisionRadius
    end

    def animation_frames
      AnimationFrames
    end

    def sprite_sheet
      EmptyString
    end

    def attack_speed
      AttackSpeed
    end

    def damage
      Damage
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

      animation_frames.times do |i|
        animation.add(
          filename: sprite_sheet,
          x: i * size,
          y: row * size,
          width: size,
          height: size
        )
      end

      animations.add(name, animation, flip_horizontal: flip_horizontal, flip_vertical: flip_vertical)
    end

    def follow_range?(player : Player)
      # TODO: this is very inefficient,
      #       need to figure out when following? monsters should regenerate path again
      return true if following?

      # more efficient guards before doing box/circle collision detection
      return false if cx < player.torch_cx - player.monster_follow_radius - player.size * 2
      return false if cx > player.torch_cx + player.monster_follow_radius + player.size * 2
      return false if cy < player.torch_cy - player.monster_follow_radius - player.size * 2
      return false if cy > player.torch_cy + player.monster_follow_radius + player.size * 2
      return false if MathHelpers.distance(cx, cy, player.cx, player.cy) < player.monster_radius * SkipPathingRatio

      collides?(player.monster_follow_radius, player.torch_cx, player.torch_cy)
    end

    def follow_player!(player : Player, tiles : GSF::Path::Tiles)
      @following = true

      # make path to player
      entity = {row: (cy // TileSize).to_i, col: (cx // TileSize).to_i}
      target = {row: (player.collision_cy // TileSize).to_i, col: (player.collision_cx // TileSize).to_i}

      @path = GSF::Path.find(entity, target, tiles)

      # removes our cx, cy since we're already there
      @path.shift

      @path
    end

    def ready_to_attack?
      next_attack_timer.done?
    end

    def attack!
      @attacking = true
    end

    def stop_attacking!
      @attacking = false
      @attacked = false
    end

    def update(frame_time)
      animations.update(frame_time)
      play_animation
    end

    def update_following(frame_time, p_cx, p_cy, p_dist, collidable_tiles, movables)
      update(frame_time)

      @attacked = false

      if attacking?
        move_towards(p_cx, p_cy, 0, 0)

        dist = MathHelpers.distance(cx, cy, p_cx, p_cy)

        if dist <= size // 2
          @attacked = true
          @next_attack_timer.duration = rand(NextAttackDurationMin..NextAttackDurationMax).milliseconds
          @next_attack_timer.restart
          @attacking = false
        end
      elsif !@path.empty? && MathHelpers.distance(cx, cy, p_cx, p_cy) >= p_dist * SkipPathingRatio
        move_with_path(@path.first)
      else
        @path.clear
        move_towards(p_cx, p_cy, p_dist, size)
      end

      return if dx == 0 && dy == 0

      movement_speed = attacking? || attacked? ? attack_speed : speed

      update_movement(frame_time, speed: movement_speed, collidable_tiles: collidable_tiles, movables: movables)
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
