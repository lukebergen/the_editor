require 'json'

class Renderer

  attr_accessor :media_manager

  def initialize(window)
    @window = window
    @media_manager = MediaManager.new(@window)
    @dialog_font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
    @mouse_img = Gosu::Image.new(@window, "#{APPLICATION_DIR}/media/system/mouse.png")
  end

  def paint(game)
    set_background

    #@mouse_img.draw(@window.mouse_x, @window.mouse_y, Constants::Z_POSITIONS[:mouse])

    render_map(game.current_map)

    game.objects.each do |go|
      if (go.has_module('Displayable'))
        x = go.attributes[:x]
        y = go.attributes[:y]
        z = go.attributes[:z]
        height = go.attributes[:height]
        width = go.attributes[:width]
        img_src = go.attributes[:current_image]
        if (img_src.include?(':'))
          split = img_src.split(':')
          current_image = @media_manager.animations[split[0]].current_image(split[1])
        else
          current_image = @media_manager.images[go.attributes[:current_image]]
        end
        if (x && y && current_image)
          fx = fy = 1
          z ||= Constants::Z_POSITIONS[:default_game_object]
          if (height || width)
            fx, fy = stretch_factor(current_image, height, width)
          end
          current_image.draw(x, y, z, fx, fy)
        end
      end
    end

    if @s
      @dialog_font.draw(@s, 0, 0, 0, 1, 1, Gosu::Color::BLACK)
    end
  end

  def tick
    @media_manager.animations.values.each do |ani|
      ani.tick
    end
  end

  def render_map(map_name)
    map = media_manager.maps[map_name]
    tileset = media_manager.tilesets[map.tileset]
    mul = tileset.tile_size
    map.tiles.each_with_index do |row_arr, row|
      row_arr.each_with_index do |tile_data, col|
        # first paint the bottom tile
        img = tileset.tiles[tile_data[0]][tile_data[1]]
        img.draw(col * mul, row * mul, Constants::Z_POSITIONS[:top_tile])
        
        # then paint the top tile
        img = tileset.tiles[tile_data[2]][tile_data[3]]
        img.draw(col * mul, row * mul, Constants::Z_POSITIONS[:bottom_tile])

        # figure out blocking later
      end
    end
  end

  def stretch_factor(image, stretch_to_height, stretch_to_width)
    x = y = 1
    if (stretch_to_height)
      y = stretch_to_height / image.height.to_f
    end
    if (stretch_to_width)
      x = stretch_to_width / image.width.to_f
    end
    return x, y
  end

  def draw_text(text)
    @s = text
  end

  def set_background
    w = Gosu::Color::WHITE
    @window.draw_quad(0, 0, w, 
                      @window.width, 0, w,
                      @window.width, @window.height, w,
                      0, @window.height, w)
  end

end