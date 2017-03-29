require "spec_helper"

describe EventNotification do
	before do
		init_channel_partners
		release_mailing_list.users << [dt_subscriber, att_subscriber, not_subbed_to_hotfix, appdirect_subscriber]
		hotfix_mailing_list.users << [dt_subscriber, att_subscriber]
		@att.account_reps << account_rep
		@dt.account_reps << account_rep
		@appdirect.account_reps << account_rep
	end
	subject(:release){ FactoryGirl.create(:release, :published, :present) }
	let(:release_mailing_list){ MailingList.create(:title => "Release Notification", :joinable => true, :internal_only => false) }
	let(:hotfix_mailing_list){ MailingList.create(:title => "Release Notification", :joinable => true, :internal_only => false) }
	let(:dt_subscriber){ FactoryGirl.create(:channel_admin, :email => "dt@example.com", :channel_partner_id => @dt.id) }
	let(:att_subscriber){ FactoryGirl.create(:channel_admin, :email => "att@example.com", :channel_partner_id => @att.id) }
	let(:appdirect_subscriber){ FactoryGirl.create(:channel_admin, :email => "appdirect@appdirect.com", :channel_partner_id => @appdirect.id ) }
	let(:not_subbed_to_hotfix){ FactoryGirl.create(:channel_admin, :email => "dt2@example.com", :channel_partner_id => @dt.id) }
	let!(:att_information){ release.channel_specific_contents.create({ :channel_partner_ids => [@att.id], :content => "ATT content", :whitelist => true }) }
	let!(:dt_information){ release.channel_specific_contents.create({ :channel_partner_ids => [@dt.id], :content => "DT content", :whitelist => true }) }
	let(:account_rep){ FactoryGirl.create(:account_rep, :channel_partner_id => @appdirect.id) }

	describe "AASM integration" do

		it "shouldn't fire when we change state to revised" do
			Release.any_instance.should_not_receive(:email_notification_subscribers)
			release.revise!
		end

		it "should fire when we change state to finalized" do
			release.revise!
			Release.any_instance.should_receive(:email_notification_subscribers)
			release.finalize!
		end
	end

	describe "Sending Release Email to DT" do
		let(:mail){ EventNotification.send_mail(release.class.to_s, release.id, @dt.id, release_mailing_list.id) }
		let(:sendgrid_header){ ActiveSupport::JSON.decode(mail.header['X-SMTPAPI'].value) }
	  let(:channel_partner_url_base){ "http://#{@dt.subdomain}.docs.appdirect.com" }
	  let(:html){ Capybara::Node::Simple.new(get_message_part(mail, /html/)) }

	  before do
	  	#TODO: find a better way to stub this out, the worker fails if you don't provide a valid URL
	  	Release.any_instance.should_receive(:authenticated_s3_pdf_url).and_return("http://google.com")
			Release.any_instance.should_receive(:pdf_exists_for?).and_return(true)
	  end

  	it "should use the Mailing List title as subject line" do
  		mail.subject.should include(release.title.to_s)
  	end

  	it "should have smtpapi headers that includes dt_subscriber" do
  		sendgrid_header["to"].should include(dt_subscriber.email)
  	end

  	it "should not have smtpapi headers that include att_subscriber" do
  		sendgrid_header["to"].should_not include(att_subscriber.email)
  	end

  	it "should include the release number" do
  		mail.encoded.should include("#{release.title}")
  	end

	it "should not include a link to AT&T specific information" do
		mail.body.encoded.should_not match("#{channel_partner_url_base}/releases/#{release.title}##{@att.name.parameterize}")
	end

	it "should include a link to DT specific information" do
		#binding.pry
		expect(html).to have_link("#{@dt.name}", :href => "#{channel_partner_url_base}/releases/#{release.title}##{@dt.name.parameterize}" )
		#mail.body.encoded.should match("#{channel_partner_url_base}/releases/#{release.title}##{@dt.name.parameterize}")
	end

  	it "should include a link to the release" do
  		mail.body.encoded.should match("#{channel_partner_url_base}/releases/#{release.title}")
  	end

  	it "should include the release summary" do
  		mail.body.parts.find {|p| p.content_type.match /html/}.body.raw_source.should include("#{release.summary}")
  	end

  	it "should include an attachment" do
  		mail.attachments.should_not be_empty
  	end
	end

	describe "Sending Hotfix to ATT" do
		let!(:hotfix){ release.hotfixes.create(:number => "#{release.title}.1", :content => "this is a hotfix", :channel_partner_ids => @att.id, :pub_status => "published") }
		let(:mail){ EventNotification.send_mail(release.class.to_s, release.id, @att.id, hotfix_mailing_list.id) }
		let(:sendgrid_header){ ActiveSupport::JSON.decode(mail.header['X-SMTPAPI'].value) }
		let(:channel_partner_url_base){ "http://#{@att.subdomain}.docs.appdirect.com" }

		before do
	  	#TODO: find a better way to stub this out, the worker fails if you don't provide a valid URL
	  	Release.any_instance.should_receive(:authenticated_s3_pdf_url).and_return("http://google.com")
			Release.any_instance.should_receive(:pdf_exists_for?).and_return(true)
	  end

  	it "should use the Mailing List title as subject line" do
  		mail.subject.should include(release.title.to_s)
  	end

  	it "should have smtpapi headers that includes att_subscriber" do
  		sendgrid_header["to"].should include(att_subscriber.email)
  	end

  	it "should not have smtpapi headers that include dt_subscriber" do
  		sendgrid_header["to"].should_not include(dt_subscriber.email)
  	end

		it "should not include non-subscribed users" do
			sendgrid_header["to"].should_not include(not_subbed_to_hotfix.email)
		end

  	it "should include a link to the release" do
  		mail.body.encoded.should match("#{channel_partner_url_base}/releases/#{release.title}")
  	end

  	it "should include the hotfix number" do
  		mail.body.encoded.should include("#{hotfix.number}")
  	end

  	it "should include the phrase 'Hotfix Published'" do
  		mail.body.encoded.should include("Hotfix Published")
  	end

  	it "should include the hotfix content (yes, all of it.)" do
  		mail.encoded.should include("#{hotfix.content}")
  	end

  	it "should include an attachment" do
  		mail.attachments.should_not be_empty
  	end
  end


end
