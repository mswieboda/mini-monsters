require "../level"

module MiniMonsters::Levels
  class One < MiniMonsters::Level
    TileSheet = "./assets/tiles/dungeon_base.png"

    def initialize(player)
      super(player, rows: 19, cols: 29)
    end

    def player_jump_to_start
      player.jump_to_tile(9, 9, tile_size)
    end

    def init_tiles
      tiles = Array(Int32).new(size: rows * cols, value: 0)
      @tile_map = TileMap.new(TileSheet, tile_size, tiles, rows, cols)
    end

    def init_monsters
      @monsters << Monster.new(5 * tile_size, 3 * tile_size)
      @monsters << Monster.new(7 * tile_size, 7 * tile_size)
      @monsters << Monster.new(1 * tile_size, 5 * tile_size)
    end
  end
end
