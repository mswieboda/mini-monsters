require "game_sf"

require "./mini_monsters/game"

module MiniMonsters
  alias Keys = GSF::Keys
  alias Mouse = GSF::Mouse
  alias Joysticks = GSF::Joysticks
  alias Screen = GSF::Screen
  alias Timer = GSF::Timer

  alias TileData = Tuple(Int32, Int32, Int32) # tile_type, row, col
  alias Tiles = Array(TileData)
  alias VisibilityData = Tuple(Visibility, Int32, Int32) # v, row, col

  TileSize = 64
  Debug = true

  Game.new.run
end
