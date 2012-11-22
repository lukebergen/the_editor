module InputHandler
  def self.included(klass)

    def button_down(id)
      if id == Gosu::KbEscape
        close
      end
      if id == Gosu::KbD
        do_debugger
      end
      @game.emit(:key_down, id)
    end

    def button_up(id)
      @game.emit(:key_up, id)
    end

  end
end