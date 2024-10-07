require "../level"

module MiniMonsters::Levels
  class Maze1 < MiniMonsters::Level
    TileMapFile = "./assets/levels/maze_1.json"

    def tile_map_file
      TileMapFile
    end
  end
end
