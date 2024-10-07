module MiniMonsters
  class Font
    def self.default
      @@font_default ||= SF::Font.from_file("./assets/fonts/PressStart2P.ttf")
    end
  end
end
