APPLICATION_DIR ||= "./application"
require File.join([APPLICATION_DIR, 'game_object'])
modules = Dir.glob(File.join([APPLICATION_DIR, 'go_modules', '**', '*.rb']))
modules.each do |filename|
  require filename
end

game_objects = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*', 'code.rb']))
game_objects.each do |filename|
  require filename
end

class Game

  attr_accessor :objects, :current_map

  def initialize
    @objects = load_game_objects
    @current_map = "dev_area"
  end

  def load_game_objects
    objects = []
    paths = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*']))
    paths.each do |path|
      klass = Utils.constantize(File.basename(path))
      obj = klass.new(self)
      json = File.read(File.join([path, 'data.json']))
      hash = JSON::load(json).inject({}) {|h, (k,v)| h[k.to_sym] = v; h}
      obj.attributes = obj.attributes.merge(hash)
      obj.post_json_init if obj.respond_to?(:post_json_init)
      objects << obj
    end

    return objects
  end

  def emit(message, *args, &block)
    @objects.each do |obj|
      if (obj.listeners.has_key?(message))
        callback = obj.listeners[message]
        obj.send(callback, *args, &block)
      end
    end
  end

  def tick
    @objects.each do |obj|
      if (obj.respond_to?(:tick))
        obj.tick
      end
    end
  end

end