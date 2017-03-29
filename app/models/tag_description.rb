class TagDescription < ActiveRecord::Base
	attr_accessible :description, :tag_id
	belongs_to :tag
end