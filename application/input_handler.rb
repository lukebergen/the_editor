module InputHandler

  KEY_MAP = {}
  consts = Gosu.constants.select {|k| k[0..1] == "Kb" || k[0..1] == "Ms"}
  consts.each do |const|
    KEY_MAP[Gosu.const_get(const)] = const.to_sym
  end

  def self.included(klass)

    def button_down(id)
      if id == Gosu::KbEscape
        close
      end
      if id == Gosu::KbD
        do_debugger
      end
      if id == Gosu::KbK
        if (@game.mode == :play)
          @game.set_mode(:edit)
          @renderer = @edit_renderer
        else
          @game.set_mode(:play)
          @renderer = @play_renderer
        end
      end
      if id == Gosu::KbX
        @game.debugger_time = true
      end
      if id == Gosu::MsLeft
        @game
        obj = GameObject.spawn(@game, "Chair")
        obj.set_attributes(x: mouse_x, y: mouse_y)
      end
      @game.emit(message: :key_down, params: [InputHandler::KEY_MAP[id]])
    end

    def button_up(id)
      @game.emit(message: :key_up, params: [InputHandler::KEY_MAP[id]])
    end

  end
end