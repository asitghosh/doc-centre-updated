class Isv < Page
  # include Pdfable
  mapping = {
              manual: {
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
                  date: { type: "date" }
                }
              }
            }

  searchkick merge_mappings: true, mappings: mapping, index_name: "isv_info_#{Rails.env}"



  def headline
    "ISV Information"
  end

  def friendly_title
    title
  end

  def search_data
    generate_search_data_hash
  end

  def should_index?
    printable? #&& self.type != "Support" # only index published records
  end

  def generate_search_data_hash
    to_search = {}
    to_search["title"] = "#{title}"
    to_search["permalink"] = permalink
    to_search["public_content"] = format_field_for_search(self.body_contents)
    to_search["date"] = self.updated_at
    ChannelPartner.all.each do |cp|
      to_search["#{cp.name.parameterize}_content"] = private_content(cp.id)
    end
    return to_search
  end

  def private_content(id)
    channel_specific = channel_specific_contents.of(id).pluck(:content).join("") || ""
    return format_field_for_search(channel_specific)
  end

  def generate_permalink
    urls = self.ancestors.collect { |parent| parent.slug }
    urls.push self.slug
    # RAILS 4 TODO: If upgrading to Rails 4, change method to update_columns
    self.update_column(:permalink, "/isv-info/#{urls.join('/')}")
  end
end
