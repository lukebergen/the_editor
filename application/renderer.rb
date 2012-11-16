class Renderer
  def initialize(window)
    @window = window
    @media_manager = MediaManager.new(@window)
    @dialog_font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
    @mouse_img = Gosu::Image.new(@window, "#{APPLICATION_DIR}/media/system/mouse.png")
  end

  def paint(game)
    set_background

    @mouse_img.draw(@window.mouse_x, @window.mouse_y, Constants::Z_POSITIONS[:mouse])

    game.objects.each do |go|
      if (go.has_module('Displayable'))
        x = go.attributes[:x]
        y = go.attributes[:y]
        z = go.attributes[:z]
        height = go.attributes[:height]
        width = go.attributes[:width]
        current_image = @media_manager.images[go.attributes[:current_image]]
        if (x && y && current_image)
          fx = fy = 1
          z ||= 0
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