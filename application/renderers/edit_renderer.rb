class EditRenderer < Renderer::Base

  def initialize(window)
    super(window)
    @code_string_font = Gosu::Font.new(window, Gosu::default_font_name, Constants::CODE_FONT_SIZE)
    @code_string_objects = {}
  end

  def paint(game)
    super(game)
    render_side_bar
  end

  def tick(game)
    game.objects.each do |obj|
      unless @code_string_objects[obj.id]
        @code_string_objects[obj.id] = {}
        lines = str_to_lines(obj.code_string, obj.get_attribute(:width))
        speed = lines.count / 20.0
        @code_string_objects[obj.id][:lines] = lines
        @code_string_objects[obj.id][:speed] = speed
        @code_string_objects[obj.id][:height] = speed
      end
      @code_string_objects[obj.id][:height] -= @code_string_objects[obj.id][:speed]
      if (@code_string_objects[obj.id][:lines].count * Constants::CODE_FONT_SIZE * -1 > @code_string_objects[obj.id][:height] - obj.get_attribute(:height))
        @code_string_objects[obj.id][:height] = 0
      end
    end
  end

  def render_object(go, x, y, z)
    z = z == 0 ? -1 : -1 / z.to_f
    height = go.attributes[:height]
    width = go.attributes[:width]
    lines = @code_string_objects[go.id][:lines] || []
    height_offset = @code_string_objects[go.id][:height] || 0
    window.clip_to(x, y, width, height) do
      lines.each_with_index do |line, i|
        @code_string_font.draw(line, x, y + (i * Constants::CODE_FONT_SIZE) + height_offset, z, 1, 1, Gosu::Color::BLACK)
      end
    end
  end

  def str_to_lines(str, width)
    lines = []
    temp = ''
    str.each_char do |char|
      next if char == $/
      temp << char
      if @code_string_font.text_width(temp) > width
        lines << temp
        temp = ''
      end
    end
    lines
  end

  def render_world
  end
  
  def render_side_bar
  end

end