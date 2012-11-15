APPLICATION_DIR ||= "./application"
require File.join([APPLICATION_DIR, 'game_object'])
modules = Dir.glob(File.join([APPLICATION_DIR, 'go_modules', '**', '*.rb']))
modules.each do |filename|
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
    return [go]
  end

  def tick

  end

end