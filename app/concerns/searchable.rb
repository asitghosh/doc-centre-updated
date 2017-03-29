# encoding: UTF-8
module Searchable
  extend ActiveSupport::Concern
  #
  included do
  #   include Tire::Model::Search
  #   attr_accessor :current_channel_partner_id
  #   after_commit :tire_store
    #searchkick
    include ActionView::Helpers::SanitizeHelper
  end
  #
  module ClassMethods
  end

  def format_field_for_search(string)
    stripped_string = strip_tags(string).gsub(/[^[:print:]]|\\r|\\t|\\n|\\p{Pd}|—\.|\&lt;|\&gt;|\\u2014/, ' ').gsub(/\s{1,}/, ' ')
    # STOPWORDS is definied in initializers/constants.rb
    # http://stackoverflow.com/questions/4655194/simple-filtering-out-of-common-words-from-a-text-description
    # common = {}
    # STOPWORDS.each{|w| common[w] = true}
    # stopped = stripped_string.gsub(/\b\w+\b/){|word| common[word.downcase] ? '': word}.squeeze(' ')
    # return stopped
  end
  #
  # def cs_contents
  #   ChannelPartner.unscoped.each do |cp|
  #
  #   end
  # end
  #
  # def searchable_cs_contents(channel_partner_id)
  #   channel_specific_contents.of(current_channel_partner_id).pluck(:content).join("")
  # end
  #
  # def searchable_hotfixes(channel_partner_id)
  #   hfixes                    = hotfixes.public_with_specifics_for(channel_partner_id)
  #   content                   = hfixes.pluck(:content)
  #   channel_specific_content  = hfixes.map { |hf| hf.channel_specific_contents.of(channel_partner_id).pluck(:content)}
  #   (content + channel_specific_content).join('')
  # end
  #
  # def tire_store
  #   ChannelPartner.unscoped.each do |cp|
  #     cp_id = cp.id
  #     self.current_channel_partner_id = cp_id
  #     index = Tire::Index.new("channel_partner_#{cp_id}")
  #     index.create
  #     index.store self
  #   end
  # end
  #
  # #TODO: comment this out before putting this anywhere.
  # # def drop_all
  # #   ChannelPartner.unscoped.each do |cp|
  # #     cp_id = cp.id
  # #     index = Tire::Index.new("channel_partner_#{cp_id}")
  # #     index.delete
  # #   end
  # # end

end
