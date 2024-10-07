require "../level"
require "../rat"
require "../spider"

module MiniMonsters::Levels
  class Maze1 < MiniMonsters::Level
    TileMapFile = "./assets/levels/maze_1.json"

    def tile_map_file
      TileMapFile
    end

    def init_monsters
      @monsters << Rat.new(row: 106, col: 46)
      @monsters << Spider.new(row: 103, col: 43)
      @monsters << Rat.new(row: 101, col: 41)
      @monsters << Spider.new(row: 79, col: 40)
      @monsters << Rat.new(row: 106, col: 48)
      @monsters << Spider.new(row: 106, col: 43)
      @monsters << Rat.new(row: 106, col: 41)
    end
  end
end
