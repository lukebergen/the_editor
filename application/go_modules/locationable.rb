module Locationable

  def self.extended(klass)
    klass.add_attributes :x, :y, :z, :height, :width
  end

  def tile_x(false_x = nil)
    ((false_x || get_attribute(:x) || 0.0) / Constants::TILE_SIZE).floor
  end

  def tile_y(false_y = nil)
    ((false_y || get_attribute(:y) || 0.0) / Constants::TILE_SIZE).floor
  end

  def tile_width
    (get_attribute(:width) / Constants::TILE_SIZE).round
  end

  def tile_height
    (get_attribute(:height) / Constants::TILE_SIZE).round
  end
  
end