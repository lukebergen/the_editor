module Interactive

  def self.extended(klass)
  end

  def listen_for(event, callback)
    @listeners[event] = callback
  end

  def emit(event, *args, &block)
    if (@game)
      @game.emit(event, *args, &block)
    end
  end

end