module Collidable
  REQUIRES = ['Tickable']

  def self.extended(klass)
    klass.instance_eval do
      @on_tile_collision = :stop
    end
  end

  def collides?(arr)

    # check tiles
    # edge case, checking for collisions on other maps.... sticky
    tile_block = @game.maps[get_attribute(:current_map)].blocked?(arr)
    return :tile if tile_block

    # now check for object blocks
    return nil
  end

  def collision_ok?(new_x, new_y)
    old_tiles = next_move_tiles(get_attribute(:x), get_attribute(:y))
    with_x_shift = next_move_tiles(new_x, get_attribute(:y))
    with_y_shift = next_move_tiles(get_attribute(:x), new_y)
    with_both_shift = next_move_tiles(new_x, new_y)

    # if the result of the new move is that the object is still within the same
    # tiles, then no collision could have occurred so...
    if old_tiles == with_x_shift && old_tiles == with_y_shift && old_tiles == with_both_shift
      return [true, true]
    end

    tile_block_x = tile_block_y = true

    tile_block_x = !@game.maps[get_attribute(:current_map)].blocked?(with_x_shift)
    unless tile_block_x
      # so, we haven't hit a blocking tile, what about objects?
      # TODO handle object collision detection
    end

    tile_block_y = !@game.maps[get_attribute(:current_map)].blocked?(with_y_shift)
    unless tile_block_x
      # so, we haven't hit a blocking tile, what about objects?
      # TODO handle object collision detection
    end

    [tile_block_x, tile_block_y]
  end

  def next_move_tiles(next_x, next_y)
    my_coords = []
    (0..tile_width).each do |row_diff|
      (0..tile_height).each do |col_diff|
        my_coords << [tile_y(next_y) + row_diff, tile_x(next_x) + col_diff]
      end
    end
    my_coords
  end

  def collide(obj = :tile)
    puts self.name
    if (obj != :tile)
      emit(object: obj.name, message: collide, params: [self.name])
    end
  end

end