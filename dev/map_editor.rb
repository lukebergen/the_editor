APPLICATION_DIR = "./application"
require 'gosu'
require 'json'
require 'debugger'
require File.join([APPLICATION_DIR, "tileset.rb"])
require File.join([APPLICATION_DIR, "map.rb"])

class GameWindow < Gosu::Window

  def initialize(name, height=nil, width=nil, tileset_name=nil)
    super 1280, 800, false
    @text = nil
    @timer = 0
    @selecting_tile = false
    @dialog_font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @mouse_img = Gosu::Image.new(self, "#{APPLICATION_DIR}/media/system/mouse.png")
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
          arr << []#[0,0,0,0,0]
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
    @currently_over = [0,0]
  end

  def update
    set_currently_over
  end

  def draw
    draw_mouse
    draw_selected_tile unless @selecting_tile

    if (@selecting_tile)
      draw_tile_selection
    else
      draw_map
    end

    if @text
      @dialog_font.draw(@text, 0, 0, 0, 1, 1, Gosu::Color::BLACK)
      if (@timer <= 0)
        @text = nil
      else
        @timer -= 1
      end
    end
  end

  def draw_map
    set_background
    ts = @tileset.tile_size
    @map.tiles.each_with_index do |row, y|
      row.each_with_index do |data_arr, x|
        next if data_arr.empty?
        img = @tileset.tiles[data_arr[0]][data_arr[1]]
        img.draw(x*ts, y*ts, 200)
      end
    end
  end

  def draw_tile_selection
    ts = @tileset.tile_size
    @tileset.tiles.each_with_index do |row, y|
      row.each_with_index do |img, x|
        img.draw(x*ts, y*ts, 200)
      end
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      if (@selecting_tile)
        @selecting_tile = false
      else
        close
      end
    end
    if id == Gosu::KbD
      do_debugger
    end
    if id == Gosu::KbS
      notify("Saving")
      json = @map.to_json
      File.open("./#{@map.name}.map", 'w') {|f| f.write(json)}
    end
    if id == Gosu::KbT
      notify("Selecting Tile")
      @selecting_tile = true
    end
    if id == Gosu::KbO
      notify("Selecting Object")
    end
    if id == Gosu::KbX
      notify("currently over: #{@currently_over[0]}, #{@currently_over[1]}")
    end
    if id == Gosu::MsLeft
      notify("Left-Click")
      if (@selecting_tile)
        @selected_tile = @currently_over
        @selecting_tile = false
      else
        previous_tile = @map.tiles[@currently_over[1]][@currently_over[0]]
        previous_tile[0] = @selected_tile[0]
        previous_tile[1] = @selected_tile[1]
        @map.tiles[@currently_over[1]][@currently_over[0]] = previous_tile
      end
    end
    if id == Gosu::MsRight
      notify("Right-Click")
    end
  end

  def notify(text)
    @text = text
    @timer = 60
  end

  def do_debugger
    debugger
    noop = nil
  end

  def draw_mouse
    @mouse_img.draw(self.mouse_x, self.mouse_y, 10000)
  end

  def draw_selected_tile
    @selected_tile[0]
    @selected_tile[1]
    ts = @tileset.tile_size
    img = @tileset.tiles[@selected_tile[0]][@selected_tile[1]]
    img.draw(@currently_over[0]*ts, @currently_over[1]*ts, 1000)
  end

  def set_currently_over
    ts = @tileset.tile_size
    x = self.mouse_x / ts
    y = self.mouse_y / ts
    @currently_over = [x.floor,y.floor]
  end

  def set_background
    w = Gosu::Color::WHITE
    width = @map.width * @tileset.tile_size
    height = @map.height * @tileset.tile_size
    self.draw_quad(0, 0, w, 
                      width, 0, w,
                      width, height, w,
                      0, height, w)
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