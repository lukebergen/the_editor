class PlayRenderer < Renderer::Base

  def initialize(window)
    super(window)
  end

  def paint(game)
    super(game)
    render_world
  end

  def tick(game)
    super(game)
    media_manager.animations.values.each do |ani|
      ani.tick
    end
    update_focus(game)
  end

  def render_object(go, x, y, z)
    height = go.attributes[:height]
    width = go.attributes[:width]
    img_src = go.attributes[:current_image]
    if (img_src.include?(':'))
      split = img_src.split(':')
      current_image = media_manager.animations[split[0]].current_image(split[1])
    else
      current_image = media_manager.images[go.attributes[:current_image]]
    end
    if (x && y && current_image)
      fx = fy = 1
      if (height || width)
        fx, fy = stretch_factor(current_image, height, width)
      end
      #puts "drawing: #{go.id}: #{x}, #{y}, #{z}"
      current_image.draw(x, y, z, fx, fy)
    end
  end

  def update_focus(game)

    focus_object = game.objects.select do |obj|
      obj.has_attribute?(:has_focus) && obj.get_attribute(:has_focus)
    end.first

    return unless focus_object

    center_x = window.width / 2.0
    center_y = window.height / 2.0

    has_left     = !(@@neighbors[0][0] || @@neighbors[1][0] || @@neighbors[2][0]).nil?
    has_top      = !(@@neighbors[0][0] || @@neighbors[0][1] || @@neighbors[0][2]).nil?
    has_right    = !(@@neighbors[0][2] || @@neighbors[1][2] || @@neighbors[2][2]).nil?
    has_bottom   = !(@@neighbors[2][0] || @@neighbors[2][1] || @@neighbors[2][2]).nil?

    # set focus assuming there's a neighbor, then reset it to center if no neighbor
    fx = focus_object.get_attribute(:x)
    fy = focus_object.get_attribute(:y)
    @@focus[0] = fx #center_x - (fx - center_x)
    @@focus[1] = fy #center_y - (fy - center_y)

    if (fx < center_x && !has_left)
      @@focus[0] = center_x
    end
    if (fx > (1024 - center_x) && !has_right)
      @@focus[0] = (1024 - center_x)
    end
    if (fy < center_y && !has_top)
      @@focus[1] = center_y
    end
    if (fy > (1024 - center_y) && !has_bottom)
      @@focus[1] = (1024 - center_y)
    end
  end

  def render_world
    @world.draw((window.width / 2.0) - @@focus[0], (window.height / 2.0) - @@focus[1], Constants::Z_POSITIONS[:top_tile])
  end

end