require "./visibility"

module MiniMonsters
  class Tile
    alias Visibilities = Hash(Int32, Hash(Int32, Visibility))
    property visibilities : Visibilities
    property? explored

    TileSize = 64 # should share with Level
    VisibilityFactor = 4
    VisibilitySize = TileSize // VisibilityFactor

    def initialize
      @explored = false
      @visibilities = Visibilities.new

      VisibilityFactor.times do |row|
        @visibilities[row] = Hash(Int32, Visibility).new

        VisibilityFactor.times do |col|
          @visibilities[row][col] = Visibility::None
        end
      end
    end

    def self.size
      TileSize
    end

    def size
      TileSize
    end

    def reset_visibility
      @visibilities.each do |row, visibilities|
        visibilities.each do |col, visibility|
          next unless visibility.clear?

          @visibilities[row][col] = Visibility::Fog
        end
      end
    end

    def update_visibility(x, y, player)
      @visibilities.each do |row, visibilities|
        visibilities.each do |col, _visibility|
          vx = x + col * VisibilitySize
          vy = y + row * VisibilitySize

          if collision_with_circle?(vx, vy, VisibilitySize, player.torch_cx, player.torch_cy, player.visibility_radius)
            @visibilities[row][col] = Visibility::Clear
          end
        end
      end
    end

    def collision_with_circle?(x, y, size, cx, cy, radius)
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

    def draw(window, row, col, sprite)
      sprite.position = {col * size, row * size}

      window.draw(sprite)
    end

    def draw_visibility(window, row, col, torch_left_percent)
      x = col * size
      y = row * size

      @visibilities.each do |vrow, visibilities|
        visibilities.each do |vcol, visibility|
          visibility.draw(window, x + vcol * VisibilitySize, y + vrow * VisibilitySize, VisibilitySize, torch_left_percent)
        end
      end
    end
  end
end
