module MiniMonsters
  class Monster
    getter x : Int32 | Float32
    getter y : Int32 | Float32
    getter sprite : SF::Sprite

    Size = 64
    Sheet = "./assets/sprites/mouse.png"

    def initialize(@x = 0, @y = 0)
      texture = SF::Texture.from_file(Sheet, SF::IntRect.new(0, 0, size, size))

      @sprite = SF::Sprite.new(texture)
      @sprite.position = {x, y}
    end

    def size
      Size
    end

    def jump(x, y)
      @x = x
      @y = y

      @sprite.position = {x, y}
    end

    def jump_to_tile(col, row, tile_size)
      jump(col * tile_size, row * tile_size)
    end

    def draw(window : SF::RenderWindow)
      window.draw(sprite)
    end
  end
end
