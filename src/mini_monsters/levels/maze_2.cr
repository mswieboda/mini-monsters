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
      @monsters << Rat.new(row: 6, col: 6)
      @monsters << Spider.new(row: 3, col: 3)
      @monsters << Rat.new(row: 1, col: 1)
      @monsters << Spider.new(row: 79, col: 0)
      @monsters << Rat.new(row: 6, col: 8)
      @monsters << Spider.new(row: 6, col: 3)
      @monsters << Rat.new(row: 6, col: 1)
    end
  end
end
