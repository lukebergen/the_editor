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

  attr_accessor :objects

  def initialize
    @objects = load_game_objects
  end

  def load_game_objects
    go = GameObject.new
    go.add_module("Displayable")
    go.attributes[:current_image] = "chair.png"
    go.attributes[:x] = 20
    go.attributes[:y] = 20

    objects = []
    paths = Dir.glob(File.join([APPLICATION_DIR, 'objects', '*']))
    paths.each do |path|
      klass = Utils.constantize(File.basename(path))
      obj = klass.new
      yaml = File.read(File.join([path, 'data.yml']))
      hash = YAML::load(yaml)
      obj.attributes = go.attributes.merge(hash)
      objects << obj
    end

    return objects
  end

  def tick

  end

end