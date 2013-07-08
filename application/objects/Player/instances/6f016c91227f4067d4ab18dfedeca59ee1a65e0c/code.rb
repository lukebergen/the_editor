def init
  add_module("Displayable")
  add_module("Tickable")
  add_module("Movable")
  add_module("Collidable")

  add_attribute(:has_focus, true)

  listen_for(:key_down, :key_down)
  listen_for(:key_up, :key_up)
  listen_for(:collide, :on_collide)
  listen_for(:map_change, :map_change)

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
    emit(message: :start_move, params: {dir: :up, object_id: self.id})
  when :KbDown
    emit(message: :start_move, params: {dir: :down, object_id: self.id})
  when :KbLeft
    emit(message: :start_move, params: {dir: :left, object_id: self.id})
  when :KbRight
    emit(message: :start_move, params: {dir: :right, object_id: self.id})
  when :KbSpace
    emit(message: :start_move, params: {dir: :right, object_name: 'Chair'})
  end
end

def key_up(params)
  key = params[:key]
  case key
  when :KbUp
    emit(message: :stop_move, params: {dir: :up, object_id: self.id})
  when :KbDown
    emit(message: :stop_move, params: {dir: :down, object_id: self.id})
  when :KbLeft
    emit(message: :stop_move, params: {dir: :left, object_id: self.id})
  when :KbRight
    emit(message: :stop_move, params: {dir: :right, object_id: self.id})
  when :KbSpace
    emit(message: :stop_move, params: {dir: :right, object_name: 'Chair'})
  end
end

def map_change(params)
  return unless about_me?(params)
  map_name = params[:name]
  @game.change_map(map_name)
end
