APPLICATION_DIR ||= "./application"
require File.join([APPLICATION_DIR, 'game_object'])
modules = Dir.glob(File.join([APPLICATION_DIR, 'go_modules', '**', '*.rb']))
modules.each do |filename|
  require filename
end

class Game

  def initialize
    load_game_objects
    load_media
  end

  def tick

  end

  def load_game_objects
  end

  def load_media
  end
  
end