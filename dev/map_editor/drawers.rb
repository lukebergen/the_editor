module Drawers

  def draw_map
    set_background
    ts = @tileset.tile_size
    @map.tiles.each_with_index do |row, y|
      row.each_with_index do |data_arr, x|
        next if data_arr.empty?
        img = @tileset.tiles[data_arr[0]][data_arr[1]]
        img.draw(x * ts + @focus[0], y * ts + @focus[1], 210)
        img = @tileset.tiles[data_arr[2]][data_arr[3]]
        img.draw(x * ts + @focus[0], y * ts + @focus[1], 200)

        # blocking tiles
        if (@block_mode && data_arr[4] == 1)
          # top
          if (@map.tiles[y-1] && @map.tiles[y-1][x][4] == 0)
            self.draw_line(x*ts+@focus[0],y*ts+@focus[1],Gosu::Color::YELLOW, x*ts+ts+@focus[0], y*ts+@focus[1], Gosu::Color::YELLOW, 300)
          end
          # right
          if (@map.tiles[y][x+1] && @map.tiles[y][x+1][4] == 0)
            self.draw_line(x*ts+ts+@focus[0],y*ts+@focus[0],Gosu::Color::YELLOW, x*ts+ts+@focus[0], y*ts+ts+@focus[1], Gosu::Color::YELLOW, 300)
          end
          # bottom
          if (@map.tiles[y+1] && @map.tiles[y+1][x][4] == 0)
            self.draw_line(x*ts+@focus[0],y*ts+ts+@focus[1],Gosu::Color::YELLOW, x*ts+ts+@focus[0], y*ts+ts+@focus[1], Gosu::Color::YELLOW, 300)
          end
          # left
          if (@map.tiles[y][x-1] && @map.tiles[y][x-1][4] == 0)
            self.draw_line(x*ts+@focus[0],y*ts+@focus[1],Gosu::Color::YELLOW, x*ts+@focus[0], y*ts+ts+@focus[1], Gosu::Color::YELLOW, 300)
          end
        end # if data_arr[4] == 1
      end # row.each
    end # @map.tiles.each
  end # def draw_map

  def draw_tile_selection
    ts = @tileset.tile_size
    @tileset.tiles.each_with_index do |row, y|
      row.each_with_index do |img, x|
        img.draw(x*ts, y*ts, 200)
      end
    end
  end

  def draw_object_selection
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

  def draw_selected_tile
    ts = @tileset.tile_size
    img = @tileset.tiles[@selected_tile[0]][@selected_tile[1]]
    img.draw(@currently_over[1]*ts+@focus[0], @currently_over[0]*ts+@focus[1], 1000)
  end

  def draw_selected_object
    ts = @tileset.tile_size
    obj_arr = @tileset.objects[@selected_object]
    obj_arr.each_with_index do |row, i|
      row.each_with_index do |col, j|
        img = @tileset.tiles[col[2]][col[3]]
        #img.draw(j*ts, i*ts, 200)
        img.draw(@currently_over[1]*ts + j*ts + @focus[0], @currently_over[0]*ts + i*ts + @focus[1], 1000)

        img = @tileset.tiles[col[0]][col[1]]
        #img.draw(j*ts, i*ts, 200)
        img.draw(@currently_over[1]*ts + j*ts + @focus[0], @currently_over[0]*ts + i*ts + @focus[1], 1000)
      end
    end
  end

  def draw_block_selection
    ts = @tileset.tile_size
    sx = @block_selection[1] * ts + @focus[0]
    ex = @block_selection[3] * ts + ts + @focus[1]
    sy = @block_selection[0] * ts + @focus[0]
    ey = @block_selection[2] * ts + ts + @focus[1]
    w = Gosu::Color::WHITE
    # top
    draw_line(sx, sy, w, ex, sy, w, 300)
    # right
    draw_line(ex, sy, w, ex, ey, w, 300)
    # bottom
    draw_line(sx, ey, w, ex, ey, w, 300)
    # left
    draw_line(sx, sy, w, sx, ey, w, 300)
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