require "./movable"

module MiniMonsters
  class Monster < Movable
    getter? following

    CollisionRadius = 24
    Speed = 416

    def initialize(row = 0, col = 0)
      super

      @following = false
    end

    def speed
      Speed
    end

    def collision_radius
      CollisionRadius
    end

    def follow_range?(player : Player)
      # more efficient guards before doing box/circle collision detection
      return false if following?
      return false if cx < player.torch_cx - player.monster_follow_radius - player.size * 2
      return false if cx > player.torch_cx + player.monster_follow_radius + player.size * 2
      return false if cy < player.torch_cy - player.monster_follow_radius - player.size * 2
      return false if cy > player.torch_cy + player.monster_follow_radius + player.size * 2

      collides?(Circle.new(player.monster_follow_radius), player.torch_cx, player.torch_cy)
    end

    def follow_player!
      @following = true
    end

    def update_following(frame_time, p_cx, p_cy, p_dist, collidable_tiles, movables)
      move_towards(p_cx, p_cy, p_dist)

      return if dx == 0 && dy == 0

      update_movement(frame_time, collidable_tiles: collidable_tiles, movables: movables)
    end

    def move_towards(p_cx, p_cy, p_dist)
      @dx = move_change_from_distance(p_cx, cx, p_dist, size)
      @dy = move_change_from_distance(p_cy, cy, p_dist, size)
    end

    def move_change_from_distance(p_value, value, p_dist, inner_threshold)
      dist = p_value - value
      dist.abs > p_dist ? dist.sign : dist.abs < p_dist - inner_threshold ? -dist.sign : 0
    end

    def draw(window : SF::RenderWindow)
    end
  end
end
