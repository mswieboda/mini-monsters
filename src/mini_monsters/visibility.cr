module MiniMonsters
  enum Visibility : UInt8
    None
    Fog
    Clear

    def color
      case self
      when .none?
        SF::Color.new(0, 0, 0)
      when .fog?
        SF::Color.new(0, 0, 0, 159)
      when .clear?
        SF::Color::Transparent
      else
        SF::Color::Magenta
      end
    end

    def draw(window, x, y, size)
      rect = SF::RectangleShape.new({size, size})
      rect.fill_color = color
      rect.position = {x, y}

      window.draw(rect)
    end
  end
end
