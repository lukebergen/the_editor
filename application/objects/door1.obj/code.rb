class Code < GameObject
  def initialize
    add_module("Locationable")
    add_module("Touchable")
  end
end