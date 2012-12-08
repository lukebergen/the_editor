APPLICATION_DIR ||= File.join(['.', 'application'])
require File.join([APPLICATION_DIR, 'game_object'])
modules = Dir.glob(File.join([APPLICATION_DIR, 'go_modules', '**', '*.rb']))
modules.each do |filename|
  require filename
end

game_objects = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*', 'code.rb']))

class Game

  include GameHelper

  attr_accessor :objects, :current_map, :maps, :debugger_time, :mode

  def initialize(maps)
    @objects = []
    load_game_objects
    @current_map = "dev_area0101"
    @maps = maps
    @debugger_time = false
    @mode = :play
  end

  def load_game_objects
    paths = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*']))
    paths.each do |path|
      load_game_object_instances(path)
    end
  end

  def save
    @objects.each do |obj|
      json_path = File.join([APPLICATION_DIR, 'objects', obj.name, 'instances', obj.id, 'data.json'])
      json = JSON::dump(obj.attributes)
      File.open(json_path, 'w') {|f| f.write(json)}
    end
  end

  def emit(hash, &block)
    if (@mode == :play)
      emit_to_objects(hash, &block)
    else
      handle_edit_input(hash)
    end
  end

  def tick
    if (@mode == :play)
      tick_objects
    end
  end

end