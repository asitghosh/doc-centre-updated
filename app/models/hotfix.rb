class Hotfix < ActiveRecord::Base
  # temporary variable used in ActiveAdmin after_save
  attr_accessor :active_admin_requested_event

	attr_accessible :number,
					:release_id,
					:channel_partner_ids,
					:content,
					:pub_status,
					:channel_specific_contents_attributes,
          :active_admin_requested_event

	belongs_to :release
	has_and_belongs_to_many :channel_partners
	has_many :channel_specific_contents, as: :channel_specific
	accepts_nested_attributes_for :channel_specific_contents, :allow_destroy => true
  validates_presence_of :number, :release_id, :content
  # -- scopes

  default_scope order: 'hotfixes.created_at'

	def self.public_with_specifics_for(channel_partner_id)
  	published.joins("LEFT JOIN channel_partners_hotfixes ON channel_partners_hotfixes.hotfix_id = hotfixes.id")
    .where('channel_partners_hotfixes.channel_partner_id IS NULL OR channel_partners_hotfixes.channel_partner_id = ?', channel_partner_id)
	end

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
  # -- instance methods

  def after_publish(email=nil)
    ChannelPartner.where(:able_to_see_releases => true).pluck(:id).each do |channel_partner_id|
      Resque.enqueue(PdfGeneratorAndEmailer, self.release.class.name, self.release.id, channel_partner_id, {:to => email, :list => "Hotfix Notification"})
    end
  end

  def permalink
    "#{Rails.application.routes.url_helpers.release_path(self.release)}#hotfix#{self.number.gsub(".", "_")}"
  end

  def title
    "Hotfix #{self.number}"
  end

  def headline
    "Hotfix"
  end

  def friendly_title
    title
  end

  def contents_for(user)
    csc = user.can_see_all? ?
      self.channel_specific_contents :
      self.channel_specific_contents.of(user.channel_partner.id)

    ofthejedi = {}
    csc.map do |content|
      content.channel_partners.each do |cp|
        ofthejedi[cp.name] ||= []
        ofthejedi[cp.name] << content
      end
    end
    Hash[ofthejedi.sort]
  end

end
