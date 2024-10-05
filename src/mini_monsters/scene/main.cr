require "../player"
require "../levels/one"
require "../hud"

module MiniMonsters::Scene
  class Main < GSF::Scene
    getter player : Player
    getter level : Level

    CenteredViewPadding = 128

    def initialize
      super(:main)

      @player = Player.new
      @level = Levels::One.new(player)
      @hud = HUD.new
    end

    def init
      HUD.init
      level.start
      # view_movement
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      level.update(frame_time, keys, joysticks)
      # view_movement if player.moved?

      HUD.update(frame_time)
    end

    def view_movement
      view = Screen.view

      cx = player.x
      cy = player.y
      w = Screen.width / 2 - CenteredViewPadding
      h = Screen.height / 2 - CenteredViewPadding

      cx = w if cx < w
      cy = h if cy < h

      cx = level.width - w if cx > level.width - w
      cy = level.height - h if cy > level.height - h

      view.center = {cx, cy}

      Screen.window.view = view
    end

    def draw(window)
      level.draw(window)
      HUD.draw(window)
    end
  end
end
