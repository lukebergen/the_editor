class Tileset

  attr_accessor :name, :tile_size, :tiles

  def initialize(window, path)
    json = File.read(File.join([path, "data.json"]))
    
    image_path = File.join([path, "tiles.png"])
    data = JSON.load(json)
    tile_images = Gosu::Image.load_tiles(window, image_path, data["tile_size"], data["tile_size"], true)
    arr = tile_images.group_by {|x| tile_images.index(x) / data["width"]}.values

    @name = data["name"]
    @tile_size = data["tile_size"]
    @tiles = arr
  end
end