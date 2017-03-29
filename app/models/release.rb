class Release < ActiveRecord::Base

  # pub_status = whether or not the release is visible to the signed-in channel users, admins see all
  # release_date = the day the release will be deployed to production
  resourcify #Used by rolify
  extend FriendlyId
  friendly_id :title, use: [:slugged]
  include Searchable

  # temporary variable used in ActiveAdmin after_save
  attr_accessor :active_admin_requested_event

  attr_accessible :title,
                  :release_date,
                  :summary,
                  :channel_specific_contents_attributes,
                  :channel_specific_states_attributes,
                  :feature_ids,
                  :pub_status,
                  :marketplace_improvements,
                  :manager_improvements,
                  :devcenter_improvements,
                  :api_improvements,
                  :slug,
                  :corporate_portal,
                  :hotfixes_attributes,
                  :passages_attributes,
                  :active_admin_requested_event,
                  :general_notes


  PUBLISHED_STATES = [:released, :revised, :master]

  has_many :features
  has_many :hotfixes
  has_many :channel_specific_contents, as: :channel_specific
  has_many :channel_specific_states, as: :channel_specific_state
  has_many :passages, as: :passages

  serialize :subsection_headings, Hash
  accepts_nested_attributes_for :channel_specific_contents, :allow_destroy => true
  accepts_nested_attributes_for :channel_specific_states, :allow_destroy => true
  accepts_nested_attributes_for :hotfixes, :allow_destroy => true
  accepts_nested_attributes_for :passages, :allow_destroy => true
  acts_as_readable :new_reader_all_but_most_recent => true, :on => :created_at

  default_scope order: 'releases.release_date DESC'
  default_scope includes(:passages)
  scope :published, where(:pub_status => PUBLISHED_STATES)
  scope :released, lambda { published.where("date_trunc('minute', release_date) <= now()") }
  scope :current, lambda { released.order("release_date DESC").limit(1) }
  scope :created_or_updated_since, lambda { |time, user| published.where("created_at > ? OR updated_at > ?", time, time).with_read_marks_for(user) }
  scope :recent, order: 'releases.updated_at DESC'
  scope :search_import, -> { includes(:channel_specific_contents, :hotfixes, :passages) }

  before_save :update_heading_ids
  after_save :update_subsection_headings
  validates_presence_of :title, :release_date, :summary
  validates_uniqueness_of :title

  has_autosave
  has_paper_trail
  include Pdfable

  def should_index?
    !!self.published? # only index published records
  end
  # marketplace_improvements: { type: "string", analyzer: "snowball", store: false },
  # manager_improvements: { type: "string", analyzer: "snowball", store: false },
  # devcenter_improvements: { type: "string", analyzer: "snowball", store: false },
  # api_improvements: { type: "string", analyzer: "snowball", store: false },
  # corporate_portal: { type: "string", analyzer: "snowball", store: false }
  searchkick merge_mappings: true, mappings: {
              release: {
                dynamic_templates: [
                  { content: {
                      match: "*_content",
                      match_mapping_type: "string",
                      mapping: {
                        type: "string",
                        analyzer: "snowball",
                        index: "analyzed"
                      }
                  }}
                ],
                properties: {
                  title: { type: "string", analyzer: "keyword", index: "analyzed" },
                  public_content: { type: "string", analyzer: "snowball", index: "analyzed" },
                  date: { type: "date" }
                }
              }
            }




  def search_data
    generate_search_data_hash
  end

  def generate_search_data_hash
    to_search = {}
    to_search["title"] = "Release #{title}"
    to_search["public_content"] = public_content
    to_search["date"] = self.release_date.to_time
    # ChannelPartner.all.each do |cp|
    #   to_search["#{cp.name.parameterize}_content"] = private_content(cp.id)
    # end
    return to_search
  end

  def public_content
    format_field_for_search(marketplace_improvements_content) + format_field_for_search(manager_improvements_content) + format_field_for_search(devcenter_improvements_content) + format_field_for_search(api_improvements_content) + format_field_for_search(corporate_portal_content)
  end

  def private_content(id)
    channel_specific = channel_specific_contents.of(id).pluck(:content).join("") || ""
    hfixes                    = hotfixes.public_with_specifics_for(id)
    content                   = hfixes.pluck(:content)
    channel_specific_content  = hfixes.map { |hf| hf.channel_specific_contents.of(id).pluck(:content)}
    hotfix_content = (content + channel_specific_content).join('')
    return format_field_for_search(channel_specific + hotfix_content)
  end

  include AASM
  aasm :column => 'pub_status' do
    state :draft, :initial => true
    state :released
    state :revised
    state :master

    event :release do
      transitions :from => :draft, :to => :released
    end

    event :revise do
      transitions :from => [:draft, :released], :to => :revised
    end

    event :finalize, :after => Proc.new { email_notification_subscribers } do
      transitions :from => [:draft, :revised], :to => :master
    end

    event :redraft do
      transitions :from => [:released, :revised, :master], :to => :draft
    end
  end

  def email_notification_subscribers(email=nil)
    ChannelPartner.where(:able_to_see_releases => true).pluck(:id).each do |channel_partner_id|
      Resque.enqueue(PdfGeneratorAndEmailer, self.class.name, self.id, channel_partner_id, {:to => email, :list => "Release Notification"})
    end
  end

  def self.current_release
    #can't cache this or it doesn't reflect updates to the current release
    #as the day/time changes or release pub_status
    Release.current.first
  end

  Passage::SECTION_NAMES.each do |type_name|
    define_method("#{type_name}_passages") do
      passages.where(type_name: "#{type_name}")
    end

    define_method("#{type_name}_content") do
      wysiwyg = self["#{type_name}"] || ""
      wysiwyg + self.send("#{type_name}_passages").collect { |p| p.content }.join
    end
  end

  def passage_contents
    self.passages.pluck("content").join
  end

  def self.printable
    published?
  end

  def any_content_for?(user)
    if user.can_see_all? or self.general_notes? then return true end
    @ac_for ||= !hotfixes_for(user).blank? or notes_for_user?(user)
  end

  def general_notes?
    @gn ||= !(marketplace_improvements_content.blank? and manager_improvements_content.blank? and devcenter_improvements_content.blank? and api_improvements_content.blank? and corporate_portal_content.blank?)
  end

  def headline
    "Release Notes"
  end

  def friendly_title
    "Release #{title}"
  end

  def permalink
    Rails.application.routes.url_helpers.release_path(self)
  end

  def channel_partners
    # channels with whitelisted notes
    whitelist = channel_specific_contents.where('channel_specific_contents.whitelist = ? OR channel_specific_contents.whitelist IS NULL', 't').joins(:channel_partners).pluck("channel_partners.id")
    # get all channel partner ids
    channelpartner_ids = ChannelPartner.pluck(:id)
    # get the ones marked as blacklist
    blacklisted_channel_content = channel_specific_contents.where('channel_specific_contents.whitelist = ?', 'f')
    # for each blacklist, add every channel partner to wl except the one blacklisted.
    blacklisted_channel_content.each do |blacklisted_item|
      to_add = channelpartner_ids.reject { |item| blacklisted_item.channel_partner_ids.include? item }
      whitelist += to_add
    end
    return whitelist.uniq
  end

  def hotfixes_for(user)
    @hf_for ||= user.can_see_all? ?
      self.hotfixes :
      self.hotfixes.public_with_specifics_for(user.channel_partner.id)
  end

  def hotfix_numbers_for(user)
    hf = hotfixes_for(user)
    @hf_num ||= hf.collect { |h| h.number }
  end

  def notes_for?(partner_id)
    channel_partners.include?(partner_id)
  end

  def notes_for_user?(user)
    if user.can_see_all?
      !channel_partners.empty?
    else
      channel_partners.include?(user.channel_partner.id)
    end
  end

  def count_notes_for(user)
    if user.can_see_all?
      channel_specific_contents.count
    else
      channel_partners.count(user.channel_partner.id)
    end
  end

  def display_name
    "Release #{title}"
  end

  def published?
    Release::PUBLISHED_STATES.include?(self.pub_status.to_sym)
  end

  def printable?
    self.published?
  end

  def current?
    Release.current_release.id == id unless Release.current.empty?
  end

  # TODO: Tests for this: could be buggy.
  def future?
    release_date.nil? || !released?
  end

  def past?
    !current? && released?
  end

  def released?
    release_date <= Date.today
  end

  # def draft?
  #   pub_status == 'draft'
  # end

  def release_type
    case
    when draft?
      'draft'
    when future?
      'future'
    when past?
      "past"
    when current?
      'current'
    end
  end

  def generate_heading_ids(field, field_subheadings, field_html)
    field_subheadings.each do |heading|
      heading['id'] = "#{field.parameterize}-#{heading.content.parameterize}"
      self[field] = field_html.to_html
    end
  end

  def generate_subheadings
    wysiwyg_fields = { 'marketplace_improvements' => {name: 'Marketplace Improvements'},
                        'api_improvements'         => {name: 'Marketplace API Improvements'},
                        'devcenter_improvements'   => {name: 'Developer Center Improvements'},
                        'manager_improvements'     => {name: 'Marketplace Manager Improvements'},
                        'corporate_portal'         => {name: 'Corporate Portal'}
                      }
    wysiwyg_fields.each do |field_key, field_hash|
      if self.send("#{field_key}_content").blank?
        wysiwyg_fields.delete(field_key)
      # else
      #   # field_html = Nokogiri::HTML.fragment( self[field_key] )
      #   # field_subheadings = field_html.css('h2','h3')
      #   # generate_heading_ids(field_key, field_subheadings, field_html)
      #   # wysiwyg_fields[field_key][:headings] = field_subheadings.blank? ? "" : field_subheadings.map { |item| item.children.text }
      end
    end
  end

  def update_heading_ids
    self.passages.each do |passage|
      passage.content = process_heading_ids(passage.content)
    end

    self.channel_specific_contents.each do |passage|
      passage.content = process_heading_ids(passage.content)
    end
  end

  def process_heading_ids(fragment)
    new_body = Nokogiri::HTML.fragment(fragment)
    new_body.css('h2','h3').each do |heading|
      heading_id = heading.content.parameterize
      heading['id'] = heading_id

      # add the spy_this class
      heading['class'] ||= ""
      heading['class'] = heading['class'] << " spy_this" unless heading['class'].include? "spy_this"

      # add an anchor for hash pointers in url
      heading.css('.anchor').remove
      heading.prepend_child("<a class='anchor' href='##{heading_id}'></a>")
    end
    return new_body.to_html
  end

  def update_subsection_headings
    #Release.update_all({:subsection_headings => generate_subheadings}, {:id => self.id})
    self.update_column(:subsection_headings, generate_subheadings.to_yaml)
    #self.update_attribute(:subsection_headings, generate_subheadings)
  end

end
