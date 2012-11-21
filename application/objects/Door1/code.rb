class Door1 < GameObject
  def initialize
    super
    add_module("Displayable")
    add_module("Touchable")
  end

  def post_json_init
    set_animation("player_walk_down")
  end
end