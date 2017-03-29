class Roadmap < ActiveRecord::Base
  resourcify #Used by rolify
  has_autosave
  has_ancestry :orphan_strategy => :rootify, :cache_depth => true
  extend FriendlyId
  friendly_id :title, use: [:scoped, :slugged], :scope => :ancestry # Generates data for slug column on save based on :title, scoped to the parents so we don't get suffixes for identically named quarters between years. /2013/q3 and /2014/q3--2
  acts_as_readable :new_reader_all_but_most_recent => true, :on => :created_at
  include Searchable
  has_paper_trail
  attr_accessor :active_admin_requested_event

  attr_accessible :title,
                   :product,
                   :pub_status,
                   :release_id,
                   :content,
                   :slug,
                   :permalink,
                   :redirect_to_first_child,
                   :subsection_headings,
                   :sortable_order,
                   :is_a_quarter,
                   :parent_id,
                   :active_admin_requested_event,
                   :created_at,
                   :updated_at

  ROADMAP_PUBLISHED_STATES = [:planned, :in_progress, :ongoing, :complete]

  after_initialize :sortable
  after_save :generate_permalink, :refresh_descendants

  default_scope order: 'roadmaps.sortable_order ASC'
  scope :published, where(:pub_status => ROADMAP_PUBLISHED_STATES)
  scope :no_redirect, where(:redirect_to_first_child => false)
  scope :created_or_updated_since, lambda { |time, user| published.no_redirect.where("created_at > ? OR updated_at > ?", time, time).with_read_marks_for(user) }

  has_many :channel_specific_contents, as: :channel_specific
  accepts_nested_attributes_for :channel_specific_contents, :allow_destroy => true

  validates_presence_of :content, :title

  searchkick merge_mappings: true, mappings: {
              roadmap: {
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
                  title: { type: "string", analyzer: "snowball", index: "analyzed" },
                  permalink: { type: "string", analyzer: "keyword", index: "not_analyzed" },
                  public_content: { type: "string", analyzer: "snowball", index: "analyzed" },
                  date: { type: "date" }
                }
              }
            }
  def search_data
    generate_search_data_hash
  end

  def should_index?
    published? and self.redirect_to_first_child == false
  end

  def generate_search_data_hash
    to_search = {}
    to_search["title"] = "#{title}"
    to_search["permalink"] = permalink
    to_search["date"] = self.updated_at
    to_search["public_content"] = format_field_for_search(self.content)
    # ChannelPartner.all.each do |cp|
    #   to_search["#{cp.name.parameterize}_content"] = private_content(cp.id)
    # end
    return to_search
  end

  def private_content(id)
    channel_specific = channel_specific_contents.of(id).pluck(:content).join("") || ""
    return format_field_for_search(channel_specific)
  end

  include AASM
  aasm :column => 'pub_status' do
    state :draft, :initial => true
    state :planned
    state :in_progress
    state :ongoing
    state :complete

    event :publish do
      transitions :from => :draft, :to => :planned
    end

    event :start_work do
      transitions :from => [:planned, :draft], :to => :in_progress
    end

    event :ongoing do
      transitions :from => [:planned, :in_progress, :draft], :to => :ongoing
    end

    event :finish do
      transitions :from => [:planned, :in_progress, :ongoing, :draft], :to => :complete
    end

    event :redraft do
      transitions :from => [:planned, :in_progress, :ongoing, :complete], :to => :draft
    end
  end

  def friendly_title
    title
  end

  def headline
    "Roadmap"
  end

  def first_live_child
    @first_live_child ||= descendants.where(:redirect_to_first_child => false).published.order('sortable_order').first
  end

  def published?
    ROADMAP_PUBLISHED_STATES.include?(pub_status.to_sym)
  end

  def sortable
    self.sortable_order ||= (Roadmap.maximum("sortable_order") || 0) + 1
  end

  def generate_permalink
    urls = ["roadmaps"]
    urls.push self.ancestors.collect { |parent| parent.slug }
    urls.push self.slug
    permalink = urls.join('/')
    # RAILS 4 TODO: If upgrading to Rails 4, change method to update_columns
    self.update_column(:permalink, "/#{permalink.gsub(/\/\//, '/' )}")
  end

  def refresh_descendants
    unless self.descendants.empty?
      self.descendants.each do |d|
        d.generate_permalink
      end
    end
  end

  def self.sort(pages_order, page_data)
    response_data = {}
    pages_hash = Roadmap.find(pages_order).inject({}){ |hash, page| hash[page.id.to_s] = page; hash }

    Roadmap.transaction do
      pages_order.each_with_index do |page_id, index|
        page = pages_hash[page_id]

        page.parent_id = page_data[page_id] == 'null' ? nil : page_data[page_id]

        page.sortable_order = index
        page.save
        response_data[page.id] = page.permalink
      end #end each
    end #end Page.transaction
    return response_data
  end

  # def self.update_categories
  #   ActiveRecord::Base.record_timestamps = false
  #   begin
  #     Roadmap.all.each do |roadmap|
  #       case roadmap.product
  #         when "Vendor Tools & Billing"
  #           roadmap.update_column("product", "Developer Tools & Billing")
  #         when "Corporate Marketplace Manager"
  #           roadmap.update_column("product", "Network Manager")
  #         when "Orchestration"
  #           roadmap.update_column("product", "Reseller")
  #       end
  #     end
  #   ensure
  #     ActiveRecord::Base.record_timestamps = true
  #   end
  # end

end
