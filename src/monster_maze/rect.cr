require "./math_helpers"

module MonsterMaze
  struct Rect
    property width : Int32
    property height : Int32

    def initialize(@width = 1, @height = 1)
    end

    # Rect (width, height, x, y) with Circle (radius, cx, cy)
    def self.collides?(width, height, x, y, radius, cx, cy)
      # temporary variables to set edges for testing
      test_x = cx
      test_y = cy

      # which edge is closest?
      if cx < x
        # test left edge
        test_x = x
      elsif cx > x + width
        # right edge
        test_x = x + width
      end

      if cy < y
        # top edge
        test_y = y
      elsif cy > y + height
        # bottom edge
        test_y = y + height
      end

      # get distance from closest edges
      # if distance is less than radius, it collides
      MathHelpers.distance(test_x, test_y, cx, cy) <= radius
    end

    # with circle (cx, cy, radius)
    def collides?(x, y, circle : Circle, cx, cy)
      self.class.collides?(width, height, x, y, circle.radius, cx, cy)
    end

    def draw(window : SF::RenderWindow, x, y)
      rectangle = SF::RectangleShape.new({width, height})
      rectangle.position = {x, y}
      rectangle.fill_color = SF::Color::Transparent
      rectangle.outline_color = SF::Color::Magenta
      rectangle.outline_thickness = 2

      window.draw(rectangle)
    end
  end
end
