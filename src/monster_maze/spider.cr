require "./monster"

module MonsterMaze
  class Spider < Monster
    SpriteSheet = "./assets/sprites/spider.png"
    AnimationFrames = 4
    Speed = 448

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
