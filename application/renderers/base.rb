require 'json'

module Renderer
  class Base

    def initialize(window)
      @@media_manager ||= MediaManager.new(window)
      @@window = window
      @@dialog_font = Gosu::Font.new(window, Gosu::default_font_name, 20)
      @@focus = [window.width / 2.0, window.height / 2.0]
      @@neighbors = [[],[],[]]

      @pre_rendered_maps = {}
      @current_map = nil
    end

    def media_manager
      @@media_manager
    end

    def window
      @@window
    end

    def focus
      @@focus
    end

    def neighbors
      @@neighbors
    end

    def paint(game)
      set_background
      render_game_objects(game.objects)
      if @s
        @@dialog_font.draw(@s, 1100, 750, 1000, 1, 1, Gosu::Color::BLACK)
      end
    end

    def tick(game)
      if (@current_map != game.current_map)
        build_world(game.current_map)
      end
    end

    def build_world(map_name)
      @@neighbors = [[],[],[]]
      @current_map = map_name
      map = media_manager.maps[map_name]
      @world = window.record(1024*3, 1024*3) do
        @@neighbors[1][1] = build_map(map_name, 0, 0)
        map.neighbors.each do |key, name|
          case key
          when :top_left
            @@neighbors[0][0] = build_map(name, -1024, -1024)
          when :top
            @@neighbors[0][1] = build_map(name, 0, -1024)
          when :top_right
            @@neighbors[0][2] = build_map(name, 1024, -1024)
          when :left
            @@neighbors[1][0] = build_map(name, -1024, 0)
          when :right
            @@neighbors[1][2] = build_map(name, 1024, 0)
          when :bottom_left
            @@neighbors[2][0] = build_map(name, -1024, 1024)
          when :bottom
            @@neighbors[2][1] = build_map(name, 0, 1024)
          when :bottom_right
            @@neighbors[2][2] = build_map(name, 1024, 1024)
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
      map.tiles.each_with_index do |row_arr, row|
        row_arr.each_with_index do |tile_data, col|
          img = tileset.tiles[tile_data[0]][tile_data[1]]
          img.draw((col * mul) + offset_x, (row * mul) + offset_y, Constants::Z_POSITIONS[:top_tile])
        end
      end
      map.tiles.each_with_index do |row_arr, row|
        row_arr.each_with_index do |tile_data, col|
          img = tileset.tiles[tile_data[2]][tile_data[3]]
          img.draw((col * mul) + offset_x, (row * mul) + offset_y, Constants::Z_POSITIONS[:bottom_tile])
        end
      end
      result[:name] = name
      result
    end

    def render_game_objects(objects)
      objects = objects.select do |obj|
        obj.has_module?("Displayable") && obj.get_attribute(:current_map)
      end
      (0..2).each do |row|
        (0..2).each do |col|
          next unless @@neighbors[row] && @@neighbors[row][col] && @@neighbors[row][col][:name]
          map_name = @@neighbors[row][col][:name]
          objects_to_render = objects.select {|obj| obj.get_attribute(:current_map) == @@neighbors[row][col][:name]}
          objects_to_render.each do |go|
            x = go.attributes[:x] - (focus[0] - (window.width / 2.0)) + ((col-1) * Constants::MAP_WIDTH)
            y = go.attributes[:y] - (focus[1] - (window.height / 2.0)) + ((row-1) * Constants::MAP_HEIGHT)
            z = go.attributes[:z] || Constants::Z_POSITIONS[:default_game_object]
            render_object(go, x, y, z)
          end  # objects_to_render
        end  # col
      end  # row
    end  # def render_game_objects

    def render_object(obj, x, y, z)
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
      window.draw_quad(0, 0, w, 
                        window.width, 0, w,
                        window.width, window.height, w,
                        0, window.height, w, -1000)
    end

  end

end