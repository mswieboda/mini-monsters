require "../levels/maze_1"
require "../levels/maze_2"

module MiniMonsters::Scene
  class Start < GSF::Scene
    getter start_scene : Symbol?
    getter items
    getter level_class

    TextColorFocused = SF::Color.new(255, 127, 0) # orange

    def initialize
      super(:start)

      @start_scene = nil
      @items = GSF::MenuItems.new(font: Font.default)
      @level_class = Level
    end

    def reset
      super
      items = [] of String

      items << "start maze 1"
      items << "start maze 2"

      items << "exit"

      @start_scene = nil
      @items = GSF::MenuItems.new(
        font: Font.default,
        items: items,
        size: 48,
        text_color_focused: TextColorFocused,
        initial_focused_index: 0
      )
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      items.update(frame_time, keys, mouse, joysticks)

      if items.selected?(keys, mouse, joysticks)
        case items.focused_label
        when "start maze 1"
          @level_class = Levels::Maze1
          @start_scene = :main
        when "start maze 2"
          @level_class = Levels::Maze2
          @start_scene = :main
        when "exit"
          @exit = true
        end
      elsif keys.just_pressed?(Keys::Escape) || joysticks.just_pressed?(Joysticks::Back)
        @exit = true
      end
    end

    def draw(window : SF::RenderWindow)
      items.draw(window)
    end
  end
end
