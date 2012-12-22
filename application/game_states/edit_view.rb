class EditView < Fidgit::GuiState
  def initialize(game, renderer)
    super()
    @game = game
    @renderer = renderer

  end

  def update
    @game.tick
    @renderer.tick(@game)
    @fps = "fps: #{Gosu::fps}"
    super()
  end

  def draw
    @renderer.paint(@game)
    @renderer.draw_text(@fps)
    super()
  end

  def button_down(id)
    case id
    when Gosu::KbK
      @game.set_mode(:play)
      pop_game_state
    when Gosu::KbX
      vertical align: :center do
        # Create a label with a dark green background.
        my_label = label "Hello world!", background_color: Gosu::Color::BLACK

        # Create a button that, when clicked, changes the label text.
        button("Goodbye", align_h: :center, tip: "Press me and be done with it!") do
          my_label.text = "Goodbye cruel world!"
        end
      end
    else
      super(id)
    end
  end

end