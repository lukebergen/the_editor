APPLICATION_DIR = File.join(['.', 'application'])
require 'gosu'
require 'digest'
require 'fileutils'
require 'debugger'
require 'json'
require 'texplay'
require File.join([APPLICATION_DIR, 'game'])
require File.join([APPLICATION_DIR, 'media_manager'])
require File.join([APPLICATION_DIR, 'constants'])
require File.join([APPLICATION_DIR, 'input_handler'])
require File.join([APPLICATION_DIR, 'renderers', 'base'])
require File.join([APPLICATION_DIR, 'renderers', 'edit_renderer'])
require File.join([APPLICATION_DIR, 'renderers', 'play_renderer'])
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
    @play_renderer = PlayRenderer.new(self)
    @edit_renderer = EditRenderer.new(self)
    @renderer = @play_renderer
    @game = Game.new(@renderer.media_manager.maps)
  end

  def update
    @game.tick
    @renderer.tick(@game)
    @fps = "fps: #{Gosu::fps}"
  end

  def draw
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

$times = {}
class Profiler
  class << self
    def b(tag)
      $times[tag] ||= 0.0
      s = Time.now
      yield
      $times[tag] += Time.now - s
    end
  end
end
P = Profiler

if (ARGV[0] == "console")
  win = GameWindow.new
  win.do_debugger
else
  win = GameWindow.new
  win.show
end
