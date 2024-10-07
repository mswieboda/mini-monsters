require "./monster"

module MiniMonsters
  class Spider < Monster
    SpriteSheet = "./assets/sprites/spider.png"
    AnimationFrames = 4
    Speed = 416

    def sprite_sheet
      SpriteSheet
    end

    def animation_frames
      AnimationFrames
    end

    def speed
      Speed
    end
  end
end
