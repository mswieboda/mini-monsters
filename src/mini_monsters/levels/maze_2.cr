require "../level"
require "../rat"
require "../spider"

module MiniMonsters::Levels
  class Maze2 < MiniMonsters::Level
    TileMapFile = "./assets/levels/maze_2.json"

    def tile_map_file
      TileMapFile
    end

    def init_monsters
      @monsters << Rat.new(row: 76, col: 36)
      @monsters << Spider.new(row: 73, col: 33)
      @monsters << Rat.new(row: 71, col: 31)
      @monsters << Spider.new(row: 779, col: 30)
      @monsters << Rat.new(row: 76, col: 38)
      @monsters << Spider.new(row: 76, col: 33)
      @monsters << Rat.new(row: 76, col: 31)
    end
  end
end
