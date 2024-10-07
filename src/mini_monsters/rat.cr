require "./monster"

module MiniMonsters
  class Rat < Monster
    getter sprite : SF::Sprite

    SpriteSheet = "./assets/sprites/rat.png"

    def initialize(row = 0, col = 0)
      texture = SF::Texture.from_file(SpriteSheet, SF::IntRect.new(0, 0, size, size))
      @sprite = SF::Sprite.new(texture)

      super

      @following = false
    end

    def jump(x, y)
      super

      @sprite.position = {x, y}
    end

    def draw(window : SF::RenderWindow)
      window.draw(sprite)

      return unless Debug

      collision_circle.draw(window, collision_cx, collision_cy)
    end
  end
end
