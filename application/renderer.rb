class Renderer
  def initialize(window)
    @window = window
    @dialog_font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
    @mouse_img = Gosu::Image.new(@window, "./media/mouse.png")
  end

  def paint(game)
    set_background

    @mouse_img.draw(@window.mouse_x, @window.mouse_y, Constants::Z_POSITIONS[:mouse])

    if @s
      @dialog_font.draw(@s, 0, 0, 0, 1, 1, Gosu::Color::BLACK)
    end
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