class MediaManager
  MEDIA_DIR = File.join(["#{APPLICATION_DIR}", 'media'])
  TILESETS_DIR = File.join(["#{APPLICATION_DIR}", 'tilesets'])
  MAPS_DIR = File.join(["#{APPLICATION_DIR}", 'maps'])
  ANIMATION_DIR = File.join(["#{MEDIA_DIR}", 'animations'])

  attr_accessor :images, :animations, :tilesets, :maps

  def initialize(window)
    @window = window
    @images = load_images
    @animations = load_animations
    @tilesets = load_tilesets
    @maps = load_maps
  end

  def load_images
    image_hash = {}
    image_paths = Dir.glob(File.join(["#{MEDIA_DIR}", 'images', '*']))
    image_paths.each do |path|
      key = File.basename(path)
      img = Gosu::Image.new(@window, path)
      image_hash[key] = img
    end
    image_hash
  end

  def load_animations
    animation_hash = {}
    animation_paths = Dir.glob(File.join(["#{ANIMATION_DIR}", '*']))
    animation_paths.each do |path|
      key = File.basename(path)
      animation_hash[key] = Animation.new(@window, path)
    end
    animation_hash
  end

  def load_tilesets
    tileset_hash = {}
    tileset_paths = Dir.glob(File.join(["#{TILESETS_DIR}", '*']))
    tileset_paths.each do |path|
      ts = Tileset.new(@window, path)
      tileset_hash[ts.name] = ts
    end
    tileset_hash
  end

  def load_maps
    map_hash = {}
    map_paths = Dir.glob(File.join(["#{MAPS_DIR}", '*.map']))
    map_paths.each do |path|
      map_json = File.read(path)
      map = Map.new(map_json)
      map_hash[map.name] = map
    end
    map_hash
  end

end