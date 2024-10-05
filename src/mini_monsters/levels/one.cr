require "../level"

module MiniMonsters::Levels
  class One < MiniMonsters::Level
    @tile_rect : SF::RectangleShape

    TileColor = SF::Color.new(63, 63, 63)
    TileOutlineColor = SF::Color.new(15, 15, 15, 63)

    def initialize(player)
      super(player, rows: 19, cols: 29)

      @tile_rect = SF::RectangleShape.new({tile_size, tile_size})
      @tile_rect.fill_color = TileColor
      @tile_rect.outline_color = TileOutlineColor
      @tile_rect.outline_thickness = -1
    end

    def player_jump_to_start
      player.jump_to_tile(9, 9, tile_size)
    end
  end
end
