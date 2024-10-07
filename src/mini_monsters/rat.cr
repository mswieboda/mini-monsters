require "./monster"

module MiniMonsters
  class Rat < Monster
    SpriteSheet = "./assets/sprites/rat.png"
    AnimationFrames = 3
    Speed = 384

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
