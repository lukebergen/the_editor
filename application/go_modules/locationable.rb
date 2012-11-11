module Locationable

  def self.extended(klass)
    klass.add_attributes :x, :y, :z, :height, :width
  end
  
end