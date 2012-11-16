class Door1 < GameObject
  def initialize
    super
    add_module("Displayable")
    add_module("Touchable")
  end
end