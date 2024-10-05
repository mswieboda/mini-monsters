require "../level"

module MiniMonsters::Levels
  class One < MiniMonsters::Level
    TileSpriteFile = "./assets/tiles/dungeon_base.png"

    def initialize(player)
      super(player, rows: 19, cols: 29)

      texture = SF::Texture.from_file(TileSpriteFile, SF::IntRect.new(0, 0, tile_size, tile_size))

      @tile_sprite = SF::Sprite.new(texture)
    end

    def player_jump_to_start
      player.jump_to_tile(9, 9, tile_size)
    end

    def init_monsters
      @monsters << Monster.new(5 * tile_size, 3 * tile_size)
      @monsters << Monster.new(7 * tile_size, 7 * tile_size)
      @monsters << Monster.new(1 * tile_size, 5 * tile_size)
    end
  end
end
