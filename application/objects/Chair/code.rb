def init
  add_module("Displayable")
  add_module("Movable")

  @img_form = "chair.png"
  @ani_form = "player_walk_<dir>"

  def on_hit(other_object)

  end

end
