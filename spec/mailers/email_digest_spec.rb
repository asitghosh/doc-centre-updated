require "spec_helper"

describe EmailDigest do
	before do
		init_channel_partners
		@mailing_list = MailingList.create :title => "test digest", :joinable => true, :internal_only => false #because this is not titled "Daily Digest" it should use the weekly time range
		@new_release = FactoryGirl.create(:release, :present, :published)
		@very_old_release = FactoryGirl.create(:very_old_release, :past, :published)
		@hotfix = @new_release.hotfixes.create(:number => "#{@new_release.title}.1", :pub_status => "published", :content => "This is the hotfix content")
		@cp_hotfix = @new_release.hotfixes.create(:number => "#{@new_release.title}.2", :pub_status => "published", :content => "some specific content", :channel_partner_ids => [@appdirect.id])
		@page = Page.create(:title => "guides", :body => "body", :pub_status => "published")
		@support = FactoryGirl.create(:support, :title => "this is a support", :pub_status => "published")
		@roadmap = FactoryGirl.create(:roadmap, :title => "2013")
		@quarter = @roadmap.children.create(FactoryGirl.attributes_for(:roadmap, :title => "q1", :content => "yup, roadmap", :sortable_order => 6))
		@feature = @quarter.children.create(FactoryGirl.attributes_for(:roadmap))
		@user1 = FactoryGirl.create(:user, :channel_partner_id => @appdirect.id, :email => "user1@example.com")
		@user2 = FactoryGirl.create(:user, :channel_partner_id => @dt.id, :email => "user2@example.com")
    @no_role = FactoryGirl.create(:user, :channel_partner_id => @dt.id, :email => "no_roles@example.com")
		@account_rep = FactoryGirl.create(:account_rep, :channel_partner_id => @appdirect.id)
		@mailing_list.users << [@user1, @user2]

		@appdirect.account_reps << @account_rep
		@dt.account_reps << @account_rep

    @user1.add_role(:channel_admin)
    @user2.add_role(:editor)

	end

  describe "send_mail (to channel_partner 1)" do
  	let( :mail ) { EmailDigest.send_mail(@appdirect.id, @mailing_list.id) }
  	let ( :sendgrid_header ) { ActiveSupport::JSON.decode(mail.header['X-SMTPAPI'].value) }
  	let ( :channel_partner_url_base) { "http://#{@appdirect.subdomain}.docs.appdirect.com" }


  	it "should use the Mailing List title as subject line" do
  		mail.subject.should == @mailing_list.title
  	end

  	it "should have smtpapi headers that includes @user1" do
  		sendgrid_header["to"].should include(@user1.email)
  	end

  	it "should not have smtpapi headers that includes @user2" do
  		sendgrid_header["to"].should_not include(@user2.email)
  	end

  	it "should include the update settings url" do
  		mail.body.encoded.should match("#{channel_partner_url_base}/users/settings")
  	end

  	it "should not include the very old relase url" do
  		mail.body.encoded.should_not match("#{channel_partner_url_base}/releases/#{@very_old_release.title}")
  	end

  	it "should include the newer release url" do
  		mail.body.encoded.should match("#{channel_partner_url_base}/releases/#{@new_release.title}")
  	end

		it "should include the support guide" do
			mail.body.encoded.should match("#{@support.title}")
		end

  	it "should include the hotfix" do
  		mail.body.encoded.should match("#{@hotfix.title}")
  	end

  	it "should include the channel specific hotfix" do
  		mail.body.encoded.should match("#{@cp_hotfix.title}")
  	end

		it "should include the roadmap quarter" do
			mail.body.encoded.should match("#{@quarter.title}")
		end

		it "should include the roadmap entry" do
			mail.body.encoded.should match("#{@feature.title}")
		end

		it "should not include the roadmap year" do
			mail.body.encoded.should_not match("#{@roadmap.permalink}")
		end

  	it "should be from webadmin (no account rep)" do
  		mail.from.should == ["#{@account_rep.email}"]
  	end

  end

  describe "send_mail (to channel_partner 2)" do
  	let( :mail ) { EmailDigest.send_mail(@dt.id, @mailing_list.id) }
  	let ( :sendgrid_header ) { ActiveSupport::JSON.decode(mail.header['X-SMTPAPI'].value) }
  	let ( :channel_partner_url_base) { "http://#{@dt.subdomain}.docs.appdirect.com" }

  	it "should have smtpapi headers that includes @user2" do
  		sendgrid_header["to"].should include(@user2.email)
  	end

    it "shouldn't include a user with no roles" do
      sendgrid_header["to"].should_not include(@no_role.email)
    end

    it 'should be from the account rep' do
      mail.from.should == ["#{@account_rep.email}"]
    end

  	it "should not have smtpapi headers that includes @user1" do
  		sendgrid_header["to"].should_not include(@user1.email)
  	end

  	it "should include the hotfix" do
  		mail.body.encoded.should match("#{@hotfix.title}")
  	end

		it "should include the support guide" do
			mail.body.encoded.should match("#{@support.title}")
		end

  	it "should not include the channel specific hotfix" do
  		mail.body.encoded.should_not match("#{@cp_hotfix.title}")
  	end

  end

	describe "send email to a channel partner that isn't allowed to see release notes" do
		let( :mail ) { EmailDigest.send_mail(@dt.id, @mailing_list.id) }
		let ( :sendgrid_header ) { ActiveSupport::JSON.decode(mail.header['X-SMTPAPI'].value) }
		let ( :channel_partner_url_base) { "http://#{@dt.subdomain}.docs.appdirect.com" }

		before do
			@dt.update_column(:able_to_see_releases, false)
		end

		after do
			@dt.update_column(:able_to_see_releases, true)
		end

		it "shouldn't include any release data" do
			mail.body.encoded.should_not match("#{channel_partner_url_base}/releases/#{@new_release.title}")
		end
	end

	describe "send email to a channel partner that isn't allowed to see user guide" do
		let( :mail ) { EmailDigest.send_mail(@dt.id, @mailing_list.id) }
		let ( :sendgrid_header ) { ActiveSupport::JSON.decode(mail.header['X-SMTPAPI'].value) }
		let ( :channel_partner_url_base) { "http://#{@dt.subdomain}.docs.appdirect.com" }

		before do
			@dt.update_column(:able_to_see_user_guides, false)
		end

		after do
			@dt.update_column(:able_to_see_user_guides, true)
		end

		it "shouldn't include any user guide data" do
			mail.body.encoded.should_not have_content @page.title
		end
	end


	describe "send email to a channel partner that isn't allowed to see roadmaps" do
		let( :mail ) { EmailDigest.send_mail(@dt.id, @mailing_list.id) }
		let ( :sendgrid_header ) { ActiveSupport::JSON.decode(mail.header['X-SMTPAPI'].value) }
		let ( :channel_partner_url_base) { "http://#{@dt.subdomain}.docs.appdirect.com" }

		before do
			@dt.update_column(:able_to_see_roadmaps, false)
		end

		after do
			@dt.update_column(:able_to_see_roadmaps, true)
		end

		it "shouldn't include any user guide data" do
			mail.body.encoded.should_not have_content @feature.title
		end
	end

	describe "send email to a channel partner that isn't allowed to see supports" do
		let( :mail ) { EmailDigest.send_mail(@dt.id, @mailing_list.id) }
		let ( :sendgrid_header ) { ActiveSupport::JSON.decode(mail.header['X-SMTPAPI'].value) }
		let ( :channel_partner_url_base) { "http://#{@dt.subdomain}.docs.appdirect.com" }

		before do
			@dt.update_column(:able_to_see_supports, false)
		end

		after do
			@dt.update_column(:able_to_see_supports, true)
		end

		it "shouldn't include any user guide data" do
			mail.body.encoded.should_not have_content @support.title
		end
	end

end
