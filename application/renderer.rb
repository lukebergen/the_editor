require 'json'

class Renderer

  attr_accessor :media_manager

  def initialize(window)
    @window = window
    @media_manager = MediaManager.new(@window)
    @dialog_font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
    @mouse_img = Gosu::Image.new(@window, "#{APPLICATION_DIR}/media/system/mouse.png")
    @pre_rendered_maps = {}
    @world = [[],[],[]]
    @current_map = nil
    @focus = [@window.width / 2.0, @window.height / 2.0]
  end

  def paint(game)
    set_background

    if (@current_map != game.current_map)
      build_world(game.current_map)
    end
    render_world

    render_game_objects(game.objects)

    if @s
      @dialog_font.draw(@s, 1100, 750, 1000, 1, 1, Gosu::Color::BLACK)
    end
  end

  def tick(game)
    @media_manager.animations.values.each do |ani|
      ani.tick
    end
    update_focus(game)
  end

  def build_world(map_name)
    @world = [[],[],[]]
    @current_map = map_name
    map = media_manager.maps[map_name]
    @world[1][1] = build_map(map_name)
    map.neighbors.each do |key, name|
      case key
      when :top_left
        @world[0][0] = build_map(name)
      when :top
        @world[0][1] = build_map(name)
      when :topright
        @world[0][2] = build_map(name)
      when :left
        @world[1][0] = build_map(name)
      when :right
        @world[1][2] = build_map(name)
      when :bottomleft
        @world[2][0] = build_map(name)
      when :bottom
        @world[2][1] = build_map(name)
      when :bottomright
        @world[2][2] = build_map(name)
      end
    end
  end

  def build_map(name)
    map = media_manager.maps[name]
    tileset = media_manager.tilesets[map.tileset]
    mul = tileset.tile_size

    result = {}
    result[:top_image] = @window.record(map.width*mul, map.height*mul) do
      map.tiles.each_with_index do |row_arr, row|
        row_arr.each_with_index do |tile_data, col|
          img = tileset.tiles[tile_data[0]][tile_data[1]]
          img.draw(col * mul, row * mul, 0)
        end
      end
    end
    result[:bottom_image] = @window.record(map.width*mul, map.height*mul) do
      map.tiles.each_with_index do |row_arr, row|
        row_arr.each_with_index do |tile_data, col|
          img = tileset.tiles[tile_data[2]][tile_data[3]]
          img.draw(col * mul, row * mul, 0)
        end
      end
    end
    result[:name] = name
    result
  end

  def update_focus(game)

    focus_object = game.objects.select do |obj|
      obj.has_attribute?(:has_focus) && obj.get_attribute(:has_focus)
    end.first

    map = @world[1][1]
    map = map[:top_image] if map

    return unless map && focus_object

    center_x = @window.width / 2.0
    center_y = @window.height / 2.0

    has_left     = !(@world[0][0] || @world[1][0] || @world[2][0]).nil?
    has_top      = !(@world[0][0] || @world[0][1] || @world[0][2]).nil?
    has_right    = !(@world[0][2] || @world[1][2] || @world[2][2]).nil?
    has_bottom   = !(@world[2][0] || @world[2][1] || @world[2][2]).nil?

    # set focus assuming there's a neighbor, then reset it to center if no neighbor
    fx = focus_object.get_attribute(:x)
    fy = focus_object.get_attribute(:y)
    @focus[0] = fx #center_x - (fx - center_x)
    @focus[1] = fy #center_y - (fy - center_y)

    if (fx < center_x && !has_left)
      @focus[0] = center_x
    end
    if (fx > (map.width - center_x) && !has_right)
      @focus[0] = (map.width - center_x)
    end
    if (fy < center_y && !has_top)
      @focus[1] = center_y
    end
    if (fy > (map.width - center_y) && !has_bottom)
      @focus[1] = (map.width - center_y)
    end
  end

  def render_world
    (0..2).each do |row|
      (0..2).each do |col|
        next if @world[row][col].nil? || @world[row][col].empty?
        bottom_img = @world[row][col][:bottom_image]
        top_img = @world[row][col][:top_image]
        
        x = (col - 1) * top_img.width - (@focus[0] - @window.width / 2.0)
        y = (row - 1) * top_img.height - (@focus[1] - @window.height / 2.0)
        bottom_img.draw(x, y, Constants::Z_POSITIONS[:bottom_tile])
        top_img.draw(x, y, Constants::Z_POSITIONS[:top_tile])
      end
    end
  end

  def render_game_objects(objects)
    objects = objects.select do |obj|
      obj.has_module("Displayable") && obj.get_attribute(:current_map)
    end
    (0..2).each do |row|
      (0..2).each do |col|
        next unless @world[row] && @world[row][col] && @world[row][col][:name]
        map_name = @world[row][col][:name]
        objects_to_render = objects.select {|obj| obj.get_attribute(:current_map) == @world[row][col][:name]}
        objects_to_render.each do |go|
          x = go.attributes[:x] - (@focus[0] - (@window.width / 2.0)) + ((row-1) * Constants::MAP_HEIGHT)
          y = go.attributes[:y] - (@focus[1] - (@window.height / 2.0)) + ((col-1) * Constants::MAP_WIDTH)
          z = go.attributes[:z]
          height = go.attributes[:height]
          width = go.attributes[:width]
          img_src = go.attributes[:current_image]
          if (img_src.include?(':'))
            split = img_src.split(':')
            current_image = @media_manager.animations[split[0]].current_image(split[1])
          else
            current_image = @media_manager.images[go.attributes[:current_image]]
          end
          if (x && y && current_image)
            fx = fy = 1
            z ||= Constants::Z_POSITIONS[:default_game_object]
            if (height || width)
              fx, fy = stretch_factor(current_image, height, width)
            end
            current_image.draw(x, y, z, fx, fy)
          end

        end  # objects_to_render
      end  # col
    end  # row
  end  # def render_game_objects

  def stretch_factor(image, stretch_to_height, stretch_to_width)
    x = y = 1
    if (stretch_to_height)
      y = stretch_to_height / image.height.to_f
    end
    if (stretch_to_width)
      x = stretch_to_width / image.width.to_f
    end
    return x, y
  end

  def draw_text(text)
    @s = text
  end

  def set_background
    w = Gosu::Color::WHITE
    @window.draw_quad(0, 0, w, 
                      @window.width, 0, w,
                      @window.width, @window.height, w,
                      0, @window.height, w)
  end

end