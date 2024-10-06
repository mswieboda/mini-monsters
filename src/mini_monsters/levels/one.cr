require "../level"

module MiniMonsters::Levels
  class One < MiniMonsters::Level
    TileMapFile = "./assets/levels/one.json"

    def tile_map_file
      TileMapFile
    end

    def init_monsters
      @monsters << Monster.new(5 * tile_size, 3 * tile_size)
      @monsters << Monster.new(7 * tile_size, 7 * tile_size)
      @monsters << Monster.new(1 * tile_size, 5 * tile_size)
    end
  end
end
