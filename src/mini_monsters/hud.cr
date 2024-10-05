require "./font"

module MiniMonsters
  class HUD
    @@action_text = SF::Text.new("", Font.default, 24)

    Margin = 4
    TextColor = SF::Color::White

    def self.init
      @@action_text.fill_color = TextColor
      @@action_text.position = {Margin, Margin}
    end

    def self.clear_action
      @@action_text.string = ""
    end

    def self.action=(action : String)
      @@action_text.string = "action: #{action}"
    end

    def self.update(frame_time)
      clear_action

      @@action_text.position = {Screen.x + Margin, Screen.y + Margin}
    end

    def self.draw(window : SF::RenderWindow)
      window.draw(@@action_text)
    end
  end
end
