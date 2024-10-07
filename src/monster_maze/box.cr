require "./math_helpers"

module MonsterMaze
  struct Box
    property size : Int32

    def initialize(@size = 1)
    end

    # Box (size, x, y) with Circle (radius, cx, cy)
    def self.collides?(size, x, y, radius, cx, cy)
      # temporary variables to set edges for testing
      test_x = cx
      test_y = cy

      # which edge is closest?
      if cx < x
        # test left edge
        test_x = x
      elsif cx > x + size
        # right edge
        test_x = x + size
      end

      if cy < y
        # top edge
        test_y = y
      elsif cy > y + size
        # bottom edge
        test_y = y + size
      end

      # get distance from closest edges
      # if distance is less than radius, it collides
      MathHelpers.distance(test_x, test_y, cx, cy) <= radius
    end

    # with other Box
    def collides?(x, y, other : Box, other_x, other_y)
      # calc right and bottom edges (note x, y are centered)
      right = x + size
      other_right = other_x + other.size
      bottom = y + size
      other_bottom = other_y + other.size

      # calc left and top edges (note x, y are centered)
      left = x
      other_left = other_x
      top = y
      other_top = other_y

      # check if boxes overlap on both axes
      (left < other_right && right >= other_left) &&
        (top < other_bottom && bottom >= other_top)
    end

    # with circle (cx, cy, radius)
    def collides?(x, y, circle : Circle, cx, cy)
      self.class.collides?(size, x, y, circle.radius, cx, cy)
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
