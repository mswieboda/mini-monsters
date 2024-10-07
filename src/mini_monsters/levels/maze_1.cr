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
      @monsters << Rat.new(row: 86, col: 36)
      @monsters << Spider.new(row: 83, col: 33)
      @monsters << Rat.new(row: 81, col: 31)
      @monsters << Spider.new(row: 79, col: 30)
      @monsters << Rat.new(row: 86, col: 38)
      @monsters << Spider.new(row: 86, col: 33)
      @monsters << Rat.new(row: 86, col: 31)
    end
  end
end
