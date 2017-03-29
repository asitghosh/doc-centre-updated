class ChannelPartner < ActiveRecord::Base
  before_save :blank_time
  before_create :set_api_key
  attr_accessor :users_for_mailing_list

  attr_accessible :name,
                  :subdomain,
                  :open_id_address,
                  :logo,
                  :account_rep_ids,
                  :marketplace_name,
                  :marketplace_url,
                  :color,
                  :custom_links_attributes,
                  :open_id_urls_attributes,
                  :marketplace_edition,
                  :marketplace_account_status,
                  :day_to_send_latest_release,
                  :time_to_send_latest_release,
                  :users_for_mailing_list,
                  :able_to_see_releases,
                  :able_to_see_roadmaps,
                  :able_to_see_faqs,
                  :able_to_see_user_guides,
                  :able_to_see_supports,
                  :able_to_see_isv,
                  :api_key

  #has_attached_file :logo
  has_many :users, dependent: :destroy
  has_many :custom_links, dependent: :destroy
  has_many :open_id_urls, :class_name => "OpenIDUrl"
  has_and_belongs_to_many :account_reps, :class_name => 'User', :association_foreign_key => 'account_rep_id'
  has_and_belongs_to_many :features
  has_and_belongs_to_many :hotfixes

  accepts_nested_attributes_for :custom_links, :allow_destroy => true
  accepts_nested_attributes_for :open_id_urls, :allow_destroy => true

  validates_presence_of :name, :subdomain, :marketplace_url, :color, :logo
  validates_length_of :color, :minimum => 6, :maximum => 6
  validates_presence_of :time_to_send_latest_release, :if => Proc.new { |channel_partner| channel_partner.day_to_send_latest_release.present? }
  validates_uniqueness_of :subdomain
  
  def send_latest_release(email=nil)
    if self.able_to_see_releases?
      latest_release = Release.current_release
      Resque.enqueue(PdfGeneratorAndEmailer, latest_release.class.name, latest_release.id, self.id, {:to => email, :list => "Channel Partner Mailing List"})
    end
  end

  def blank_time
    self.time_to_send_latest_release = "" if self.day_to_send_latest_release.blank?
  end

  def is_multitenant?
    self.open_id_urls.length > 1
  end

  def able_to_see_releases?
    able_to_see_releases
  end

  def able_to_see_roadmaps?
    able_to_see_roadmaps
  end

  def able_to_see_faqs?
    able_to_see_faqs
  end

  def able_to_see_user_guides?
    able_to_see_user_guides
  end

  def able_to_see_guides?
    #this is the navigation item, not the user_guides
    able_to_see_user_guides || able_to_see_faqs
  end

  def able_to_see_product_changes?
    #this is the navigation item
    able_to_see_releases || able_to_see_roadmaps
  end

  def generate_api_key
    loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless ChannelPartner.exists?(api_key: token)
    end
  end

  def set_api_key
    self.api_key = generate_api_key
  end

  def self.assign_api_keys
    ChannelPartner.all.each do |cp|
      cp.update_attribute(:api_key, cp.generate_api_key)
    end
  end

  def self.init_openid
    ChannelPartner.all.each do |cp|
      cp.open_id_urls.create({ :open_id_url => cp.open_id_address })
      cp.update_attribute(:open_id_address, nil)
    end
  end
end
