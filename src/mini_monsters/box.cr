module MiniMonsters
  struct Box
    property size : Int32

    def initialize(@size)
    end

    def collides?(x, y, other : Box, other_x, other_y)
      # calc right and bottom edges (note x, y are centered)
      right = x + size
      other_right = other_x + other.size
      bottom = y + size
      other_bottom = other_y + other.size

      # calc left and top edges (note x, y are centered)
      left = x - size
      other_left = other_x - size
      top = y - size
      other_top = other_y - size

      # check if boxes overlap on both axes
      (left < other_right && right >= other_left) &&
        (top < other_bottom && bottom >= other_top)
    end

    def draw(window : SF::RenderWindow, x, y)
      rectangle = SF::RectangleShape.new({size, size})
      rectangle.position = {x, y}
      rectangle.fill_color = SF::Color::Transparent
      rectangle.outline_color = SF::Color::Magenta
      rectangle.outline_thickness = 2

      window.draw(rectangle)
    end
  end
end
