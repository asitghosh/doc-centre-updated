class Feature < ActiveRecord::Base
  has_autosave
  resourcify #Used by rolify
  attr_accessible :title, 
                  :summary, 
                  :release_id, 
                  :content, 
                  :channel_partner_ids, 
                  :pub_status

  belongs_to :release
  has_and_belongs_to_many :channel_partners
  acts_as_readable :on => :created_at
  after_commit :update_release_pdf
  before_save :newly_attached?

  validates_presence_of :title, :summary, :content

  def update_release_pdf
    self.release.update_pdf if self.release
  end

  # SCOPES/Class Methods: 
  
  default_scope order('release_id ASC')
  scope :created_or_updated_since, lambda { |time, user| shown.where("features.created_at > ? OR features.updated_at > ?", time, time).with_read_marks_for(user) }
  scope :public, lambda { shown.joins("LEFT JOIN channel_partners_features ON channel_partners_features.feature_id = features.id").where('channel_partners_features.channel_partner_id IS NULL') }
  scope :recent, order: 'features.updated_at DESC'

  include AASM
  aasm :column => 'pub_status' do
    state :draft, :initial => true
    state :published

    event :publish, :after => Proc.new { after_publish } do
      transitions :from => :draft, :to => :published
    end

    event :redraft do
      transitions :from => :published, :to => :draft
    end 
  end

  def after_publish
    # this will fire... after publish. SURPRISE!
  end

  def self.public_with_specifics_for(channel_partner_id)
    joins("LEFT JOIN channel_partners_features ON channel_partners_features.feature_id = features.id").where('channel_partners_features.channel_partner_id IS NULL OR channel_partners_features.channel_partner_id = ?', channel_partner_id)
  end

  def self.upcoming
    unscoped { public.order("created_at DESC").limit(3) }
  end

  def self.shown
    Feature.joins("LEFT JOIN releases ON releases.id = features.release_id").where("features.release_id IS NULL OR releases.release_date > CURRENT_DATE")
  end

  def headline
    "Upcoming Features"
  end

  # INSTANCE METHODS
  def friendly_title
    "#{title}"
  end

  def newly_attached?
    self.merge_date = Time.now() if self.release_id_changed?
    self.merge_date = nil unless self.attached?
  end

  def attached?
    self.release != nil
  end

  def shown?
    @shown ||= release.nil? || release.release_date >= Date.today
  end

end
