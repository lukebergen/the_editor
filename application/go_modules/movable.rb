module Movable

  REQUIRES = ['Tickable', 'Locationable']

  def self.extended(klass)
    klass.add_attribute(:dir, :down)
    klass.instance_eval do
      listen_for(:start_move, :start_move)
      listen_for(:stop_move, :stop_move)
      add_ticker(:move)
      add_ticker(:check_edge_hit)
      @speed = 10.0
      @dx = 0
      @dy = 0
      @dirs_moving = []
      @last_dir = :down
      @ani_form = "#{self.class.to_s}_<dir>"
      @img_form = "#{self.class.to_s}_<dir>.png"
    end
  end

  def start_move(dir)
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

  def stop_move(dir)
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
    set_attribute(:x, old_x + (@dx * (@speed - (@dirs_moving.count / 1.3))))
    set_attribute(:y, old_y + (@dy * (@speed - (@dirs_moving.count / 1.3))))
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
    @game.edge_hit(self, dir, on_world_edge: :stop)
  end

end