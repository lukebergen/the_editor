def init
  add_module("Displayable")
  add_module("Movable")
  add_module("Collidable")

  listen_for(:collide, :collide)

  @img_form = "chair.png"
  @ani_form = "player_walk_<dir>"

  def collide(other_object=nil)
    return true
  end

end
