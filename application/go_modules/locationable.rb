module Locationable

  def self.extended(klass)
    klass.add_attributes :x, :y, :z, :height, :width
  end

  def tile_x
    (get_attribute(:x) / Constants::TILE_SIZE).round
  end

  def tile_y
    (get_attribute(:y) / Constants::TILE_SIZE).round
  end

  def tile_width
    (get_attribute(:width) / Constants::TILE_SIZE).round
  end

  def tile_height
    (get_attribute(:height) / Constants::TILE_SIZE).round
  end
  
end