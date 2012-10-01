require 'gosu'
require './game'
require './constants'
require './input_handler'
require './renderer'

class GameWindow < Gosu::Window
  
  include InputHandler

  def initialize
    super 1280, 800, false
    self.caption = "The Editor"
    @game = Game.new
    @renderer = Renderer.new(self)
  end

  def update
    @game.tick
  end

  def draw
    @renderer.paint(@game)
  end

end

win = GameWindow.new
win.show