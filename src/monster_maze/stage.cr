require "./font"
require "./scene/start"
require "./scene/main"

module MonsterMaze
  class Stage < GSF::Stage
    getter player : Player
    getter start
    getter main

    def initialize
      super

      @player = Player.new

      @start = Scene::Start.new
      @main = Scene::Main.new(player)

      @scene = start
      @scene.reset
    end

    def check_scenes
      case scene.name
      when :start
        if scene.exit?
          @exit = true
        elsif start_scene = start.start_scene
          @main.level = start.level_class.new(player)

          switch(main) if start_scene == :main
        end
      when :main
        switch(start) if scene.exit?
      end
    end
  end
end
