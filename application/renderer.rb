require 'json'

class Renderer

  attr_accessor :media_manager

  def initialize(window)
    @window = window
    @media_manager = MediaManager.new(@window)
    @dialog_font = Gosu::Font.new(@window, Gosu::default_font_name, 20)
    @code_string_font = Gosu::Font.new(@window, Gosu::default_font_name, Constants::CODE_FONT_SIZE)
    @code_string_objects = {}
    @pre_rendered_maps = {}
    @neighbors = [[],[],[]]
    @current_map = nil
    @focus = [@window.width / 2.0, @window.height / 2.0]
  end

  def paint(game)
    set_background

    if (game.mode == :play)
      render_world
    else
      render_code_world
      render_side_bar
    end

    render_game_objects(game.objects, game.mode)

    if @s
      @dialog_font.draw(@s, 1100, 750, 1000, 1, 1, Gosu::Color::BLACK)
    end
  end

  def tick(game)
    if (game.mode == :play)
      @media_manager.animations.values.each do |ani|
        ani.tick
      end
      if (@current_map != game.current_map)
        build_world(game.current_map)
      end
      update_focus(game)
    else
      game.objects.each do |obj|
        unless @code_string_objects[obj.id]
          @code_string_objects[obj.id] = {}
          lines = str_to_lines(obj.code_string, obj.get_attribute(:width))
          speed = lines.count / 20.0
          @code_string_objects[obj.id][:lines] = lines
          @code_string_objects[obj.id][:speed] = speed
          @code_string_objects[obj.id][:height] = speed
        end
        @code_string_objects[obj.id][:height] -= @code_string_objects[obj.id][:speed]
        if (@code_string_objects[obj.id][:lines].count * Constants::CODE_FONT_SIZE * -1 > @code_string_objects[obj.id][:height] - obj.get_attribute(:height))
          @code_string_objects[obj.id][:height] = 0
        end
      end
    end
  end

  def str_to_lines(str, width)
    lines = []
    temp = ''
    str.each_char do |char|
      next if char == $/
      temp << char
      if @code_string_font.text_width(temp) > width
        lines << temp
        temp = ''
      end
    end
    lines
  end

  def set_mode(m)
    if (m == :play)
      @code_string_scrol = {}
    end
  end

  def build_world(map_name)
    @neighbors = [[],[],[]]
    @current_map = map_name
    map = media_manager.maps[map_name]
    @world = @window.record(1024*3, 1024*3) do
      @neighbors[1][1] = build_map(map_name, 0, 0)
      map.neighbors.each do |key, name|
        case key
        when :top_left
          @neighbors[0][0] = build_map(name, -1024, -1024)
        when :top
          @neighbors[0][1] = build_map(name, 0, -1024)
        when :top_right
          @neighbors[0][2] = build_map(name, 1024, -1024)
        when :left
          @neighbors[1][0] = build_map(name, -1024, 0)
        when :right
          @neighbors[1][2] = build_map(name, 1024, 0)
        when :bottom_left
          @neighbors[2][0] = build_map(name, -1024, 1024)
        when :bottom
          @neighbors[2][1] = build_map(name, 0, 1024)
        when :bottom_right
          @neighbors[2][2] = build_map(name, 1024, 1024)
        end
      end
    end
  end

  def build_map(name, offset_x, offset_y)
    map = media_manager.maps[name]
    return unless map
    tileset = media_manager.tilesets[map.tileset]
    mul = tileset.tile_size

    result = {}
    # result[:top_image] = @window.record(map.width*mul, map.height*mul) do
      map.tiles.each_with_index do |row_arr, row|
        row_arr.each_with_index do |tile_data, col|
          img = tileset.tiles[tile_data[0]][tile_data[1]]
          img.draw((col * mul) + offset_x, (row * mul) + offset_y, Constants::Z_POSITIONS[:top_tile])
        end
      end
    # end
    # result[:bottom_image] = @window.record(map.width*mul, map.height*mul) do
      map.tiles.each_with_index do |row_arr, row|
        row_arr.each_with_index do |tile_data, col|
          img = tileset.tiles[tile_data[2]][tile_data[3]]
          img.draw((col * mul) + offset_x, (row * mul) + offset_y, Constants::Z_POSITIONS[:bottom_tile])
        end
      end
    # end
    result[:name] = name
    result
  end

  def update_focus(game)

    focus_object = game.objects.select do |obj|
      obj.has_attribute?(:has_focus) && obj.get_attribute(:has_focus)
    end.first

    return unless focus_object

    center_x = @window.width / 2.0
    center_y = @window.height / 2.0

    has_left     = !(@neighbors[0][0] || @neighbors[1][0] || @neighbors[2][0]).nil?
    has_top      = !(@neighbors[0][0] || @neighbors[0][1] || @neighbors[0][2]).nil?
    has_right    = !(@neighbors[0][2] || @neighbors[1][2] || @neighbors[2][2]).nil?
    has_bottom   = !(@neighbors[2][0] || @neighbors[2][1] || @neighbors[2][2]).nil?

    # set focus assuming there's a neighbor, then reset it to center if no neighbor
    fx = focus_object.get_attribute(:x)
    fy = focus_object.get_attribute(:y)
    @focus[0] = fx #center_x - (fx - center_x)
    @focus[1] = fy #center_y - (fy - center_y)

    if (fx < center_x && !has_left)
      @focus[0] = center_x
    end
    if (fx > (1024 - center_x) && !has_right)
      @focus[0] = (1024 - center_x)
    end
    if (fy < center_y && !has_top)
      @focus[1] = center_y
    end
    if (fy > (1024 - center_y) && !has_bottom)
      @focus[1] = (1024 - center_y)
    end
  end

  def render_world
    @world.draw((@window.width / 2.0) - @focus[0], (@window.height / 2.0) - @focus[1], Constants::Z_POSITIONS[:top_tile])
  end

  def render_game_objects(objects, mode = :play)
    objects = objects.select do |obj|
      obj.has_module?("Displayable") && obj.get_attribute(:current_map)
    end
    (0..2).each do |row|
      (0..2).each do |col|
        next unless @neighbors[row] && @neighbors[row][col] && @neighbors[row][col][:name]
        map_name = @neighbors[row][col][:name]
        objects_to_render = objects.select {|obj| obj.get_attribute(:current_map) == @neighbors[row][col][:name]}
        objects_to_render.each do |go|
          x = go.attributes[:x] - (@focus[0] - (@window.width / 2.0)) + ((col-1) * Constants::MAP_WIDTH)
          y = go.attributes[:y] - (@focus[1] - (@window.height / 2.0)) + ((row-1) * Constants::MAP_HEIGHT)
          z = go.attributes[:z] || Constants::Z_POSITIONS[:default_game_object]
          render_object(go, x, y, z, mode)
        end  # objects_to_render
      end  # col
    end  # row
  end  # def render_game_objects

  def render_object(go, x, y, z, mode = :play)
    height = go.attributes[:height]
    width = go.attributes[:width]
    if (mode == :play)
      img_src = go.attributes[:current_image]
      if (img_src.include?(':'))
        split = img_src.split(':')
        current_image = @media_manager.animations[split[0]].current_image(split[1])
      else
        current_image = @media_manager.images[go.attributes[:current_image]]
      end
      if (x && y && current_image)
        fx = fy = 1
        if (height || width)
          fx, fy = stretch_factor(current_image, height, width)
        end
        #puts "drawing: #{go.id}: #{x}, #{y}, #{z}"
        current_image.draw(x, y, z, fx, fy)
      end
    else

      lines = @code_string_objects[go.id][:lines] || []
      height_offset = @code_string_objects[go.id][:height] || 0
      @window.clip_to(x, y, width, height) do
        lines.each_with_index do |line, i|
          @code_string_font.draw(line, x, y + (i * Constants::CODE_FONT_SIZE) + height_offset, z, 1, 1, Gosu::Color::BLACK)
        end
      end
    end
  end

  def render_code_world
  end
  
  def render_side_bar
  end

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