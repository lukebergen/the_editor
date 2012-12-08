module InputHandler

  KEY_MAP = {}
  consts = Gosu.constants.select {|k| k[0..1] == "Kb" || k[0..1] == "Ms"}
  consts.each do |const|
    KEY_MAP[Gosu.const_get(const)] = const.to_sym
  end

  def self.included(klass)

    def button_down(id)
      params = {key: InputHandler::KEY_MAP[id]}
      case id
        when Gosu::KbEscape
          close

        when Gosu::KbD
          do_debugger

        when Gosu::KbK
          if (@game.mode == :play)
            @game.set_mode(:edit)
            @renderer = @edit_renderer
          else
            @game.set_mode(:play)
            @renderer = @play_renderer
          end

        when Gosu::KbX
          @game.debugger_time = true

        when Gosu::MsLeft
          params[:mouse] = {x: mouse_x, y: mouse_y}

        when Gosu::MsRight
          params[:mouse] = {x: mouse_x, y: mouse_y}

      end
      @game.emit(message: :key_down, params: params)
    end

    def button_up(id)
      @game.emit(message: :key_up, params: {key: InputHandler::KEY_MAP[id]})
    end

  end
end