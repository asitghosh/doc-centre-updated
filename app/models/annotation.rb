class Annotation < ActiveRecord::Base
	serialize :ranges, JSON
	serialize :permissions, JSON
	include AASM

	attr_accessible :quote,
					:text,
					:ranges,
					:page_permalink,
					:page_id,
					:user_id,
					:aasm_state,
					:permissions,
          :classification

	belongs_to :owner, :class_name => "User", :foreign_key => :user_id
	belongs_to :page

	aasm do
		state :submitted, :default => true
		state :resolved

		event :resolve do
			transitions :from => :submitted, :to => :resolved
		end
	end

	def user
		self.owner.email
	end

	def self.send_digest
		AnnotationsDigest.send_mail.deliver
	end
					
end