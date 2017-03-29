class FaqsController < ApplicationController
  include RestrictedPartners
  layout 'pages'
  before_filter :tag_nav

  def index
    @faqs = Faq.all
  end

  def show
    tag_filter = params[:tag].titleize
    @faqs = Faq.tagged_with(tag_filter)
  end

  def show_individual
    @faq = Faq.find(params[:id])
  end

  def tag_nav
    @faq_nav = Faq.tag_counts_on(:tags) #this returns an array of tag objects that we can pull the name out of for the nav
  end
  # def tag_count
  #   @tags = FAQ.tag_counts
  # end
end
