class Player < GameObject
  def initialize(game)
    super(game)
    add_module("Displayable")
    add_module("Touchable")
    add_module("Interactive")
    add_module("Tickable")
    add_module("Movable")

    add_attribute(:has_focus, true)

  end

  def post_json_init
    #set_animation("player_walk_down")
  end

end