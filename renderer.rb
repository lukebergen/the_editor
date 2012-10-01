class Renderer
  def initialize(window)
    @window = window
    @dialog_font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
    @mouse_img = Gosu::Image.new(@window, "./media/mouse.png")
  end

  def paint(game)
    set_background

    @mouse_img.draw(@window.mouse_x, @window.mouse_y, Constants::Z_POSITIONS[:mouse])
  end

  def set_background
    w = Gosu::Color::WHITE
    @window.draw_quad(0, 0, w, 
                      @window.width, 0, w,
                      @window.width, @window.height, w,
                      0, @window.height, w)
  end

end