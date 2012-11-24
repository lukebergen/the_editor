APPLICATION_DIR = "./application"
require 'gosu'
require 'json'
require File.join([APPLICATION_DIR, "tileset.rb"])
require File.join([APPLICATION_DIR, "map.rb"])
require File.join([APPLICATION_DIR, "utils.rb"])
require File.expand_path(File.join([File.dirname(__FILE__), "drawers.rb"]))
require File.expand_path(File.join([File.dirname(__FILE__), "input_handlers.rb"]))
require File.expand_path(File.join([File.dirname(__FILE__), "setters"]))

class GameWindow < Gosu::Window

  include Drawers
  include InputHandlers
  include Setters

  def initialize(name, height=nil, width=nil, tileset_name=nil)
    super 1280, 800, false
    @text = nil
    @timer = 0
    @selecting_tile = false
    @dialog_font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    if (height)
      @map = Map.new
      @map.name = name
      @map.height = height.to_i
      @map.width = width.to_i
      @map.tileset = tileset_name
      @map.tiles = []
      @map.height.times do
        arr = []
        @map.width.times do
          arr << [0,0,0,0,0]
        end
        @map.tiles << arr
      end
    else
      json = File.read("#{name}.map")
      @map = Map.new(json)
    end
    unless tileset_name
      tileset_name = @map.tileset
    end
    tileset_dir = File.join([APPLICATION_DIR, "tilesets", tileset_name])
    @tileset = Tileset.new(self, tileset_dir)
    @selected_tile = [0,0]
    @selected_object = nil
    @currently_over = [0,0]
    @block_mode = false
    @block_selection = [0,0,0,0]
  end

  def needs_cursor?
    true
  end

  def update
    set_currently_over
    set_block_selection if @block_mode
  end

  def draw
    #draw_mouse

    if (@selecting_tile)
      draw_tile_selection
    elsif (@selecting_object)
      draw_object_selection
    else
      if (@selected_tile)
        draw_selected_tile
      elsif (@selected_object)
        draw_selected_object
      end
      draw_map
    end

    if @text
      @dialog_font.draw(@text, 0, 0, 9000, 1, 1, Gosu::Color::BLACK)
      if (@timer <= 0)
        @text = nil
      else
        @timer -= 1
      end
    end
  end

  def notify(text)
    @text = text
    @timer = 60
  end

end

# "name":"dev_area","height":64,"width":64,"tileset":"tiles","tiles"
if ARGV[0] && ARGV[1] && ARGV[2] && ARGV[3]
  name, height, width, tileset_name = ARGV[0], ARGV[1], ARGV[2], ARGV[3]
  win = GameWindow.new(name, height, width, tileset_name)
  win.show
elsif ARGV[0]
  name = ARGV[0]
  win = GameWindow.new(name)
  win.show
else
  puts "Usage:"
  puts "ruby map_editor.rb 'map-name' 'height' 'width' 'tileset-to-use'"
  puts "OR"
  puts "ruby map_editor.rb 'name-of-existing-map'"
  exit
end