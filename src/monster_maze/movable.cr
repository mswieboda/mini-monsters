module MonsterMaze
  class Movable < GSF::Movable
    getter collision_circle : Circle
    getter path : GSF::Path::Cells

    Size = 64
    Radius = Size // 2
    Speed = 256

    def initialize(row = 0, col = 0)
      super(0, 0)

      @collision_circle = Circle.new(collision_radius)
      @path = [] of GSF::Path::Cell

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
      speed = speed,
      level_width = 0,
      level_height = 0,
      collidable_tiles = [] of TileData,
      movables = [] of Movable
    )
      @moved = false

      return unless move_with_speed(frame_time, speed)
      return unless move_with_level(level_width, level_height)

      unless collidable_tiles.empty?
        return unless move_with_collidable_tiles(collidable_tiles)
      end

      unless movables.empty?
        return unless move_with_movables(movables)
      end

      move(dx, dy)
    end

    def move_with_level(level_width, level_height)
      if level_width > 0
        @dx = 0 if collision_x + dx < 0 || collision_cx + collision_radius + dx > level_width
      end

      return unless moving?

      if level_height > 0
        @dy = 0 if collision_y + dy < 0 || collision_cy + collision_radius + dy > level_height
      end

      moving?
    end

    def move_with_collidable_tiles(tiles)
      t_c_box = Box.new(TileSize)

      tiles.each do |_tile, row, col|
        if collides?(dx, 0, t_c_box, col * TileSize, row * TileSize)
          @dx = 0
          break
        end
      end

      return unless moving?

      tiles.each do |_tile, row, col|
        if collides?(0, dy, t_c_box, col * TileSize, row * TileSize)
          @dy = 0
          break
        end
      end

      moving?
    end

    def move_with_movables(movables)
      movables.each do |movable|
        if collides?(dx, 0, movable)
          @dx = 0
          break
        end
      end

      return unless moving?

      movables.each do |movable|
        if collides?(0, dy, movable)
          @dy = 0
          break
        end
      end
    end

    def pathing_stay?(dist_x, dist_y)
      !moving? && dist_x.zero? && dist_y.zero?
    end

    def pathing_overpassed_target?(dist_x, dist_y)
      moving? && -@dx.sign * dist_x >= 0 && -@dy.sign * dist_y >= 0
    end

    def move_with_path(cell : GSF::Path::Cell)
      cell_cx = cell[:col] * TileSize + TileSize // 2
      cell_cy = cell[:row] * TileSize + TileSize // 2

      dist_x = cell_cx - cx
      dist_y = cell_cy - cy

      if pathing_stay?(dist_x, dist_y)
        # remove it from path
        removed_cell = @path.shift
      elsif pathing_overpassed_target?(dist_x, dist_y)
        # remove it from path
        removed_cell = @path.shift

        # make sure it's exactly at center, move it backwards (glitchy)
        jump_to_tile(removed_cell[:row], removed_cell[:col]) unless dist_x.zero? && dist_y.zero?

        @dx = 0
        @dy = 0
      else
        new_dx = dist_x.sign
        new_dy = dist_y.sign

        @dx = new_dx
        @dy = new_dy
      end
    end

    def move_towards(target_cx, target_cy, target_dist_threshold, inner_threshold)
      @dx = delta_from_move_towards_target(cx, target_cx, target_dist_threshold, inner_threshold)
      @dy = delta_from_move_towards_target(cy, target_cy, target_dist_threshold, inner_threshold)
    end

    def delta_from_move_towards_target(value, target_value, target_dist_threshold, inner_threshold)
      dist = target_value - value

      # TODO: this `- inner_threshold` is wrong, needs to be +/- range depending on direction
      if dist.abs > target_dist_threshold
        dist.sign
      elsif dist.abs < target_dist_threshold - inner_threshold
        -dist.sign
      else
        0
      end
    end

    def jump_to_tile(row, col)
      jump(col * TileSize, row * TileSize)
    end

    def collides?(movable : Movable)
      collides?(movable.collision_circle, movable.collision_cx, movable.collision_cy)
    end

    def collides?(radius, cx, cy)
      collision_circle.collides?(collision_cx, collision_cy, radius, cx, cy)
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
