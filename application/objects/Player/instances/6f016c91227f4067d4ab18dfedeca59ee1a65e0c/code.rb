def init
  add_module("Displayable")
  add_module("Tickable")
  add_module("Movable")
  add_module("Collidable")

  add_attribute(:has_focus, true)

  listen_for(:key_down, :key_down)
  listen_for(:key_up, :key_up)
  listen_for(:map_change, :map_change)
  listen_for(:collide, :on_collide)

  @img_form = "player_<dir>.png"
  @ani_form = "player_walk_<dir>"

end

def post_json_init
  #set_animation("player_walk_down")
end

def on_collide(other=nil)
  return true
end

def key_down(params)
  key = params[:key]
  case key
  when :KbUp
    emit(object_id: self.id, message: :start_move, params: {dir: :up})
  when :KbDown
    emit(object_id: self.id, message: :start_move, params: {dir: :down})
  when :KbLeft
    emit(object_id: self.id, message: :start_move, params: {dir: :left})
  when :KbRight
    emit(object_id: self.id, message: :start_move, params: {dir: :right})
  when :KbSpace
    emit(object_name: 'Chair', message: :start_move, params: {dir: :right})
  end
end

def key_up(params)
  key = params[:key]
  case key
  when :KbUp
    emit(object_id: self.id, message: :stop_move, params: {dir: :up})
  when :KbDown
    emit(object_id: self.id, message: :stop_move, params: {dir: :down})
  when :KbLeft
    emit(object_id: self.id, message: :stop_move, params: {dir: :left})
  when :KbRight
    emit(object_id: self.id, message: :stop_move, params: {dir: :right})
  when :KbSpace
    emit(object_name: 'Chair', message: :stop_move, params: {dir: :right})
  end

  def map_change(params)
    map_name = params[:name]
    @game.change_map(map_name)
  end
end
