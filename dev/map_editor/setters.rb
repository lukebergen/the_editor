module Setters
  def set_currently_over
    ts = @tileset.tile_size
    x = self.mouse_x / ts
    y = self.mouse_y / ts
    x = @map.width - 1 if x >= @map.width
    y = @map.height - 1 if y >= @map.height
    @currently_over = [y.floor,x.floor]
  end

  def set_block_selection
    @block_selection = [@block_selection[0], @block_selection[1], @currently_over[0], @currently_over[1]]
  end
end