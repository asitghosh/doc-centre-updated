class Api < Page
  #include Pdfable

  attr_accessor :active_admin_requested_event_api
  has_many :annotations, foreign_key: "page_id"
  
  mapping = {
              api: {
                dynamic_templates: [
                  { content: {
                      match: "*_content",
                      match_mapping_type: "string",
                      mapping: {
                        type: "string",
                        analyzer: "snowball",
                        index: "analyzed"
                      }
                  }}
                ],
                properties: {
                  title: { type: "string", analyzer: "snowball", index: "analyzed" },
                  permalink: { type: "string", analyzer: "keyword", index: "not_analyzed" },
                  public_content: { type: "string", analyzer: "snowball", index: "analyzed" },
                  date: { type: "date" },
                  book: { type: "string", analyzer: "keyword", index: "analyzed" }
                }
              }
            }

  searchkick merge_mappings: true, mappings: mapping, index_name: "apis_#{Rails.env}"
  def headline
    "Documentation"
  end

  def friendly_title
    title
  end

  def generate_permalink
    urls = self.ancestors.collect { |parent| parent.slug }
    urls.push self.slug
    # RAILS 4 TODO: If upgrading to Rails 4, change method to update_columns
    self.update_column(:permalink, "/#{urls.join('/')}")
  end

  def search_data
    generate_search_data_hash
  end

  def should_index?
    printable? && !self.is_framemaker? #&& self.type != "Support" # only index published records
  end

  def book_title
    self.root.title
  end

  def open_issues
    self.annotations.where("aasm_state = ?", "submitted").count
  end

  def generate_search_data_hash
    to_search = {}
    to_search["title"] = "#{title}"
    to_search["permalink"] = permalink
    to_search["public_content"] = format_field_for_search(self.body_contents)
    to_search["date"] = self.updated_at
    to_search["book"] = book_title
    # ChannelPartner.all.each do |cp|
    #   to_search["#{cp.name.parameterize}_content"] = private_content(cp.id)
    # end
    return to_search
  end

  def framemaker_contents
    begin
      #puts "Fetching: #{Rails.root.join(self.framemaker_export_location)}"
      File.read(Rails.root.join(self.framemaker_export_location))
    rescue
      puts "Couldn't find that file... searching for #{self.framemaker_page_id}"
      if self.framemaker_page_id && !Dir.glob("#{Rails.root}/public/framemaker/**/*---#{self.framemaker_page_id}.html").first.nil?
        File.read(Dir.glob("#{Rails.root}/public/framemaker/**/*---#{self.framemaker_page_id}.html").first)
      else
        #TODO log/alert here
        return "Unable to find that file"
      end
    rescue
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def body_contents
    if is_framemaker?
      return framemaker_contents
    else
      return self.passages.pluck(:content).join
    end
  end

  def private_content(id)
    channel_specific = channel_specific_contents.of(id).pluck(:content).join("") || ""
    return format_field_for_search(channel_specific)
  end

  def update_subsection_headings
  end
end
