module Movable

  REQUIRES = ['Tickable', 'Displayable']

  def self.extended(klass)
    klass.add_attribute(:dir, :down)
    klass.instance_eval do
      listen_for(:start_move, :start_move)
      listen_for(:stop_move, :stop_move)
      add_ticker(:move)
      add_ticker(:check_edge_hit)
      set_attribute(:speed, 10.0)
      @dx = 0
      @dy = 0
      @dirs_moving = []
      @last_dir = :down
      @ani_form = "#{self.class.to_s}_<dir>"
      @img_form = "#{self.class.to_s}_<dir>.png"
    end
  end

  def start_move(params)
    dir = params[:dir]
    case dir
    when :up
      @dirs_moving << :up
      direction_ani
      @dy -= 1
    when :down
      @dirs_moving << :down
      direction_ani
      @dy += 1
    when :left
      @dirs_moving << :left
      direction_ani
      @dx -= 1
    when :right
      @dirs_moving << :right
      direction_ani
      @dx += 1
    end
  end

  def stop_move(params)
    dir = params[:dir]
    case dir
    when :up
      set_attribute(:dir, :up)
      @dirs_moving.delete(:up)
      direction_ani
      @dy += 1
    when :down
      set_attribute(:dir, :down)
      @dirs_moving.delete(:down)
      direction_ani
      @dy -= 1
    when :left
      set_attribute(:dir, :left)
      @dirs_moving.delete(:left)
      direction_ani
      @dx += 1
    when :right
      set_attribute(:dir, :right)
      @dirs_moving.delete(:right)
      direction_ani
      @dx -= 1
    end
  end

  def direction_ani
    if (@dirs_moving.empty?)
      img_str = @img_form.gsub('<dir>', get_attribute(:dir).to_s)
      set_attribute(:current_image, img_str)
    else
      if !current_animation || current_animation.include?(get_attribute(:dir).to_s)
        img_str = @ani_form.gsub('<dir>', @dirs_moving.last.to_s)
        set_animation(img_str)
      end
    end
  end

  def move
    return if @dx == 0 && @dy == 0
    old_x = get_attribute(:x)
    old_y = get_attribute(:y)
    new_x = old_x + (@dx * (get_attribute(:speed) - (@dirs_moving.count * 1.0)))
    new_y = old_y + (@dy * (get_attribute(:speed) - (@dirs_moving.count * 1.0)))
    
    blocked_x = blocked_y = false
    if (has_module?('Collidable'))
      blocked_x, blocked_y = collision_block?(new_x, new_y)
      if (blocked_x)
        if (new_x + get_attribute(:width) >= blocked_x[0] &&
            old_x + get_attribute(:width) < blocked_x[0])
          new_x = blocked_x[0] - 1 - get_attribute(:width)
        end
        if (new_x <= blocked_x[1] && old_x > blocked_x[1])
          new_x = blocked_x[1] + 1
        end
      end

      if (blocked_y)
        if (new_y + get_attribute(:height) >= blocked_y[0]) &&
           (old_y + get_attribute(:height) < blocked_y[0])
          new_y = blocked_y[0] - 1 - get_attribute(:height)
        end
        if (new_y <= blocked_y[1] && old_y > blocked_y[1])
          new_y = blocked_y[1] + 1
        end
      end

    end

    set_attribute(:x, new_x)
    set_attribute(:y, new_y)
  end

  def check_edge_hit
    x = get_attribute(:x)
    y = get_attribute(:y)

    if (x < 0)
      edge_hit(:left)
    end
    if (y < 0)
      edge_hit(:top)
    end
    if (x > Constants::MAP_WIDTH) # - get_attribute(:width))
      edge_hit(:right)
    end
    if (y > Constants::MAP_HEIGHT) # - get_attribute(:height))
      edge_hit(:bottom)
    end
  end

  def edge_hit(dir)
    options = {on_world_edge: :stop}
    map = @game.maps[self.get_attribute(:current_map)]
    case dir
    when :left
      if (map.neighbors[:left])
        self.set_attribute(:x, Constants::MAP_WIDTH)
        change_map(map.neighbors[:left])
      else
        if (options[:on_world_edge] == :stop)
          self.set_attribute(:x, 0)
        elsif (options[:on_world_edge] == :destroy)
          destroy
        end
      end
    when :top
      if (map.neighbors[:top])
        self.set_attribute(:y, Constants::MAP_HEIGHT)
        change_map(map.neighbors[:top])
      else
        if (options[:on_world_edge] == :stop)
          self.set_attribute(:y, 0)
        elsif (options[:on_world_edge] == :destroy)
          destroy
        end
      end
    when :right
      if (map.neighbors[:right])
        self.set_attribute(:x, 0)
        change_map(map.neighbors[:right])
      else
        if (options[:on_world_edge] == :stop)
          self.set_attribute(:x, Constants::MAP_WIDTH)
        elsif (options[:on_world_edge] == :destroy)
          destroy
        end
      end
    when :bottom
      if (map.neighbors[:bottom])
        self.set_attribute(:y, 0)
        change_map(map.neighbors[:bottom])
      else
        if (options[:on_world_edge] == :stop)
          self.set_attribute(:y, Constants::MAP_HEIGHT)
        elsif (options[:on_world_edge] == :destroy)
          destroy
        end
      end
    end
  end

  def move_to(x, y, speed=1)
    @move_to_final_x = x
    @move_to_final_y = y
    @move_to_speed = 5
    add_ticker(:do_move)
    do_move
  end

  def do_move
    old_x = get_attribute(:x)
    old_y = get_attribute(:y)
    diff_x = @move_to_final_x - old_x
    diff_y = @move_to_final_y - old_y

    x_component = diff_x.to_f / (diff_x.abs + diff_y.abs)
    y_component = diff_y.to_f / (diff_x.abs + diff_y.abs)
    
    new_x = old_x + (@move_to_speed * x_component)
    new_y = old_y + (@move_to_speed * y_component)

    passed_x = ((new_x - @move_to_final_x) * (old_x - @move_to_final_x)) <= 0
    passed_y = ((new_y - @move_to_final_x) * (old_y - @move_to_final_y)) <= 0
    if (passed_x || passed_y)
      new_x = @move_to_final_x
      new_y = @move_to_final_y
      remove_ticker(:do_move)
    end
    set_attribute(:x, new_x)
    set_attribute(:y, new_y)
  end

  def change_map(map_name)
    self.set_attribute(:current_map, map_name)
    emit({object_id: self.id, message: :map_change, params: {name: map_name}})
  end

end