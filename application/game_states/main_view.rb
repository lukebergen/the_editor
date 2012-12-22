class MainView < Fidgit::GuiState

  include InputHandler

  def initialize(game, renderer)
    @game = game
    @renderer = renderer
  end

  def update
    @game.tick
    @renderer.tick(@game)
    @fps = "fps: #{Gosu::fps}"
  end

  def draw
    @renderer.paint(@game)
    @renderer.draw_text(@fps)
  end

end