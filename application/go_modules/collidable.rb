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

  def collision_block?(new_x, new_y)
    old_tiles = next_move_tiles(get_attribute(:x), get_attribute(:y))
    with_x_shift = next_move_tiles(new_x, get_attribute(:y))
    with_y_shift = next_move_tiles(get_attribute(:x), new_y)
    with_both_shift = next_move_tiles(new_x, new_y)

    # if the result of the new move is that the object is still within the same
    # tiles, then no collision could have occurred so...
    if old_tiles == with_x_shift && old_tiles == with_y_shift && old_tiles == with_both_shift
      return [false, false]
    end

    result = [false, false]

    collision_objects = collision_at?(with_x_shift)
    if (collision_objects)
      if (collision_objects == :tile)
        result[0] = true
      else
        collision_objects.each do |other|
          result[0] ||= @game.emit(object_id: other.id, message: :collide, params: {other_id: self.id})
        end
      end
    end

    collision_objects = collision_at?(with_y_shift)
    if (collision_objects)
      if (collision_objects == :tile)
        result[1] = true
      else
        collision_objects.each do |other|
          result[1] = @game.emit(object_id: other.id, message: :collide, params: {other_id: self.id})
        end
      end
    end

    result
  end

  def collision_at?(points)
    if @game.maps[get_attribute(:current_map)].blocked?(points)
      return :tile
    else
      result = []
      (@game.objects - [self]).each do |other|
        next unless other.get_attribute(:current_map) == self.get_attribute(:current_map)
        other_arr = []
        (0..other.tile_width).each do |w|
          (0..other.tile_height).each do |h|
            other_arr << [other.tile_x + w, other.tile_y + h]
          end
        end
        unless (points & other_arr).empty?
          result << other
        end
      end
      result = nil if result.count == 0
      return result
    end
  end

  def next_move_tiles(next_x = get_attribute(:x), next_y = get_attribute(:y))
    my_coords = []
    (0..tile_width).each do |row_diff|
      (0..tile_height).each do |col_diff|
        my_coords << [tile_x(next_x) + row_diff, tile_y(next_y) + col_diff]
      end
    end
    my_coords
  end

  def collide(obj = :tile)
    puts self.name
    if (obj != :tile)
      emit(object_id: obj.id, message: collide, params: [self.id])
    end
  end

end