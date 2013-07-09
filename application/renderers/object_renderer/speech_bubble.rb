class SpeechBubble < ObjectRenderer::Base
  def draw(obj)
    x = translate_x(obj.get_attribute(:x))
    y = translate_y(obj.get_attribute(:y))
    b = Gosu::Color::BLACK
    # window.draw_quad(x, y, b,
    #                  x + 20, y, b,
    #                  x + 20, y + 20, b,
    #                  x, y + 20, b
    #                 )
  end
end