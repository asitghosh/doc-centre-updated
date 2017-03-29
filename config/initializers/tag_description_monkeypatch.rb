ActsAsTaggableOn::Tag.class_eval do
	attr_accessible :description_attributes
	has_one :description, class_name: "TagDescription"
	accepts_nested_attributes_for :description, :allow_destroy => true
end