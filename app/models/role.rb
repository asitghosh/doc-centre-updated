class Role < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  has_many :permissions
  has_and_belongs_to_many :users, :join_table => :users_roles
  accepts_nested_attributes_for :permissions, :allow_destroy => true
  attr_accessible :name, :permissions_attributes


  scopify
end
