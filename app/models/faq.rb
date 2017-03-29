class Faq < ActiveRecord::Base
  resourcify #Used by rolify
  acts_as_taggable
  include Searchable
  extend FriendlyId
  friendly_id :question, use: [:slugged]

  attr_accessible :question,
                  :answer,
                  :pub_status,
                  :tag_list,
                  :slug

  validates_presence_of :question, :answer

  searchkick merge_mappings: true, mappings: {
              faq: {
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
                  public_content: { type: "string", analyzer: "snowball", index: "analyzed" },
                  date: { type: "date" }
                }
              }
            }

  def search_data
    generate_search_data_hash
  end

  def generate_search_data_hash
    to_search = {}
    to_search["title"] = "#{question}"
    to_search["public_content"] = format_field_for_search(self.answer)
    to_search["date"] = self.updated_at
    # ChannelPartner.all.each do |cp|
    #   to_search["#{cp.name.parameterize}_content"] = ""
    # end
    return to_search
  end

  def friendly_title
    question
  end

  def title
    question
  end

  def headline
    "FAQs"
  end
end
