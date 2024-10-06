require "../level"

module MiniMonsters::Levels
  class Maze1 < MiniMonsters::Level
    TileMapFile = "./assets/levels/maze_1.json"

    def tile_map_file
      TileMapFile
    end

    def init_monsters
      @monsters << Monster.new(row: 86, col: 36)
    end
  end
end
