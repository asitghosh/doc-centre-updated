class Update < ActiveRecord::Base
  attr_accessible :title,
                  :content,
                  :release_date,
                  :pub_status

  default_scope order: 'updates.release_date DESC'
  scope :published, where("pub_status = 'published'")
  scope :current, lambda { published.order("release_date DESC").limit(1) }

  after_create :reset_update_visibility

  def self.current_version_number
    @cvn ||= published.limit(1).title
  end

  def reset_update_visibility
    User.all.each { |u| u.reset_update if u.can_see_all? }
  end
end