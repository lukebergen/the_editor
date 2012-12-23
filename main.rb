APPLICATION_DIR = File.join(['.', 'application'])
require 'gosu'
require 'chingu'
require 'fidgit'
require 'digest'
require 'fileutils'
require 'debugger'
require 'json'
require 'texplay'

Dir.glob(File.join([APPLICATION_DIR, 'helpers', '*.rb'])).each do |helper_path|
  require helper_path
end

require File.join([APPLICATION_DIR, 'game'])
require File.join([APPLICATION_DIR, 'media_manager'])
require File.join([APPLICATION_DIR, 'constants'])
require File.join([APPLICATION_DIR, 'input_handler'])
require File.join([APPLICATION_DIR, 'renderers', 'base'])
require File.join([APPLICATION_DIR, 'renderers', 'edit_renderer'])
require File.join([APPLICATION_DIR, 'renderers', 'play_renderer'])
require File.join([APPLICATION_DIR, 'game_states', 'main_view'])
require File.join([APPLICATION_DIR, 'game_states', 'edit_view'])
require File.join([APPLICATION_DIR, 'tileset'])
require File.join([APPLICATION_DIR, 'map'])
require File.join([APPLICATION_DIR, 'animation'])
require File.join([APPLICATION_DIR, 'utils'])

class GameWindow < Chingu::Window
  
  # include InputHandler

  attr_accessor :renderer

  def initialize
    super 1280, 800, false
    self.caption = "The Editor"
    @play_renderer = PlayRenderer.new(self)
    @edit_renderer = EditRenderer.new(self)
    @renderer = @play_renderer
    @game = Game.new(@renderer.media_manager.maps)

    $playing_state = MainView.new(@game, @play_renderer)
    $editing_state = EditView.new(@game, @edit_renderer)

    push_game_state $playing_state
  end

  # def update
  #   @game.tick
  #   @renderer.tick(@game)
  #   @fps = "fps: #{Gosu::fps}"
  # end

  # def draw
  #   @renderer.paint(@game)
  #   @renderer.draw_text(@fps)
  # end

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

  def game_objects_at(win_x, win_y)
    game_mouse = window_pos_to_game_pos(win_x, win_y)
    @game.objects_at(game_mouse[:map], game_mouse[:x], game_mouse[:y])
  end

  def window_pos_to_game_pos(win_x, win_y)
    game_x = game_y = game_map = nil

    focus_offset_x = (self.width / 2.0) - @renderer.focus[0]
    focus_offset_y = (self.height / 2.0) - @renderer.focus[1]

    game_x = (win_x - focus_offset_x) % Constants::MAP_WIDTH
    game_y = (win_y - focus_offset_y) % Constants::MAP_HEIGHT

    map_offset_x = ((win_x - focus_offset_x) / Constants::MAP_WIDTH).floor + 1
    map_offset_y = ((win_y - focus_offset_y) / Constants::MAP_HEIGHT).floor + 1

    if (@renderer.neighbors[map_offset_y])
      if @renderer.neighbors[map_offset_y][map_offset_x]
        game_map = @renderer.neighbors[map_offset_y][map_offset_x][:name]
      end
    end

    {map: game_map, x: game_x, y: game_y}
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
