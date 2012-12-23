class EditView < Fidgit::GuiState
  def initialize(game, renderer)
    super()
    @game = game
    @renderer = renderer
    draw_side_bar
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
    when Gosu::MsLeft
      objects = $window.game_objects_at($window.mouse_x, $window.mouse_y)
      object = objects.sort_by do |obj|
        z = obj.get_attribute(:z)
        z = z.to_f if z
        z ||= -1000
      end.first
      @my_label.text = object.name if object
    when Gosu::KbK
      @game.set_mode(:play)
      pop_game_state
    when Gosu::KbX
      
    else
      super(id)
    end
  end

  def draw_side_bar
    vertical align_h: :right, alighn_h: :top do
      scroll_window(
        width: 400,
        height: $window.height,
        background_color: Gosu::Color::BLACK,
        align_h: :right
        ) do
          # Create a label with a dark green background.
        @my_label = label "Hello world!", background_color: Gosu::Color::BLACK

        # Create a button that, when clicked, changes the label text.
        button("Goodbye", align_h: :center, tip: "Press me and be done with it!") do
          my_label.text = "#{$window.height}"
        end
      end
    end
  end

end