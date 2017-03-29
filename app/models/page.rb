class Page < ActiveRecord::Base
  # serialize :subsection_headings
  resourcify #Used by rolify
  has_autosave
  has_paper_trail
  #extend FriendlyId
  include Searchable
  #friendly_id :title, use: [:scoped, :slugged], :scope => :ancestry # Generates data for slug column on save based on :title
  has_ancestry :orphan_strategy => :rootify, :cache_depth => true
  acts_as_readable :on => :created_at

  # temporary variable used in ActiveAdmin after_save
  attr_accessor :active_admin_requested_event
  # include PgSearch
  # multisearchable :against => [:title, :body]

  attr_accessible :body,
                  :title,
                  :slug,
                  :release_date,
                  :permalink,
                  :logo,
                  :redirect_to_first_child,
                  :sortable_order,
                  :active_admin_requested_event_support,
                  :active_admin_requested_event_api,
                  :parent_id,
                  :pub_status,
                  :page_pub_date,
                  :subsection_headings,
                  :channel_specific_contents_attributes,
                  :passages_attributes,
                  :active_admin_requested_event,
                  :is_framemaker,
                  :framemaker_book,
                  :framemaker_chapter,
                  :framemaker_page_id,
                  :framemaker_export_location,
                  :type,
                  :summary

  after_initialize :sortable
  before_save :update_heading_ids, :generate_slug
  after_save :generate_permalink, :refresh_descendants, :update_subsection_headings

  has_many :passages, as: :passages
  has_many :channel_specific_contents, as: :channel_specific
  has_many :channel_specific_states, as: :channel_specific_state

  accepts_nested_attributes_for :passages, :allow_destroy => true
  accepts_nested_attributes_for :channel_specific_contents, :allow_destroy => true

  validates_presence_of :title


  default_scope order: 'sortable_order ASC'
  # default_scope includes(:passages)
  # scope :published, where('pub_status = ?', "published")
  scope :draft,     where('pub_status = ?', "draft")
  scope :no_redirect, where(:redirect_to_first_child => false)
  scope :created_or_updated_since, lambda { |time, user| published.no_redirect.where("created_at > ? OR updated_at > ?", time, time).with_read_marks_for(user) }
  scope :recent, order: 'pages.updated_at DESC'



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


  def self.printable
    Page.where(pub_status: "published").where(redirect_to_first_child: false)
  end

  def headline
    "Manuals"
  end

  def friendly_title
    "#{title}"
  end

  def body_contents
    self.body + self.passages.pluck(:content).join
  end

  def printable?
    self.published? and self.redirect_to_first_child == false
  end

  def sortable
    self.sortable_order ||= (Page.maximum("sortable_order") || 0) + 1
  end

  def is_roadmap?
    @rm ||= self.permalink.split('/').include?("roadmap")
  end

  def is_guide?
    @gu ||= self.permalink.split('/').include?("manuals")
  end

  def is_manual?
    is_guide?
  end

  def first_live_child
    @first_live_child ||= descendants.where(:redirect_to_first_child => false).published.order('sortable_order').first
  end

  def self.sort(pages_order, page_data)
    response_data = {}
    pages_hash = Page.find(pages_order).inject({}){ |hash, page| hash[page.id.to_s] = page; hash }
    Page.skip_callback(:commit, :after, :generate_pdf)
    Page.transaction do
      pages_order.each_with_index do |page_id, index|
        page = pages_hash[page_id]

        page.parent_id = page_data[page_id] == 'null' ? nil : page_data[page_id]
        page.sortable_order = index
        page.save
        response_data[page.id] = page.permalink
      end #end each
    end #end Page.transaction
    Page.set_callback(:commit, :after, :generate_pdf)
    return response_data
  end
  
  def generate_slug
    self.slug = self.title.parameterize
  end

  def generate_permalink
    urls = self.ancestors.collect { |parent| parent.slug }
    urls.push self.slug
    # RAILS 4 TODO: If upgrading to Rails 4, change method to update_columns
    self.update_column(:permalink, "/#{urls.join('/')}")
  end

  def refresh_descendants
    unless self.descendants.empty?
      self.descendants.each do |d|
        d.generate_permalink
      end
    end
  end

  def update_heading_ids
    self.body = process_heading_ids(self.body)

    self.passages.each do |passage|
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
    body_nodeset = Nokogiri::HTML.fragment(self.body_contents)
    subheadings = body_nodeset.css('h2','h3').map { |item| item.children.text }.to_s
    self.update_column(:subsection_headings, subheadings)
  end

  # TODO: DELETE THIS AFTER USING IT.

  # def self.copy_to_roadmap
  #   root = Page.find_by_title("Roadmap")
  #   r = Roadmap.create(root.dupe_roadmap)
  #   root.copy_children(Roadmap.first)
  #
  # end
  #
  # def copy_children(parent)
  #   self.children.each do |child|
  #     roadmap_child = child.dupe_roadmap
  #     new_roadmap = parent.children.create(roadmap_child)
  #     child.copy_children(new_roadmap) if child.children.present?
  #   end
  # end
  #
  # def dupe_roadmap
  #   {
  #   title: self.title,
  #   content: self.body,
  #   pub_status: "planned",
  #   is_a_quarter: self.depth == 2,
  #   redirect_to_first_child: self.redirect_to_first_child,
  #   sortable_order: self.sortable_order,
  #   created_at: self.created_at,
  #   updated_at: self.updated_at
  #   }
  # end

end
