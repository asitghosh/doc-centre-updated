class CustomLink < ActiveRecord::Base
  attr_accessible :label, :url, :link_type, :channel_partner_id
  belongs_to :channel_partner
  default_scope order: 'link_type ASC'
end