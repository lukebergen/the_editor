APPLICATION_DIR = "./application"
require 'gosu'
require 'debugger'
require 'json'
require File.join([APPLICATION_DIR, 'game'])
require File.join([APPLICATION_DIR, 'media_manager'])
require File.join([APPLICATION_DIR, 'constants'])
require File.join([APPLICATION_DIR, 'input_handler'])
require File.join([APPLICATION_DIR, 'renderer'])
require File.join([APPLICATION_DIR, 'tileset'])
require File.join([APPLICATION_DIR, 'map'])
require File.join([APPLICATION_DIR, 'animation'])
require File.join([APPLICATION_DIR, 'utils'])

class GameWindow < Gosu::Window
  
  include InputHandler

  attr_accessor :renderer

  def initialize
    super 1280, 800, false
    self.caption = "The Editor"
    @game = Game.new
    @renderer = Renderer.new(self)
  end

  def update
    @game.tick
    @fps = "fps: #{Gosu::fps}"
  end

  def draw
    @renderer.tick
    @renderer.paint(@game)
    @renderer.draw_text(@fps)
  end

  def needs_cursor?
    true
  end

  def do_debugger
    debugger
    noop = nil
  end

  def reload!
    exec("ruby main.rb console")
  end

end

if (ARGV[0] == "console")
  win = GameWindow.new
  win.do_debugger
else
  win = GameWindow.new
  win.show
end
