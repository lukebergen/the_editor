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
      obj.save
    end
  end

  def object(identifier)
    if (GameObject.is_id?(identifier))
      objects = @objects.select {|x| x.id == identifier}
      return objects.first
    else
      return @objects.select {|x| x.name == identifier}
    end
  end

  def emit(hash, &block)
    if (@mode == :play)
      emit_to_objects(hash, &block)
    else
      handle_edit_message(hash)
    end
  end

  def tick
    if (@mode == :play)
      tick_objects
    end
  end

  def do_debugger
    debugger
    noop = nil
  end

end