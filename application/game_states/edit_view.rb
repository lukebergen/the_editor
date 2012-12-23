class EditView < Fidgit::GuiState
  def initialize(game, renderer)
    super()
    @game = game
    @renderer = renderer
    @edit_font = Gosu::Font.new($window, "", 25)
    @obj_attributes = []
    (0..64).each {@obj_attributes << {}}
    draw_side_bar
  end

  def setup
    super
    update_side_bar_with(@current_object) if @current_object
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
      if (object)
        @current_object = object
        update_side_bar_with(object)
      else
        super(id)
      end
    when Gosu::KbK
      close_edit_mode
    when Gosu::KbX
      @obj_attributes[0][:input].text = "test"
    else
      super(id)
    end
  end

  def update_side_bar_with(object)
    @object_id_label.text = object.get_attribute(:id)
    @object_name_label.text = object.name
    clear_obj_attributes
    n = 0
    object.attributes.each do |key, value|
      key = key.to_s
      next if ['name', 'id', ''].include?(key)
      value = 'nil' unless value
      @obj_attributes[n][:label].text = key
      @obj_attributes[n][:input].text = value
      @obj_attributes[n][:original_class] = value.class
      n += 1
    end
  end

  def clear_obj_attributes
    @obj_attributes.each do |h|
      h[:label].text = ''
      h[:input].text = ''
    end
  end

  def draw_side_bar
    vertical align_h: :right, alighn_h: :top do
      scroll_window(
        width: 400,
        height: $window.height - 100,
        background_color: Gosu::Color::BLACK,
        align_h: :right
        ) do
        @object_id_label = label 'test', background_color: Gosu::Color::BLACK, font_height: 18
        @object_name_label = label "test", background_color: Gosu::Color::BLACK, font_height: 25

        @obj_attributes.each do |attr_hash|
          attr_hash[:label] = label '', background_color: Gosu::Color::BLACK, font_height: 20
          attr_hash[:input] = text_area text: '', width: 300, editable: true, font: @edit_font
        end
      end
      horizontal do
        button "Save" do
          close_edit_mode(with_save: true)
        end
        button "Close" do
          close_edit_mode
        end
      end
    end
  end

  def close_edit_mode(opts = {})
    opts = {with_save: false}.merge(opts)
    if (opts[:with_save] && @current_object)
      @obj_attributes.each do |attr_hash|
        key = attr_hash[:label].text.to_sym
        value = attr_hash[:input].text
        if (attr_hash[:original_class] == Symbol)
          value = value.to_sym
        elsif (attr_hash[:original_class] == Fixnum)
          value = value.to_i
        elsif (attr_hash[:original_class] == Float)
          value = value.to_f
        end
        value = nil if value == 'nil'
        @current_object.set_attribute(key, value)
      end
    end
    @game.set_mode(:play)
    pop_game_state
  end

end