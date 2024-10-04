require "../player"
require "../hud"

module GameSFTemplate::Scene
  class Main < GSF::Scene
    getter hud
    getter player

    def initialize
      super(:main)

      @player = Player.new(x: 300, y: 300)
      @hud = HUD.new
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      player.update(frame_time, keys)
      hud.update(frame_time)
    end

    def draw(window)
      player.draw(window)
      hud.draw(window)
    end
  end
end
