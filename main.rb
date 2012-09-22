require 'gosu'
require './game'
require './constants'
require './input_handler'

class GameWindow < Gosu::Window
  
  include InputHandler

  def initialize
    super 1280, 800, false
    self.caption = "The Editor"
    @game = Game.new
    @dialog_font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @mouse_img = Gosu::Image.new(self, "./media/mouse.png")
  end

  def update
    @game.tick
  end

  def draw
    set_background # because I like a nice white background better
    @mouse_img.draw(self.mouse_x, self.mouse_y, Constants::Z_POSITIONS[:mouse])
  end

  def set_background
    w = Gosu::Color::WHITE
    draw_quad(0, 0, w, 
              width, 0, w,
              width, height, w,
              0, height, w)
  end

end

win = GameWindow.new
win.show