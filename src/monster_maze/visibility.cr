module MonsterMaze
  FogAlpha = 191
  ColorFog = SF::Color.new(0, 0, 0, FogAlpha)

  enum Visibility : UInt8
    None
    Fog
    Clear

    def color
      case self
      when .none?
        SF::Color::Black
      when .fog?
        ColorFog
      when .clear?
        SF::Color::Transparent
      else
        SF::Color::Magenta
      end
    end

    def explored?
      fog? || clear?
    end

    def draw(window, x, y, size, torch_left_percent)
      rect = SF::RectangleShape.new({size, size})
      rect.position = {x, y}

      if clear?
        adj_color = color.dup
        adj_color.a = FogAlpha - (torch_left_percent * (FogAlpha - adj_color.a)).to_i
        rect.fill_color = adj_color
      else
        rect.fill_color = color
      end

      window.draw(rect)
    end
  end
end
