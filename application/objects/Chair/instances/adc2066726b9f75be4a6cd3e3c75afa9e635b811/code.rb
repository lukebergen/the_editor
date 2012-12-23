def init
  add_module("Displayable")
  add_module("Movable")
  add_module("Collidable")

  listen_for(:collide, :collide)

  @img_form = "chair.png"
  @ani_form = "player_walk_<dir>"

  def collide(params)
    other_id = params[0]
    other_object = @game.object(other_id)

    # returns true if the result of the collision (for the other object) is "I am blocking you"
    return true
  end

end
