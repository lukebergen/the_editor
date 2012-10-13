module InputHandler
  def self.included(klass)

    def button_down(id)
      if id == Gosu::KbEscape
        close
      end
      if id == Gosu::KbD
        do_debugger
      end
    end

  end
end