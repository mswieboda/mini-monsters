require "../level"

module MonsterMaze::Levels
  class Maze1 < MonsterMaze::Level
    TileMapFile = "./assets/levels/maze_1.json"

    def tile_map_file
      TileMapFile
    end
  end
end
