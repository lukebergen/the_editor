module Locationable

  def extended(klass)
    add_attributes :x, :y, :z, :height, :width
  end
  
end