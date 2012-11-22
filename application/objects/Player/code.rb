class Player < GameObject
  def initialize(game)
    super(game)
    add_module("Displayable")
    add_module("Touchable")
    add_module("Interactive")

    add_attributes(:dx, :dy, :speed)
    set_attribute(:speed, 4.0)
    set_attribute(:dx, 0)
    set_attribute(:dy, 0)

    listen_for(:key_down, :key_down)
    listen_for(:key_up, :key_up)

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
      set_attribute(:dy, get_attribute(:dy) - 1)
    when Gosu::KbDown
      @dirs_moving << :down
      direction_ani
      set_attribute(:dy, get_attribute(:dy) + 1)
    when Gosu::KbLeft
      @dirs_moving << :left
      direction_ani
      set_attribute(:dx, get_attribute(:dx) - 1)
    when Gosu::KbRight
      @dirs_moving << :right
      direction_ani
      set_attribute(:dx, get_attribute(:dx) + 1)
    end
  end

  def key_up(key)
    case key
    when Gosu::KbUp
      @last_dir = :up
      @dirs_moving.delete(:up)
      direction_ani
      set_attribute(:dy, get_attribute(:dy) + 1)
    when Gosu::KbDown
      @last_dir = :down
      @dirs_moving.delete(:down)
      direction_ani
      set_attribute(:dy, get_attribute(:dy) - 1)
    when Gosu::KbLeft
      @last_dir = :left
      @dirs_moving.delete(:left)
      direction_ani
      set_attribute(:dx, get_attribute(:dx) + 1)
    when Gosu::KbRight
      @last_dir = :right
      @dirs_moving.delete(:right)
      direction_ani
      set_attribute(:dx, get_attribute(:dx) - 1)
    end
  end

  def direction_ani
    if (@dirs_moving.empty?)
      set_attribute(:current_image, "player_#{@last_dir.to_s}.png")
    else
      if !current_animation || current_animation.include?(@last_dir.to_s)
        set_animation("player_walk_#{@dirs_moving.last.to_s}")
      end
    end
  end

  def tick
    old_x = get_attribute(:x)
    old_y = get_attribute(:y)
    set_attribute(:x, old_x + (get_attribute(:dx) * (get_attribute(:speed) - (@dirs_moving.count / 1.3))))
    set_attribute(:y, old_y + (get_attribute(:dy) * (get_attribute(:speed) - (@dirs_moving.count / 1.3))))
  end

end