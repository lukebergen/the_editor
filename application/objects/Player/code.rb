def init
  add_module("Displayable")
  add_module("Touchable")
  add_module("Tickable")
  add_module("Movable")

  add_attribute(:has_focus, true)

  listen_for(:key_down, :key_down)
  listen_for(:key_up, :key_up)

  @img_form = "player_<dir>.png"
  @ani_form = "player_walk_<dir>"

end

def post_json_init
  #set_animation("player_walk_down")
end

def key_down(key)
  case key
  when :KbUp
    emit(:start_move, :up)
  when :KbDown
    emit(:start_move, :down)
  when :KbLeft
    emit(:start_move, :left)
  when :KbRight
    emit(:start_move, :right)
  end
end

def key_up(key)
  case key
  when :KbUp
    emit(:stop_move, :up)
  when :KbDown
    emit(:stop_move, :down)
  when :KbLeft
    emit(:stop_move, :left)
  when :KbRight
    emit(:stop_move, :right)
  end
end
