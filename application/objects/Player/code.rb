class Player < GameObject
  def initialize(game)
    super(game)
    add_module("Displayable")
    add_module("Touchable")
    add_module("Interactive")
    add_module("Tickable")

    add_attribute(:has_focus, true)
    add_attribute(:dir, :down)

    @speed = 10.0
    @dx = 0
    @dy = 0

    listen_for(:key_down, :key_down)
    listen_for(:key_up, :key_up)

    add_ticker(:move)
    add_ticker(:check_edge_hit)

    @dirs_moving = []
    @last_dir = :down
  end

  def post_json_init
    #set_animation("player_walk_down")
  end

  def key_down(key)
    case key
    when Gosu::KbUp
      @dirs_moving << :up
      direction_ani
      @dy -= 1
    when Gosu::KbDown
      @dirs_moving << :down
      direction_ani
      @dy += 1
    when Gosu::KbLeft
      @dirs_moving << :left
      direction_ani
      @dx -= 1
    when Gosu::KbRight
      @dirs_moving << :right
      direction_ani
      @dx += 1
    end
  end

  def key_up(key)
    case key
    when Gosu::KbUp
      set_attribute(:dir, :up)
      @dirs_moving.delete(:up)
      direction_ani
      @dy += 1
    when Gosu::KbDown
      set_attribute(:dir, :down)
      @dirs_moving.delete(:down)
      direction_ani
      @dy -= 1
    when Gosu::KbLeft
      set_attribute(:dir, :left)
      @dirs_moving.delete(:left)
      direction_ani
      @dx += 1
    when Gosu::KbRight
      set_attribute(:dir, :right)
      @dirs_moving.delete(:right)
      direction_ani
      @dx -= 1
    end
  end

  def direction_ani
    if (@dirs_moving.empty?)
      set_attribute(:current_image, "player_#{get_attribute(:dir).to_s}.png")
    else
      if !current_animation || current_animation.include?(get_attribute(:dir).to_s)
        set_animation("player_walk_#{@dirs_moving.last.to_s}")
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