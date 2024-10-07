require "../level"

module MonsterMaze::Levels
  class Maze2 < MonsterMaze::Level
    TileMapFile = "./assets/levels/maze_2.json"

    def tile_map_file
      TileMapFile
    end
  end
end
