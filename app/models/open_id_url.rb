class OpenIDUrl < ActiveRecord::Base
	attr_accessible :open_id_url,
					:channel_partner_id

	belongs_to :channel_partner
end