module MiniMonsters
  class OilPool
    getter cx : Int32
    getter cy : Int32

    MaxOilAlpha = 255
    EmptyThreshold = 0.75
    ActionRadius = 72
    ActiveRefreshTime = 10.seconds # filled at EmptyThreshold %, so 7.5 sec)

    def initialize(row, col)
      @cx = col * TileSize + TileSize // 2
      @cy = row * TileSize + TileSize // 2
      @refilling = false
      @refill_timer = Timer.new(ActiveRefreshTime, true)
    end

    def radius
      ActionRadius
    end

    def empty?
      @refill_timer.percent < EmptyThreshold
    end

    def dip!
      @refill_timer.start
    end

    def draw(window : SF::RenderWindow, fill_sprite : SF::Sprite)
      draw_refilling(window, fill_sprite)

      draw_action_circle(window) if Debug
    end

    def draw_refilling(window, fill_sprite)
      alpha = empty? ? 0 : MaxOilAlpha * (@refill_timer.percent).clamp(0, 1)

      fill_sprite.color = SF::Color.new(255, 255, 255, alpha.to_i)
      fill_sprite.origin = {TileSize // 2, TileSize // 2}
      fill_sprite.position = {cx, cy}

      window.draw(fill_sprite)
    end

    def draw_action_circle(window)
      circle = SF::CircleShape.new(radius)
      circle.origin = {radius, radius}
      circle.position = {cx, cy}
      circle.fill_color = SF::Color.new(255, 0, 255, 63)

      window.draw(circle)
    end
  end
end
