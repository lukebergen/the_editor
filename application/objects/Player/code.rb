class Player < GameObject
  def initialize(game)
    super(game)
    add_module("Displayable")
    add_module("Touchable")
    add_module("Interactive")

    add_attributes(:dx, :dy, :speed)
    set_attribute(:speed, 3.0)
    set_attribute(:dx, 0)
    set_attribute(:dy, 0)

    listen_for(:key_down, :key_down)
    listen_for(:key_up, :key_up)

    @dir_keys_down = 0
  end

  def post_json_init
    #set_animation("player_walk_down")
  end

  def key_down(key)
    case key
    when Gosu::KbUp
      @dir_keys_down += 1
      set_animation('player_walk_up')
      set_attribute(:dy, get_attribute(:dy) - 1)
    when Gosu::KbDown
      @dir_keys_down += 1
      set_animation('player_walk_down')
      set_attribute(:dy, get_attribute(:dy) + 1)
    when Gosu::KbLeft
      @dir_keys_down += 1
      set_animation('player_walk_left')
      set_attribute(:dx, get_attribute(:dx) - 1)
    when Gosu::KbRight
      @dir_keys_down += 1
      set_animation('player_walk_right')
      set_attribute(:dx, get_attribute(:dx) + 1)
    end
  end

  def key_up(key)
    case key
    when Gosu::KbUp
      @dir_keys_down -= 1
      set_image('player_up.png') if @dir_keys_down == 0
      set_attribute(:dy, get_attribute(:dy) + 1)
    when Gosu::KbDown
      @dir_keys_down -= 1
      set_image('player_down.png') if @dir_keys_down == 0
      set_attribute(:dy, get_attribute(:dy) - 1)
    when Gosu::KbLeft
      @dir_keys_down -= 1
      set_image('player_left.png') if @dir_keys_down == 0
      set_attribute(:dx, get_attribute(:dx) + 1)
    when Gosu::KbRight
      @dir_keys_down -= 1
      set_image('player_right.png') if @dir_keys_down == 0
      set_attribute(:dx, get_attribute(:dx) - 1)
    end
  end

  def tick
    old_x = get_attribute(:x)
    old_y = get_attribute(:y)
    set_attribute(:x, old_x + (get_attribute(:dx) * get_attribute(:speed)))
    set_attribute(:y, old_y + (get_attribute(:dy) * get_attribute(:speed)))
  end

end