class Passage < ActiveRecord::Base
  SECTION_NAMES = %w[marketplace_improvements manager_improvements devcenter_improvements api_improvements corporate_portal]
  has_paper_trail

  attr_accessible :content,
                  :sortable_order,
                  :tag_list,
                  :remote_content,
                  :type_name

  belongs_to :passages, polymorphic: true
  acts_as_taggable

  validates :type_name, inclusion: { in: SECTION_NAMES }, :allow_nil => true
  validates :remote_content, :allow_blank => true, :format => URI::regexp(%w(http https))
  validates :content, presence: true, unless: :remote_content
  validates :remote_content, presence: true, unless: :content

  default_scope order: 'passages.sortable_order ASC'

  def output
    if content.present?
      return content
    elsif remote_content.present?
      response = HTTParty.get(self.remote_content)
      return response.body.force_encoding('UTF-8')
    else
      return nil
    end
  end
end
