module Setters
  def set_currently_over
    ts = @tileset.tile_size
    x = (self.mouse_x - @focus[0]) / ts
    y = (self.mouse_y - @focus[1]) / ts
    x = @map.width - 1 if x >= @map.width
    y = @map.height - 1 if y >= @map.height
    @currently_over = [y.floor,x.floor]
  end

  def set_block_selection
    if (button_down?(Gosu::MsLeft))
      @block_selection = [@block_selection[0], @block_selection[1], @currently_over[0], @currently_over[1]]
    else
      @block_selection = [@currently_over[0], @currently_over[1], @currently_over[0], @currently_over[1]]
    end
  end

  def set_focus
    if (@keys[:down])
      @focus[1] -= 5
    end
    if (@keys[:up])
      @focus[1] += 5
    end
    if (@keys[:left])
      @focus[0] += 5
    end
    if (@keys[:right])
      @focus[0] -= 5
    end
  end
end