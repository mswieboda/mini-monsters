require "game_sf"

require "./game_sf_template/game"

module GameSFTemplate
  alias Keys = GSF::Keys
  alias Mouse = GSF::Mouse
  alias Joysticks = GSF::Joysticks
  alias Screen = GSF::Screen
  alias Timer = GSF::Timer

  Game.new.run
end
