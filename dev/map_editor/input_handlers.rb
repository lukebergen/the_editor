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
      File.open("./#{@file_path}.map", 'w') {|f| f.write(json)}
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
      @block_selection = []
      @block_selection[0] = @currently_over[0]
      @block_selection[1] = @currently_over[1]
      @block_mode = true
      @selecting_tile = false
      @selecting_object = false
    end
    if id == Gosu::KbX
      # used for debugging stuff
    end
    if id == Gosu::MsLeft
      if (@block_mode)
        
      else
        left_mouse_click
      end
    end
    if id == Gosu::MsRight
      right_mouse_click
    end
  end

  def button_up(id)
    if id == Gosu::MsLeft
      if (@block_mode)
        finalize_block_selection
      end
    end
  end

  def finalize_block_selection
    (@block_selection[0]..@block_selection[2]).each do |row|
      (@block_selection[1]..@block_selection[3]).each do |col|
        @map.tiles[row][col][4] = 1
      end
    end
    @block_mode = false
    @block_selection = []
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