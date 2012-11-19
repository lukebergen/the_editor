require 'json'

class Map
  attr_accessor :name, :height, :width, :tileset, :tile_size, :tiles
  def initialize(json=nil)
    # based on the json, create
    if json
      map_hash = JSON.load(json)
      @name = map_hash["name"]
      @height = map_hash["height"]
      @width = map_hash["width"]
      @tiles = map_hash["tiles"]
      @tileset = map_hash["tileset"]
    end
  end
end