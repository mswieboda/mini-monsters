require "game_sf"

require "./mini_monsters/game"

module MiniMonsters
  alias Keys = GSF::Keys
  alias Mouse = GSF::Mouse
  alias Joysticks = GSF::Joysticks
  alias Screen = GSF::Screen
  alias Timer = GSF::Timer

  TileSize = 64
  Debug = false

  Game.new.run
end
