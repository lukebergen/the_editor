class Tileset

  attr_accessor :name, :tile_size, :tiles

  def initialize(name, tile_size, tiles)
    @name = name
    @tile_size = tile_size
    @tiles = tiles
  end
end