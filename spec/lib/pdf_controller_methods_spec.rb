# encoding: UTF-8
require 'spec_helper'

feature PdfControllerMethods do
  before :all do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
  end

  before do
    ENV['IS_A_RESQUE_WORKER'] = "true"
  end

  after do
    ENV['IS_A_RESQUE_WORKER'] = "false"
  end

  let!(:channel_partner) { @att }
  let(:release) { FactoryGirl.create(:release, :published, :present) }
  let(:generator) { PdfGenerator.new('release', release.id, channel_partner.id) }
  let(:high_priority_generator) { PdfGeneratorHighPriority.new('release', release.id, channel_partner.id)}
  let(:html) { generator.get_html}

  describe "#prepare_html" do
    it "should wrap the HTML with table captions" do
      caption = "<caption style=\"prince-caption-page: following\">"
      expect(html).to include(caption)
    end
  end

  context "a user visits a .pdf release" do
    before do
      ENV['IS_A_RESQUE_WORKER'] = "false"
    end

    context "and the PDF doesn't exist" do
      scenario "it queues the PDF" do
        as_dt_admin do
          visit release_path(release, format: 'pdf')
          PdfGeneratorHighPriority.should have_queue_size_of(1)
        end
      end
    end

    context "and the PDF exists" do
      scenario "it returns the pdf" do
        Release.any_instance.stub(:pdf_ready_for?) { :true }
        # TODO: Why does Capybara redirect us to the login if the stubbed URL doesn't end in an extension
        # Release.any_instance.stub(:authenticated_s3_pdf_url).and_return('http://www.example.com/text.pdf')
        as_dt_admin do
          visit release_path(release, format: 'pdf')
          expect(current_url).to include("s3.amazonaws.com")
        end
      end
    end

    context "when the PDF is processing" do
      scenario "it returns a  please wait flash" do
        high_priority_generator
        as_dt_admin do
          visit release_path(release, format: 'pdf')
          page.should have_content(I18n.t('pdf.generating'))
        end
      end
    end

    context "and the PDF is in the publish queue" do
      scenario "it adds the pdf to the high priority queue" do
        release.save!
        as_dt_admin do
          visit release_path(release, format: 'pdf')
          PdfGeneratorHighPriority.should have_queued("Release", release.id, @dt.id)
        end
      end
      scenario "it removes the pdf from the publish queue" do
        release.save!
        as_dt_admin do
          visit release_path(release, format: 'pdf')
          PdfGenerator.should_not have_queued("Release", release.id, @dt.id)
        end
      end
    end

  end


end
