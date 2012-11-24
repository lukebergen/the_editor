module InputHandlers

  def button_down(id)
    if id == Gosu::KbEscape
      if (@selecting_tile || @selecting_object || @block_mode)
        @selecting_tile = false
        @selecting_object = false
        @block_mode = false
      else
        close
      end
    end
    if id == Gosu::KbS
      notify("Saving")
      json = @map.to_json
      File.open("./#{@map.name}.map", 'w') {|f| f.write(json)}
    end
    if id == Gosu::KbT
      @selecting_tile = true
      @selecting_object = false
      @block_mode = false
    end
    if id == Gosu::KbO
      @selecting_object = true
      @selecting_tile = false
      @block_mode = false
    end
    if id == Gosu::KbB
      @block_mode = true
      @selecting_tile = false
      @selecting_object = false
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

end