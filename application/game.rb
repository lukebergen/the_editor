APPLICATION_DIR ||= "./application"
require File.join([APPLICATION_DIR, 'game_object'])
modules = Dir.glob(File.join([APPLICATION_DIR, 'go_modules', '**', '*.rb']))
modules.each do |filename|
  require filename
end

game_objects = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*', 'code.rb']))

class Game

  attr_accessor :objects, :current_map, :maps

  def initialize(maps)
    @objects = load_game_objects
    @current_map = "dev_area"
    @maps = maps
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

  def edge_hit(object, dir, options)
    options = {on_world_edge: :destroy}.merge(options)
    map = @maps[@current_map]
    case dir
    when :left
      if (map.neighbors[:left])
        object.set_attribute(:x, Constants::MAP_WIDTH) # - object.get_attribute(:width))
        object.set_attribute(:current_map, map.neighbors[:left])
        change_map(map.neighbors[:left])
      else
        if (options[:on_world_edge] == :stop)
          object.set_attribute(:x, 0)
        elsif (options[:on_world_edge] == :destroy)
          @objects.delete(object)
        end
      end
    when :top
      if (map.neighbors[:top])
        object.set_attribute(:y, Constants::MAP_HEIGHT) # - object.get_attribute(:height))
        object.set_attribute(:current_map, map.neighbors[:top])
        change_map(map.neighbors[:top])
      else
        if (options[:on_world_edge] == :stop)
          object.set_attribute(:y, 0)
        elsif (options[:on_world_edge] == :destroy)
          @objects.delete(object)
        end
      end
    when :right
      if (map.neighbors[:right])
        object.set_attribute(:x, 0)
        object.set_attribute(:current_map, map.neighbors[:right])
        change_map(map.neighbors[:right])
      else
        if (options[:on_world_edge] == :stop)
          object.set_attribute(:x, Constants::MAP_WIDTH) # - object.get_attribute(:width))
        elsif (options[:on_world_edge] == :destroy)
          @objects.delete(object)
        end
      end
    when :bottom
      if (map.neighbors[:bottom])
        object.set_attribute(:y, 0)
        object.set_attribute(:current_map, map.neighbors[:bottom])
        change_map(map.neighbors[:bottom])
      else
        if (options[:on_world_edge] == :stop)
          object.set_attribute(:y, Constants::MAP_HEIGHT) # - object.get_attribute(:height))
        elsif (options[:on_world_edge] == :destroy)
          @objects.delete(object)
        end
      end
    end
  end

  def change_map(map_name)
    @current_map = map_name
  end

  def emit(message, *args, &block)
    @objects.each do |obj|
      if (obj.listens_for?(message))
        callback = obj.listeners[message]
        obj.send(callback, *args, &block)
      end
    end
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