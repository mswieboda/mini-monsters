require "../player"
require "../level"

module MonsterMaze::Scene
  class Main < GSF::Scene
    property level : Level
    getter player : Player

    CenteredViewPadding = 128

    def initialize(@player : Player)
      super(:main)

      @level = Level.new(player)
    end

    def init
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
    end

    def view_movement
      view = Screen.view

      cx = player.x + player.size / 2
      cy = player.y + player.size / 2

      # NOTE: this doesn't work for smaller level sizes
      #       but leaving in for now in case we can modify it to work
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
    end
  end
end
