class Chair < GameObject
  def initialize(game)
    super(game)
    add_module("Displayable")
  end
end