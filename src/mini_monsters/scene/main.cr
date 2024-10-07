require "../player"
require "../level"
require "../hud"

module MiniMonsters::Scene
  class Main < GSF::Scene
    property level : Level
    getter player : Player

    CenteredViewPadding = 128

    def initialize(@player : Player)
      super(:main)

      @level = Level.new(player)
      @hud = HUD.new
    end

    def init
      HUD.init
      level.init
      view_movement
    end

    def reset
      super

      level.reset
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape) || level.exit?
        @exit = true
        return
      end

      level.update(frame_time, keys, joysticks)
      view_movement if player.moved?

      HUD.update(frame_time)
    end

    def view_movement
      view = Screen.view

      cx = player.x + player.size / 2
      cy = player.y + player.size / 2

      # NOTE: this doesn't work for smaller level sizes
      #       but leaving in for now in case we can modify it to work
      # w = Screen.width / 2 - CenteredViewPadding
      # h = Screen.height / 2 - CenteredViewPadding
      # cx = w if cx < w
      # cy = h if cy < h
      # cx = level.width - w if cx > level.width - w
      # cy = level.height - h if cy > level.height - h

      view.center = {cx, cy}

      Screen.window.view = view
    end

    def draw(window)
      level.draw(window)
      HUD.draw(window)
    end
  end
end
