APPLICATION_DIR = "./application"
require 'gosu'
require 'debugger'
require File.join([APPLICATION_DIR, 'game'])
require File.join([APPLICATION_DIR, 'media_manager'])
require File.join([APPLICATION_DIR, 'constants'])
require File.join([APPLICATION_DIR, 'input_handler'])
require File.join([APPLICATION_DIR, 'renderer'])

class GameWindow < Gosu::Window
  
  include InputHandler

  attr_accessor :media_manager

  def initialize
    super 1280, 800, false
    self.caption = "The Editor"
    @game = Game.new
    @renderer = Renderer.new(self)
    @media_manager = MediaManager.new(self)
    @s = File.read(__FILE__).gsub(/\n/,  "")
  end

  def update
    @game.tick
  end

  def draw
    @renderer.paint(@game)
    @renderer.draw_text(@s)
  end

  def do_debugger
    debugger
    x = 3
  end

end

win = GameWindow.new
win.show