require "../level"

module MiniMonsters::Levels
  class One < MiniMonsters::Level
    TileMapFile = "./assets/levels/one.json"
    TileSheet = "./assets/tiles.png"

    def tile_map_file
      TileMapFile
    end

    def tile_sheet_file
      TileSheet
    end

    def init_monsters
      @monsters << Monster.new(5 * tile_size, 3 * tile_size)
      @monsters << Monster.new(7 * tile_size, 7 * tile_size)
      @monsters << Monster.new(1 * tile_size, 5 * tile_size)
    end
  end
end
