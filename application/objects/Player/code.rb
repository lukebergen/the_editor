def init
  add_module("Displayable")
  add_module("Touchable")
  add_module("Tickable")
  add_module("Movable")
  add_module("Collidable")

  add_attribute(:has_focus, true)

  listen_for(:key_down, :key_down)
  listen_for(:key_up, :key_up)
  listen_for(:map_change, :map_change)

  @img_form = "player_<dir>.png"
  @ani_form = "player_walk_<dir>"

end

def post_json_init
  #set_animation("player_walk_down")
end

def key_down(key)
  case key
  when :KbUp
    emit(object: 'Player', message: :start_move, params: [:up])
  when :KbDown
    emit(object: 'Player', message: :start_move, params: [:down])
  when :KbLeft
    emit(object: 'Player', message: :start_move, params: [:left])
  when :KbRight
    emit(object: 'Player', message: :start_move, params: [:right])
  when :KbSpace
    emit(object: 'Chair', message: :start_move, params: [:right])
  end
end

def key_up(key)
  case key
  when :KbUp
    emit(object: 'Player', message: :stop_move, params: [:up])
  when :KbDown
    emit(object: 'Player', message: :stop_move, params: [:down])
  when :KbLeft
    emit(object: 'Player', message: :stop_move, params: [:left])
  when :KbRight
    emit(object: 'Player', message: :stop_move, params: [:right])
  when :KbSpace
    emit(object: 'Chair', message: :stop_move, params: [:right])
  end

  def map_change(map_name)
    @game.change_map(map_name)
  end
end
