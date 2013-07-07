module Collidable
  REQUIRES = ['Tickable']

  def self.extended(klass)
    klass.instance_eval do
      set_attribute(:on_tile_collision, :stop)
      set_attribute(:blocking, true)
    end
  end

  def is_blocking?
    get_attribute(:blocking)
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
    with_x_shift = next_move_tiles(new_x, get_attribute(:y))
    with_y_shift = next_move_tiles(get_attribute(:x), new_y)
    # with_both_shift = next_move_tiles(new_x, new_y)

    result = [false, false]

    collision_objects = collision_at?(with_x_shift)
    collision_objects.each do |collision_object|
      if (collision_object[:type] == :tile)
        x = collision_object[:point][0]
        result[0] ||= [100000, -1]
        result[0][0] = x if result[0][0] > x
        result[0][1] = x + Constants::TILE_SIZE if result[0][1] < x
        # result[0] = [x, x + Constants::TILE_SIZE]
      else
        obj = collision_object[:object]
        x = obj.get_attribute(:x)
        result[0] = [x, x + obj.get_attribute(:width)] if obj.is_blocking?
      end
    end

    collision_objects = collision_at?(with_y_shift)
    collision_objects.each do |collision_object|
      if (collision_object[:type] == :tile)
        y = collision_object[:point][1]
        result[1] ||= [100000, -1]
        result[1][0] = y if result[1][0] > y
        result[1][1] = y + Constants::TILE_SIZE if result[1][1] < y
        # result[1] = [y, y + Constants::TILE_SIZE]
      else
        obj = collision_object[:object]
        y = obj.get_attribute(:y)
        result[1] = [y, y + obj.get_attribute(:height)] if obj.is_blocking?
      end
    end

    return result[0], result[1]
  end

  def collision_at?(points)
    tile_block = @game.maps[get_attribute(:current_map)].blocked?(points)
    if tile_block
      return [{type: :tile, point: tile_block.map {|x| x * Constants::TILE_SIZE}}]
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
          result << {type: :object, point: (points & other_arr), object: other}
        end
      end
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