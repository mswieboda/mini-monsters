require "json"
require "./tile_map"
require "./visibility"
require "./monster"
require "./rat"
require "./spider"
require "./oil_pool"

module MonsterMaze
  class Level
    getter player : Player
    getter rows : Int32
    getter cols : Int32
    getter tiles : Array(Array(Int32))
    getter monsters : Array(Monster)
    getter oil_pools : Array(OilPool)
    getter? exit

    @visibilities : Array(Array(Visibility))
    @tile_map : TileMap
    @tiles : Array(Array(Int32))
    @tiles_as_cells : Array(Array(GSF::Path::Tile))
    @collidable_tile_types : Array(Int32)
    @player_collidable_tiles : Array(TileData)
    @sound_buffer_oil_dip : SF::SoundBuffer
    @sound_oil_dip : SF::Sound
    @oil_fill_sprite : SF::Sprite
    @menu_items : GSF::MenuItems
    @spawn_tiles : Array(TileData)
    @finish_area : Box
    @finish_area_x : Int32
    @finish_area_y : Int32
    @game_win_timer : Timer
    @game_over_text : SF::Text
    @sound_buffer_footsteps : SF::SoundBuffer
    @sound_footsteps : SF::Sound
    @sound_buffer_thud : SF::SoundBuffer
    @sound_thud : SF::Sound

    VisibilitySize = 16
    VisibilitySizeFactor = TileSize // VisibilitySize
    EmptyString = ""
    TileSheetFile = "./assets/tiles/tiles.png"
    TileSheetDataFile = "./assets/tiles/tiles.json"
    OilFillSheetFile = "./assets/tiles/oil_fill.png"
    SoundOilDip = "./assets/sounds/oil_dip.ogg"
    SoundFootsteps = "./assets/sounds/footsteps.ogg"
    SoundThud = "./assets/sounds/thud.ogg"
    TextColorFocused = SF::Color.new(255, 127, 0)
    GameWinDuration = 500.milliseconds

    def initialize(@player : Player, @rows = 1, @cols = 1)
      @tile_map = TileMap.new
      @tiles = [] of Array(Int32)
      @tiles_as_cells = [] of Array(GSF::Path::Tile)
      @monsters = [] of Monster
      @visibilities = [] of Array(Visibility)
      @collidable_tile_types = [] of Int32
      @player_collidable_tiles = [] of TileData
      @oil_pools = [] of OilPool
      @sound_buffer_oil_dip = SF::SoundBuffer.new
      @sound_oil_dip = SF::Sound.new
      @sound_buffer_footsteps = SF::SoundBuffer.new
      @sound_footsteps = SF::Sound.new
      @sound_buffer_thud = SF::SoundBuffer.new
      @sound_thud = SF::Sound.new
      @oil_fill_sprite = SF::Sprite.new
      @exit = false
      @menu_items = GSF::MenuItems.new(
        font: Font.default,
        items: ["new game", "exit"],
        size: 32,
        text_color_focused:  TextColorFocused,
        initial_focused_index: 0
      )
      @spawn_tiles = [] of TileData
      @finish_area = Box.new
      @finish_area_x = 0
      @finish_area_y = 0
      @game_win_timer = Timer.new(GameWinDuration)
      @game_over_text = SF::Text.new("", Font.default, 48)
      @game_over_text.fill_color = TextColorFocused
    end

    def tile_size
      TileSize
    end

    def width
      tile_size * cols
    end

    def height
      tile_size * rows
    end

    def v_rows
      rows * VisibilitySizeFactor
    end

    def v_cols
      cols * VisibilitySizeFactor
    end

    def tile_map_file
      EmptyString
    end

    def tile_sheet_file
      TileSheetFile
    end

    def tile_sheet_data_file
      TileSheetDataFile
    end

    def game_over?
      player.dead? && player.death_timer.done?
    end

    def game_win?
      return false if player.dead?

      @finish_area.collides?(
        x: @finish_area_x,
        y: @finish_area_y,
        circle: player.collision_circle,
        cx: player.collision_cx,
        cy: player.collision_cy
      )
    end

    def init
      player.init

      init_tiles
      init_visibilities
      init_monsters
      init_sounds
      init_sprites

      update_visibility
    end

    def reset
      player.reset
      @menu_items = GSF::MenuItems.new(
        font: Font.default,
        items: ["new game", "exit"],
        size: 32,
        text_color_focused:  TextColorFocused,
        initial_focused_index: 0
      )
      @game_win_timer = Timer.new(GameWinDuration)
      @game_over_text = SF::Text.new("", Font.default, 48)
      @game_over_text.fill_color = TextColorFocused
    end

    def init_tiles
      return if tile_map_file.empty? || tile_sheet_file.empty?

      json = JSON.parse(File.open(tile_map_file))
      @rows = json["height"].as_i
      @cols = json["width"].as_i

      # tile data is 1-indexed not 0-indexed so subtract 1
      tiles = json["data"].as_a.map { |j| j.as_i - 1 }
      @tile_map = TileMap.new(tile_sheet_file, tile_size, tiles, rows, cols)
      @tiles = tiles.in_slices_of(cols)

      # player_start_row and player_start_row are 0-indexed
      player.jump_to_tile(json["player_start_row"].as_i, json["player_start_col"].as_i)

      return if tile_sheet_data_file.empty?

      json = JSON.parse(File.open(tile_sheet_data_file))

      # sets tiles that are collidable from tile_sheet_data_file json
      if raw_ranges = json.dig("collidables", "ranges")
        # this file is 0-indexed
        ranges = raw_ranges.as_a.map(&.as_a.map(&.as_i))

        ranges.each do |range|
          min, max = range

          @collidable_tile_types += (min..max).to_a
        end
      end

      # converts @tiles to Array((Array(GSF::Path::Tile))
      @tiles_as_cells = @tiles.map do |cols|
        cols.map do |tile|
          @collidable_tile_types.includes?(tile) ? GSF::Path::Tile::Collidable : GSF::Path::Tile::Empty
        end
      end

      # this file is 0-indexed from tile_sheet_data_file json
      oil_pool_tile = json["oil_pool_tile"].as_i
      init_oil_pools(oil_pool_tile)

      spawn_tile = json["spawn_tile"].as_i
      init_spawns(spawn_tile)

      finish_tile = json["finish_tile"].as_i
      init_finish_area(finish_tile)
    end

    def init_oil_pools(oil_pool_tile)
      @tiles.each_with_index do |cols, row|
        cols.each_with_index do |tile, col|
          @oil_pools << OilPool.new(row: row, col: col) if tile == oil_pool_tile
        end
      end
    end

    def init_spawns(spawn_tile)
      @tiles.each_with_index do |cols, row|
        cols.each_with_index do |tile, col|
          @spawn_tiles << {tile, row, col} if tile == spawn_tile
        end
      end

      @spawn_tiles.each do |_tile, row, col|
        spawn_monster(row, col)
      end
    end

    def init_finish_area(finish_tile)
      finish_tiles = [] of TileData

      @tiles.each_with_index do |cols, row|
        cols.each_with_index do |tile, col|
          finish_tiles << {tile, row, col} if tile == finish_tile
        end
      end

      min_row = finish_tiles.min_of { |_tile, row, _col| row }
      max_row = finish_tiles.max_of { |_tile, row, _col| row }
      min_col = finish_tiles.min_of { |_tile, _row, col| col }
      max_col = finish_tiles.max_of { |_tile, _row, col| col }

      rows = 1
      cols = 1

      if min_row == max_row
        cols = max_col - min_col
      elsif min_col == max_col
        rows = max_row - min_row
      else
        raise "error: finish tiles are not either one single row or one single column"
      end

      @finish_area = Box.new(width: cols * TileSize, height: rows * TileSize)
      @finish_area_x = min_col * TileSize
      @finish_area_y = min_row * TileSize
    end

    def init_visibilities
      visibilities_flat = Array(Visibility).new(size: v_rows * v_cols, value: Visibility::None)
      @visibilities = visibilities_flat.in_slices_of(v_cols)
    end

    def init_monsters
    end

    def init_sounds
      @sound_buffer_oil_dip = SF::SoundBuffer.from_file(SoundOilDip)
      @sound_oil_dip = SF::Sound.new(@sound_buffer_oil_dip)
      @sound_oil_dip.volume = 30

      @sound_buffer_footsteps = SF::SoundBuffer.from_file(SoundFootsteps)
      @sound_footsteps = SF::Sound.new(@sound_buffer_footsteps)
      @sound_footsteps.volume = 19

      @sound_buffer_thud = SF::SoundBuffer.from_file(SoundThud)
      @sound_thud = SF::Sound.new(@sound_buffer_thud)
    end

    def init_sprites
      texture = SF::Texture.from_file(OilFillSheetFile, SF::IntRect.new(0, 0, tile_size, tile_size))

      @oil_fill_sprite = SF::Sprite.new(texture)
    end

    def spawn_monster(row, col)
      monster_type = rand(5)

      case monster_type
      when 0, 1
        @monsters << Rat.new(row, col)
      else
        @monsters << Spider.new(row, col)
      end
    end

    def play_sound(sound : SF::Sound)
      sound.play unless sound.status == SF::SoundSource::Playing
    end

    def close_collidable_tiles(movable : Movable)
      tiles = [] of TileData

      size = movable.collision_radius * 2
      lx = movable.collision_cx - size
      ly = movable.collision_cy - size
      rx = movable.collision_cx + size
      ry = movable.collision_cy + size

      min_row = (ly // tile_size - 1).clamp(0, rows - 1).to_i
      min_col = (lx // tile_size - 1).clamp(0, cols - 1).to_i
      max_row = (ry // tile_size + 1).clamp(0, rows - 1).to_i
      max_col = (rx // tile_size + 1).clamp(0, cols - 1).to_i

      @tiles[min_row..max_row].each_with_index do |cols, row_index|
        row = min_row + row_index

        cols[min_col..max_col].each_with_index do |tile, col_index|
          col = min_col + col_index

          next unless @collidable_tile_types.includes?(tile)

          tiles << {tile, row, col}
        end
      end

      tiles
    end

    def close_collidable_movables(movable : Movable)
      @monsters.select do |monster|
        next false if movable == monster

        size = monster.size * 2

        next false if movable.cx < monster.cx - size
        next false if movable.cx > monster.cx + size
        next false if movable.cy < monster.cy - size
        next false if movable.cy > monster.cy + size

        true
      end
    end

    def close_oil_pools(movable : Movable)
      @oil_pools.select do |oil_pool|
        next false if oil_pool.empty?

        size = oil_pool.radius * 2

        next false if movable.cx < oil_pool.cx - size
        next false if movable.cx > oil_pool.cx + size
        next false if movable.cy < oil_pool.cy - size
        next false if movable.cy > oil_pool.cy + size

        true
      end
    end

    def update(frame_time, keys : Keys, joysticks : Joysticks)
      if game_over?
        update_game_over(frame_time, keys, joysticks)
        return
      end

      if game_win?
        @game_win_timer.start unless @game_win_timer.started?
        update_game_over(frame_time, keys, joysticks) if @game_win_timer.done?
        return
      end

      oil_pools = [] of OilPool

      if player.moved?
        @player_collidable_tiles = close_collidable_tiles(player)
        oil_pools = close_oil_pools(player)

        @monsters
          .select(&.follow_range?(player))
          .each(&.follow_player!(player, @tiles_as_cells))

        play_sound(@sound_footsteps)
      else
        @sound_footsteps.stop
      end

      player.update(frame_time, keys, joysticks, width, height, @player_collidable_tiles)

      oil_pools.each do |oil_pool|
        if player.collides?(oil_pool.radius, oil_pool.cx, oil_pool.cy)
          play_sound(@sound_oil_dip)
          oil_pool.dip!
          player.torch_refill!
        end
      end

      monsters.select(&.following?).each do |monster|
        tiles = close_collidable_tiles(monster)
        movables = close_collidable_movables(monster)

        if player.torch_out?
          monster.attack! if monster.ready_to_attack?
        else
          monster.stop_attacking!
        end

        monster.update_following(frame_time, player.cx, player.cy, player.monster_radius, tiles, movables)

        if monster.attacked?
          player.take_damage(monster.damage)

          play_sound(@sound_thud)
        end
      end

      update_visibility if player.moved?
    end

    def update_game_over(frame_time, keys, joysticks)
      @menu_items.update(frame_time, keys: keys, joysticks: joysticks)

      if @menu_items.selected?(keys, joysticks)
        case @menu_items.focused_label
        when "new game"
          # NOTE: this resets the current game (might have bugs?)
          reset
          init
        when "exit"
          @exit = true
        end
      elsif keys.just_pressed?(Keys::Escape) || joysticks.just_pressed?(Joysticks::Back)
        @exit = true
      end
    end

    def update_visibility
      # get all tiles within rectangle of player visibility radius
      pvx = player.torch_cx - player.visibility_radius
      pvy = player.torch_cy - player.visibility_radius
      size = player.visibility_radius * 2
      offset = 2 # extra offset b/c when player flips horz its a lot more tiles

      min_row = (pvy // tile_size - offset).clamp(0, rows - 1).to_i
      min_col = (pvx // tile_size - offset).clamp(0, cols - 1).to_i
      max_row = (((pvy + size) // tile_size) + offset).clamp(0, rows - 1).to_i
      max_col = (((pvx + size) // tile_size) + offset).clamp(0, cols - 1).to_i

      # check these tiles against player visibility circle
      (min_row..max_row).each do |row|
        (min_col..max_col).each do |col|
          reset_visibility(row, col)

          next unless player_visibility_collides?(col * tile_size, row * tile_size, tile_size)

          update_tile_visibility(row, col)
        end
      end
    end

    def reset_visibility(tile_row, tile_col)
      visibilities_from_tile(tile_row, tile_col).each do |visibility, row, col|
        next unless visibility.clear?
        @visibilities[row][col] = Visibility::Fog
      end
    end

    def visibilities_from_tile(tile_row, tile_col) : Array(VisibilityData)
      visibilities = [] of VisibilityData

      min_row = tile_row * VisibilitySizeFactor
      min_col = tile_col * VisibilitySizeFactor
      max_row = min_row + VisibilitySizeFactor
      max_col = min_col + VisibilitySizeFactor

      @visibilities[min_row...max_row].each_with_index do |cols, row_index|
        row = min_row + row_index

        cols[min_col...max_col].each_with_index do |visibility, col_index|
          col = min_col + col_index

          visibilities << {visibility, row, col}
        end
      end

      visibilities
    end

    def update_tile_visibility(tile_row, tile_col)
      size = VisibilitySize

      visibilities_from_tile(tile_row, tile_col).each do |visibility, row, col|
        if !visibility.clear? && player_visibility_collides?(col * size, row * size, size)
          @visibilities[row][col] = Visibility::Clear
        end
      end
    end

    def player_visibility_collides?(x, y, size)
      Box.new(size).collides?(x, y, player.visibility_radius, player.torch_cx, player.torch_cy)
    end

    def draw(window : SF::RenderWindow)
      window.draw(@tile_map)

      monsters.each(&.draw(window))

      oil_pools.each(&.draw(window, @oil_fill_sprite))

      player.draw(window)

      if Debug
        draw_collision_tiles(window)
        monsters.each { |monster| draw_monster_path(window, monster.path) }
        player.draw_monster_follow_radius(window)
      end

      draw_visibility(window)

      player.draw_torch_visibility(window)

      draw_game_over_menu(window) if game_over? || (game_win? && @game_win_timer.done?)
    end

    def draw_game_over_menu(window)
      width = Screen.width // 3
      height = Screen.height // 3

      # background
      bg = SF::RectangleShape.new({width, height})
      bg.origin = {width // 2, height // 2}
      bg.position = {player.cx, player.cy}
      bg.fill_color = SF::Color.new(255, 127, 0, 15)

      window.draw(bg)

      # title text
      @game_over_text.string = game_over? ? "Game Over!" : "You Won!"
      title_x = Screen.x + Screen.width // 2 - @game_over_text.global_bounds.width / 2
      @game_over_text.position = {title_x, Screen.y + Screen.height // 4}
      window.draw(@game_over_text)

      # menu items
      @menu_items.draw(window, Screen.x, Screen.y)
    end

    def draw_collision_tiles(window)
      rectangle = SF::RectangleShape.new({tile_size, tile_size})
      rectangle.fill_color = SF::Color::Transparent
      rectangle.outline_color = SF::Color::Cyan
      rectangle.outline_thickness = 2

      @player_collidable_tiles.each do |_tile, row, col|
        rectangle.position = {col * tile_size, row * tile_size}

        window.draw(rectangle)
      end
    end

    def draw_monster_path(window, path : GSF::Path::Cells)
      # circle
      radius = 4
      circle = SF::CircleShape.new(radius)
      circle.origin = {radius, radius}
      circle.fill_color = SF::Color::Transparent
      circle.outline_color = SF::Color::Magenta
      circle.outline_thickness = 2

      # line
      height = 4
      rectangle = SF::RectangleShape.new
      rectangle.origin = {0, height // 2}
      rectangle.fill_color = SF::Color::Transparent
      rectangle.outline_color = SF::Color::Magenta
      rectangle.outline_thickness = 2

      last_path_cell = nil

      path.each do |cell|
        cx = cell[:col] * TileSize + TileSize // 2
        cy = cell[:row] * TileSize + TileSize // 2

        circle.position = {cx, cy}
        window.draw(circle)

        if last_cell = last_path_cell
          last_cell_cx = last_cell[:col] * TileSize
          last_cell_cy = last_cell[:row] * TileSize
          width = MathHelpers.distance(cx, cy, last_cell_cx, last_cell_cy)

          rectangle.size = {width, height}
          rectangle.position = {cx, cy}
          # TODO: calc rotation
          # theta = 0
          # rectangle.rotation = theta

          # window.draw(rectangle)
        end

        last_path_cell = cell
      end
    end

    def draw_visibility(window)
      size = VisibilitySize
      min_row = (Screen.y // size).clamp(0, v_rows - 1).to_i
      min_col = (Screen.x // size).clamp(0, v_cols - 1).to_i
      max_row = (((Screen.y + Screen.height) // size) + 1).clamp(0, v_rows - 1).to_i
      max_col = (((Screen.x + Screen.width) // size) + 1).clamp(0, v_cols - 1).to_i

      @visibilities[min_row..max_row].each_with_index do |cols, row_index|
        row = min_row + row_index

        cols[min_col..max_col].each_with_index do |visibility, col_index|
          col = min_col + col_index

          visibility.draw(window, col * size, row * size, size, player.torch_left_percent)
        end
      end
    end
  end
end
