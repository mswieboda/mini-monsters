require "./stage"

module GameSFTemplate
  class Game < GSF::Game
    getter manager

    def initialize
      mode = SF::VideoMode.desktop_mode
      style = SF::Style::None

      {% if flag?(:linux) %}
        mode.width -= 50
        mode.height -= 100

        style = SF::Style::Default
      {% end %}

      super(title: "Game SF Template", mode: mode, style: style)

      @stage = Stage.new
    end
  end
end
