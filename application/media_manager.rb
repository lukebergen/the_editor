class MediaManager
  MEDIA_DIR = "#{APPLICATION_DIR}/media"

  attr_accessor :images

  def initialize(window)
    @window = window
    @images = load_images
    @animations = load_animations
  end

  def load_images
    image_hash = {}
    image_paths = Dir.glob("#{MEDIA_DIR}/images/*")
    image_paths.each do |path|
      key = File.basename(path)
      img = Gosu::Image.new(@window, path)
      image_hash[key] = img
    end
    image_hash
  end

  def load_animations
    {}
  end
end