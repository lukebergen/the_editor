module InputHandler
  def self.included(klass)

    def button_down(id)
      if id == Gosu::KbEscape
        close
      end
    end

  end
end