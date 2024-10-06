require "./movable"

module MiniMonsters
  class Monster < Movable
    getter sprite : SF::Sprite
    getter? following

    SpriteSheet = "./assets/sprites/mouse.png"

    def initialize(row = 0, col = 0)
      texture = SF::Texture.from_file(SpriteSheet, SF::IntRect.new(0, 0, size, size))
      @sprite = SF::Sprite.new(texture)

      super

      @following = false
    end

    def follow_range?(player : Player)
      # more efficient guards before doing box/circle collision detection
      return false if following?
      return false if x + size < player.torch_cx - player.monster_follow_radius - player.size * 2
      return false if x > player.torch_cx + player.monster_follow_radius + player.size * 2
      return false if y + size < player.torch_cy - player.monster_follow_radius - player.size * 2
      return false if y > player.torch_cy + player.monster_follow_radius + player.size * 2

      collision_box.collides?(x, y, player.torch_cx, player.torch_cy, player.monster_follow_radius)
    end

    def follow_player!
      @following = true
    end

    def update_following(frame_time, p_cx, p_cy, p_dist) #, collidable_tiles)
      move_towards(p_cx, p_cy, p_dist)
      update_movement(frame_time) #, collidable_tiles)
    end

    def move_towards(p_cx, p_cy, p_dist)
      dist_x = p_cx - cx
      dist_y = p_cy - cy

      if dist_x.abs > p_dist
        @dx = dist_x.sign
      else
        @dx = 0
      end

      if dist_y.abs > p_dist
        @dy = dist_y.sign
      else
        @dy = 0
      end
    end

    def jump(x, y)
      super

      @sprite.position = {x, y}
    end

    def draw(window : SF::RenderWindow)
      window.draw(sprite)

      return unless Debug

      collision_box.draw(window, x, y)
    end
  end
end
