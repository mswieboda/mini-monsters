require "../level"
require "../rat"

module MiniMonsters::Levels
  class Maze2 < MiniMonsters::Level
    TileMapFile = "./assets/levels/maze_2.json"

    def tile_map_file
      TileMapFile
    end

    def init_monsters
      @monsters << Rat.new(row: 86, col: 36)
      @monsters << Rat.new(row: 83, col: 33)
      @monsters << Rat.new(row: 81, col: 31)
      @monsters << Rat.new(row: 79, col: 30)
      @monsters << Rat.new(row: 86, col: 38)
      @monsters << Rat.new(row: 86, col: 33)
      @monsters << Rat.new(row: 86, col: 31)
    end
  end
end
