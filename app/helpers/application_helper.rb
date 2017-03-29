module ApplicationHelper
  include CacheRocket

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def unread_badge(resource)
    render "unread_badge", :resource => resource #if any_content
  end

  def marketplace_url
    @marketplace_url ||=  current_user.channel_partner.try(:marketplace_url) ? 
                          current_user.channel_partner.try(:marketplace_url) : 
                          "https://www.appdirect.com"
  end

  def author_name_by_id(id)
    begin
      User.find(id).name
    rescue
      return id
    end
  end

  def datetime_to_date(datetime, output_tag = false, format = :long_ordinal)
    dt = datetime.to_date.to_s format
    output_tag ? "<time datetime='#{datetime.to_date.to_s :db}'>#{dt}</time>" : dt
  end

  def current_pdf_translations
    I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale][:pdf]
  end

  def color_to(color, value)
    require 'color'
    c = Color::RGB.from_html(color)
    c.lighten_by(value).html
  end

  def magick image_url, options = {}
    #In case we accidentally pass ":size" as a key:
    if options.keys.include? :size
      options[:resize] = options[:size]
      options.delete(:size) 
    end
    unless options[:allow_upscale].blank? == true and options.keys.include? :resize == true
      # Append a '>' to signify we don't want to scale up if the image isn't bigger than the requested size.
      # Without that '>', Dragonfly/ImageMagick will just size it on up, blurriness and all.
      options[:resize] = "#{options[:resize].to_s}"
      options.delete(:allow_upscale)
    end
    options[:output] = options.map { |k, v| "&#{k}=#{v}" }.join
    "/magickly/?src=#{image_url}#{options[:output]}"
  end

  def avatar_for user, options = {}
    options = {:alt => 'avatar', :class => 'avatar', :size => 28 }.merge! options
    # does the user already have an avatar in the system?
    return image_tag magick(user.avatar, resize: options[:size]), options unless user.avatar.blank?
    # otherwise use gravatar
    id = Digest::MD5::hexdigest user.email.strip.downcase
    url = '//www.gravatar.com/avatar/' + id + '.jpg?s=' + options[:size].to_s + '&d=identicon'
    image_tag url, options
  end

  def release_period release
    { :class => release_period_class(release), :label => release_period_label(release) }
  end

  def release_period_label release
    "#{release.release_type.to_s.titleize} Release"
  end

  def release_period_class release
    release.release_type
  end

  def yield_content!(content_key)
    view_flow.content.delete(content_key)
  end

  def current_layout
    layout = controller.send(:_layout)
    if layout.instance_of? String
      layout
    else
      File.basename(layout.identifier).split('.').first
    end
  end

end
