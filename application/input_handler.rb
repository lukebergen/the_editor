module InputHandler

  KEY_MAP = {}
  consts = Gosu.constants.select {|k| k[0..1] == "Kb" || k[0..1] == "Ms"}
  (consts - [:KbNum, :KbRangeBegin, :MsRangeBegin, :KbNum, :MsNum]).each do |const|
    KEY_MAP[Gosu.const_get(const)] = const.to_sym
  end

  def self.included(klass)

    def button_down(id)
      params = {key: InputHandler::KEY_MAP[id]}
      case id
        when Gosu::KbEscape
          clear_game_states
          close
          exit

        when Gosu::KbD
          @game.do_debugger

        when Gosu::KbK
          if (@game.mode == :play)
            @game.set_mode(:edit)
            # @renderer = @edit_renderer
            push_game_state $editing_state
          else
            @game.set_mode(:play)
            # @renderer = @play_renderer
            pop_game_state
          end

        when Gosu::KbX
          puts "for stuff"

        when Gosu::MsLeft
          obj = GameObject.spawn($window.game, "Chair")
          obj.set_attributes(x: $window.mouse_x, y: $window.mouse_y)
          # params[:mouse] = window_pos_to_game_pos(mouse_x, mouse_y)

        when Gosu::MsRight
          # params[:mouse] = window_pos_to_game_pos(mouse_x, mouse_y)

      end
      @game.emit(message: :key_down, params: params)
    end

    def button_up(id)
      params = {key: InputHandler::KEY_MAP[id]}
      case id
        when Gosu::MsLeft
          # params[:mouse] = window_pos_to_game_pos(mouse_x, mouse_y)

        when Gosu::MsRight
          # params[:mouse] = window_pos_to_game_pos(mouse_x, mouse_y)
      end
      @game.emit(message: :key_up, params: params)
    end

  end
end