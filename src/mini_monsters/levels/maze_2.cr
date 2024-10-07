require "../level"

module MiniMonsters::Levels
  class Maze2 < MiniMonsters::Level
    TileMapFile = "./assets/levels/maze_2.json"

    def tile_map_file
      TileMapFile
    end
  end
end
