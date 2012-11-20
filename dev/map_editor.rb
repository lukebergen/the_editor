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
          arr << [0,0,0,0,0]
        end
        @map.tiles << arr
      end
    else
      json = File.read("#{name}")
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
  end

  def update
    set_currently_over unless @selecting_object
  end

  def draw
    draw_mouse

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

  def draw_map
    set_background
    ts = @tileset.tile_size
    @map.tiles.each_with_index do |row, y|
      row.each_with_index do |data_arr, x|
        next if data_arr.empty?
        img = @tileset.tiles[data_arr[0]][data_arr[1]]
        img.draw(x*ts, y*ts, 210)
        img = @tileset.tiles[data_arr[2]][data_arr[3]]
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

  def draw_object_selection
    # BOOKMARK
    i = 0
    ts = @tileset.tile_size
    @tileset.objects.each do |object_name, tiles|
      if (self.mouse_x > 1050 && self.mouse_y > 50 + (i*20) && self.mouse_y < 50 + ((i+1)*20))
        @currently_over = object_name
        tiles.each_with_index do |row, r|
          row.each_with_index do |tile_arr, c|
            img = @tileset.tiles[tile_arr[2]][tile_arr[3]]
            img.draw(c*ts, r*ts, 200)
            img = @tileset.tiles[tile_arr[0]][tile_arr[1]]
            img.draw(c*ts, r*ts, 210)
          end
        end
        color = Gosu::Color::YELLOW
      else
        color = Gosu::Color::WHITE
      end
      @dialog_font.draw(object_name, 1100, 50 + (i * 20), 500, 1, 1, color)
      i += 1
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      if (@selecting_tile || @selecting_object)
        @selecting_tile = false
        @selecting_object = false
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
      File.open("./#{@map.name}", 'w') {|f| f.write(json)}
    end
    if id == Gosu::KbT
      @selecting_tile = true
    end
    if id == Gosu::KbO
      @selecting_object = true
    end
    if id == Gosu::KbX
      # used for debugging stuff
    end
    if id == Gosu::MsLeft
      left_mouse_click
    end
    if id == Gosu::MsRight
      right_mouse_click
    end
  end

  def left_mouse_click
    if (@selecting_tile)
      @selected_tile = @currently_over
      @selecting_tile = false
      @selected_object = nil
    elsif (@selecting_object)
      @selected_object = @currently_over
      @selected_tile = nil
      @selecting_object = false
    else
      if (@selected_tile)
        previous_tile = @map.tiles[@currently_over[0]][@currently_over[1]]
        previous_tile[0] = @selected_tile[0]
        previous_tile[1] = @selected_tile[1]
        @map.tiles[@currently_over[0]][@currently_over[1]] = previous_tile
      elsif (@selected_object)
        obj_arr = @tileset.objects[@selected_object]
        ts = @tileset.tile_size
        obj_arr.each_with_index do |row, i|
          row.each_with_index do |col, j|
            @map.tiles[@currently_over[0]+i][@currently_over[1]+j] = col
          end
        end
      end
    end
  end

  def right_mouse_click
    if !@selecting_tile && !selecting_object
      previous_tile = @map.tiles[@currently_over[0]][@currently_over[1]]
      previous_tile[2] = @selected_tile[0]
      previous_tile[3] = @selected_tile[1]
      @map.tiles[@currently_over[0]][@currently_over[1]] = previous_tile
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
    ts = @tileset.tile_size
    img = @tileset.tiles[@selected_tile[0]][@selected_tile[1]]
    img.draw(@currently_over[1]*ts, @currently_over[0]*ts, 1000)
  end

  def draw_selected_object
    # draw the currently selected object
    # BOOKMARK
    ts = @tileset.tile_size
    obj_arr = @tileset.objects[@selected_object]
    obj_arr.each_with_index do |row, i|
      row.each_with_index do |col, j|
        img = @tileset.tiles[col[2]][col[3]]
        #img.draw(j*ts, i*ts, 200)
        img.draw(@currently_over[1]*ts + j*ts, @currently_over[0]*ts + i*ts, 1000)

        img = @tileset.tiles[col[0]][col[1]]
        #img.draw(j*ts, i*ts, 200)
        img.draw(@currently_over[1]*ts + j*ts, @currently_over[0]*ts + i*ts, 1000)
      end
    end
  end

  def set_currently_over
    ts = @tileset.tile_size
    x = self.mouse_x / ts
    y = self.mouse_y / ts
    x = @map.width - 1 if x >= @map.width
    y = @map.height - 1 if y >= @map.height
    @currently_over = [y.floor,x.floor]
  end

  def set_background
    w = Gosu::Color::RED
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