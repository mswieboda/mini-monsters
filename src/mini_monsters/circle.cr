require "./math_helpers"

module MiniMonsters
  struct Circle
    property radius : Int32

    def initialize(@radius)
    end

    # with other Circle (other.radius, other_cx, other_cy)
    def collides?(cx, cy, other : Circle, other_cx, other_cy)
      MathHelpers.distance(cx, cy, other_cx, other_cy) <= radius + other.radius
    end

    # with Box (box.size, x, y)
    def collides?(cx, cy, box : Box, x, y)
      box.collides?(x, y, self, cx, cy)
    end

    def draw(window : SF::RenderWindow, cx, cy)
      circle = SF::CircleShape.new(radius)
      circle.origin = {radius, radius}
      circle.position = {cx, cy}
      circle.fill_color = SF::Color::Transparent
      circle.outline_color = SF::Color::Magenta
      circle.outline_thickness = 2

      window.draw(circle)
    end
  end
end
