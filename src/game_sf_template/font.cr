module GameSFTemplate
  class Font
    def self.default
      @@font_default ||= SF::Font.from_file("./assets/PressStart2P.ttf")
    end
  end
end
