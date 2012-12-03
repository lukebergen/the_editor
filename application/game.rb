APPLICATION_DIR ||= "./application"
require File.join([APPLICATION_DIR, 'game_object'])
modules = Dir.glob(File.join([APPLICATION_DIR, 'go_modules', '**', '*.rb']))
modules.each do |filename|
  require filename
end

game_objects = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*', 'code.rb']))

class Game

  attr_accessor :objects, :current_map, :maps, :debugger_time

  def initialize(maps)
    @objects = load_game_objects
    @current_map = "dev_area0101"
    @maps = maps
    @debugger_time = false
  end

  def load_game_objects
    objects = []
    paths = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*']))
    paths.each do |path|
      obj = load_game_object(path)
      objects << obj
    end
    return objects
  end

  def load_game_object(path)
    name = File.basename(path)
    obj = GameObject.new(self, name)
    code = File.read(File.join([path, 'code.rb']))
    obj.code_string << code << "\n"
    obj.instance_eval(code)
    obj.init
    json = File.read(File.join([path, 'data.json']))
    hash = Utils.symbolize_keys(JSON::load(json))
    obj.attributes = obj.attributes.merge(hash)
    obj.post_json_init if obj.respond_to?(:post_json_init)
    return obj
  end

  def change_map(map_name)
    @current_map = map_name
  end

  def emit(hash, &block)
    message = hash[:message]
    params = hash[:params]
    object_name = hash[:object]
    last_result = nil
    @objects.each do |obj|
      next if object_name && obj.name != object_name
      if (obj.listens_for?(message))
        callback = obj.listeners[message]
        last_result = obj.send(callback, *params, &block)
      end
    end
    last_result
  end

  def tick
    tick_objects
  end

  def tick_objects
    @objects.each do |obj|
      if (obj.respond_to?(:tick))
        obj.tick
      end
    end
  end

end