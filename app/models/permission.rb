class Permission < ActiveRecord::Base
  # Make a migration that has: 
  # action, subject_class, subject_id
  attr_accessible   :action, :subject_class, :subject_id, :role_id

  belongs_to :role
end
