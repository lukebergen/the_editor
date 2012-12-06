APPLICATION_DIR ||= File.join(['.', 'application'])
require File.join([APPLICATION_DIR, 'game_object'])
modules = Dir.glob(File.join([APPLICATION_DIR, 'go_modules', '**', '*.rb']))
modules.each do |filename|
  require filename
end

game_objects = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*', 'code.rb']))

class Game

  attr_accessor :objects, :current_map, :maps, :debugger_time

  def initialize(maps)
    @objects = []
    load_game_objects
    @current_map = "dev_area0101"
    @maps = maps
    @debugger_time = false
  end

  def load_game_objects
    paths = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*']))
    paths.each do |path|
      load_game_object_instances(path)
    end
  end

  def load_game_object_instances(path)
    name = File.basename(path)
    instances_path = File.join([path, 'instances', '*'])
    Dir.glob(instances_path).each do |inst_path|
      GameObject.spawn(self, name, inst_path)
    end
  end

  def save
    @objects.each do |obj|
      json_path = File.join([APPLICATION_DIR, 'objects', obj.name, 'instances', obj.id, 'data.json'])
      json = JSON::dump(obj.attributes)
      File.open(json_path, 'w') {|f| f.write(json)}
    end
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