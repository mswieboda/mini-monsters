require "./visibility"

module MiniMonsters
  class Tile
    property visibility : Visibility
    property? explored

    TileSize = 64 # should share with Level

    def initialize(@visibility = Visibility::None)
      @explored = false
    end

    def self.size
      TileSize
    end

    def size
      TileSize
    end

    def reset_visibility
      @visibility = Visibility::None
    end

    def explore
      @explored = true
      @visibility = Visibility::Clear
    end

    def collision_with_circle?(row, col, cx, cy, radius)
      x = col * size
      y = row * size

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
      dist_x = cx - test_x
      dist_y = cy - test_y

      # if distance is less than radius, it collides
      Math.sqrt(dist_x ** 2 + dist_y ** 2) <= radius
    end

    def draw(window, col, row, sprite)
      sprite.position = {col * size, row * size}

      window.draw(sprite)
    end

    def draw_visibility(window, col, row)
      visibility = @visibility.none? && explored? ? Visibility::Fog : @visibility
      visibility.draw(window, col * size, row * size, size)
    end
  end
end
