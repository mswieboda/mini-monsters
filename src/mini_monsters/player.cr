require "./box"

module MiniMonsters
  class Player
    alias Tiles = Array(Tuple(Int32, Int32, Int32)) # tile_type, row, col

    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter dx : Int32 | Float32
    getter dy : Int32 | Float32
    getter? moved
    getter animations : GSF::Animations
    getter collision_box : Box

    Size = 128
    Radius = Size / 2
    Speed = 512
    VisibilityRadius = 512
    SpriteWidth = 96
    SpriteHeight = 128
    Sheet = "./assets/sprites/player.png"
    AnimationDuration = 42
    TorchMaxAlpha = 32
    TorchSegments = 8
    TorchSegmentDuration = 5.seconds
    MonsterRadiusMin = 96
    MonsterRadiusMax = 256
    MonsterRadiusColor = SF::Color.new(255, 251, 0, 7)
    MonsterAttackRadius = VisibilityRadius - 128
    CollisionBoxSize = 40
    CollisionBoxXOffset = 24
    CollisionBoxYOffset = 96

    @torch_duration_alpha : Int32

    def initialize(@x = 0, @y = 0)
      @dx = 0
      @dy = 0
      @moved = false
      @collision_box = Box.new(CollisionBoxSize)

      idle = GSF::Animation.new(loops: true)
      idle.add(Sheet, 0, 0, SpriteWidth, SpriteHeight, duration_ms: AnimationDuration)

      run_frames = 12
      run = GSF::Animation.new(loops: true)

      run_frames.times do |i|
        run.add(Sheet, i * SpriteWidth, 0, SpriteWidth, SpriteHeight, duration_ms: AnimationDuration)
      end

      @animations = GSF::Animations.new(:idle_left, idle)
      animations.add(:idle_right, idle, flip_horizontal: true)
      animations.add(:run_left, run)
      animations.add(:run_right, run, flip_horizontal: true)

      @torch_duration_alpha = TorchMaxAlpha - 1
      @torch_segment_timer = Timer.new(TorchSegmentDuration)
      @torch_segment_timer.start
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

    def torch_cx
      x + 12
    end

    def torch_cy
      y + 38
    end

    def torch_left_percent
      @torch_duration_alpha / (TorchMaxAlpha - 1)
    end

    def monster_radius
      MonsterRadiusMin + (torch_left_percent * (MonsterRadiusMax - MonsterRadiusMin)).to_i
    end

    def collision_box_x
      x + CollisionBoxXOffset
    end

    def collision_box_y
      y + CollisionBoxYOffset
    end

    def init
      @torch_duration_alpha = TorchMaxAlpha - 1
      @torch_segment_timer.start
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks, level_width, level_height, collidable_tiles : Tiles, tile_size : Int32)
      update_movement_dx_input(keys, joysticks)
      update_movement_dy_input(keys, joysticks)
      update_movement(frame_time, level_width, level_height, collidable_tiles, tile_size)
      play_animation
      animations.update(frame_time)
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

    def update_movement(frame_time, level_width, level_height, collidable_tiles : Tiles, tile_size : Int32)
      @moved = false

      return if dx == 0 && dy == 0

      return if dx == 0 && dy == 0

      update_with_direction_and_speed(frame_time)
      move_with_level(level_width, level_height)

      return if dx == 0 && dy == 0

      move_with_collidables(collidable_tiles, tile_size)

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

    def move_with_collidables(tiles, tile_size)
      t_c_box = Box.new(tile_size)

      tiles.each do |row, col|
        if collides?(dx, 0, t_c_box, col * tile_size, row * tile_size)
          @dx = 0
          break
        end
      end

      return if dx == 0 && dy == 0

      tiles.each do |row, col|
        if collides?(0, dy, t_c_box, col * tile_size, row * tile_size)
          @dy = 0
          break
        end
      end
    end

    def play_animation
      # TODO: use run_right and idle_right too, based on last movement
      if dx.abs > 0 || dy.abs > 0
        animations.play(:run_left)
      else
        animations.play(:idle_left)
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

    def move(dx, dy)
      jump(x + dx, y + dy)
    end

    def jump(x, y)
      @x = x
      @y = y

      @moved = true
    end

    def jump_to_tile(row, col, tile_size)
      jump(col * tile_size, row * tile_size)
    end

    def collides?(dx, dy, other : Box, other_x, other_y)
      collision_box.collides?(collision_box_x + dx, collision_box_y + dy, other, other_x, other_y)
    end

    def draw(window : SF::RenderWindow)
      draw_monster_radius(window) if @torch_duration_alpha > 0
      animations.draw(window, x + SpriteWidth / 2, y + SpriteHeight / 2)
      collision_box.draw(window, collision_box_x, collision_box_y)
      draw_player_border(window)
    end

    def draw_player_border(window)
      rectangle = SF::RectangleShape.new({size, size})
      rectangle.position = {x, y}
      rectangle.fill_color = SF::Color::Transparent
      rectangle.outline_color = SF::Color::Green
      rectangle.outline_thickness = 2

      window.draw(rectangle)
    end

    def draw_circle_from_torch(window, radius, color)
      circle = SF::CircleShape.new(radius)
      circle.origin = {radius, radius}
      circle.position = {torch_cx, torch_cy}
      circle.fill_color = color

      window.draw(circle)
    end

    def draw_monster_attack_radius(window : SF::RenderWindow)
      draw_circle_from_torch(window, MonsterAttackRadius, SF::Color.new(255, 0, 255, 7))
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
