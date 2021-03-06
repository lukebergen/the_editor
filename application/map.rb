require 'json'

class Map
  attr_accessor :name, :height, :width, :tileset, :tile_size, :tiles, :neighbors
  def initialize(json=nil)
    # based on the json, create
    if json
      map_hash = JSON.load(json)
      @name = map_hash["name"]
      @height = map_hash["height"] || 64
      @width = map_hash["width"] || 64
      @tiles = map_hash["tiles"] || (0...64).map{[]}
      @tileset = map_hash["tileset"] || "tiles"
      @neighbors = Utils.symbolize_keys(map_hash["neighbors"] || {})
    end
  end

  def to_json
    h = {}
    h["name"] = @name
    h["height"] = @height
    h["width"] = @width
    h["tiles"] = @tiles
    h["tileset"] = @tileset
    h["neighbors"] = @neighbors
    JSON.dump(h)
  end

  def blocked?(coordinates)
    coordinates.each do |point|
      next if @tiles[point[0]].nil? || @tiles[point[0]][point[1]].nil?
      return point if @tiles[point[1]][point[0]][4] == 1
    end
    return false
  end

end