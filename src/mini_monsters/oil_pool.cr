module MiniMonsters
  struct OilPool
    getter cx : Int32
    getter cy : Int32

    ActionRadius = 96

    def initialize(row, col)
      @cx = col * TileSize + TileSize // 2
      @cy = row * TileSize + TileSize // 2
    end

    def radius
      ActionRadius
    end

    def draw(window : SF::RenderWindow)
      draw_action_circle(window)
    end

    def draw_action_circle(window)
      circle = SF::CircleShape.new(radius)
      circle.origin = {radius, radius}
      circle.position = {cx, cy}
      circle.fill_color = SF::Color.new(255, 0, 255, 128)

      window.draw(circle)
    end
  end
end
