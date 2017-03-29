require 'spec_helper'

feature "Channel Partners" do
  let!(:roadmap){ FactoryGirl.create(:page, :redirect, :title => "Roadmap", :sortable_order => 5) }
  let!(:release){ FactoryGirl.create(:release, :present, :published) }
  let!(:roadmap_child){ roadmap.children.create(FactoryGirl.attributes_for(:page, :title => "Y2013", :body => "yup, roadmap", :sortable_order => 6)) }
  let!(:new_faq) { Faq.create(:question => "question", :answer => "answer", :pub_status => "published") }
  let!(:new_page) { Page.create(:title => "guides", :body => "guide content", :pub_status => "published") }
  let!(:support){ FactoryGirl.create(:support, :title => "This is a Support Guide", :sortable_order => 6)}
  let!(:public_page){ FactoryGirl.create(:api, :title => "Billing", :sortable_order => 7)}

  background do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
    roadmap_child.run_callbacks(:save)
  end

  describe "with all permissions" do
    scenario "should allow access to releases" do
      as_superadmin do
        visit releases_path
        page.should_not have_content "403"
      end
    end

    scenario "should allow access to supports" do
      as_superadmin do
        visit supports_path
        page.should_not have_content "403"
      end
    end

    scenario "should allow access to roadmap" do
      as_superadmin do
        visit "/roadmap"
        page.should_not have_content "403"
      end
    end

    scenario "should allow access to user guide" do
      as_superadmin do
        visit "/guides"
        page.should_not have_content "403"
      end
    end

    scenario "should allow access to FAQ" do
      as_superadmin do
        visit faqs_path
        page.should_not have_content "403"
      end
    end

  end

  describe "without releases permissions" do
    before do
      @dt.update_column(:able_to_see_releases, false)
    end

    after do
      @dt.update_column(:able_to_see_releases, true)
    end

    scenario "should not allow access to releases" do
      as_dt_admin do
        visit releases_path
        page.should have_content "403"
      end
    end

    scenario "should be disabled in the header" do
      as_dt_admin do
        visit root_path
        page.should have_css('li#releases.disabled')
      end
    end

    scenario "should be disabled in the footer" do
      as_dt_admin do
        visit root_path
        page.should have_css('li#footer_releases.disabled')
      end
    end

    scenario "should not show current release on homepage" do
      as_dt_admin do
        visit root_path
        page.find('.right-col').should_not have_content release.title
      end
    end

    scenario "should not show release in table" do
      as_dt_admin do
        visit root_path
        page.find('.updates_table').should_not have_content release.title
      end
    end
  end

  describe "without supports permissions" do
    before do
      @dt.update_column(:able_to_see_supports, false)
    end

    after do
      @dt.update_column(:able_to_see_supports, true)
    end

    scenario "should not allow access to supports" do
      as_dt_admin do
        visit supports_path
        page.should have_content "403"
      end
    end

    # scenario "should be disabled in the header" do
    #   as_dt_admin do
    #     visit root_path
    #     page.should have_css('li#supports.disabled')
    #   end
    # end

    # scenario "should be disabled in the footer" do
    #   as_dt_admin do
    #     visit root_path
    #     page.should have_css('li#footer_supports.disabled')
    #   end
    # end

    # scenario "should not show release in table" do
    #   as_dt_admin do
    #     visit root_path
    #     page.find('.updates_table').should_not have_content release.title
    #   end
    # end
  end

  describe "without roadmap permissions" do
    before do
      @dt.update_column(:able_to_see_roadmaps, false)
    end

    after do
      @dt.update_column(:able_to_see_roadmaps, true)
    end

    scenario "should not allow access to roadmap" do
      as_dt_admin do
        visit "/roadmaps"
        page.should have_content "403"
      end
    end

    scenario "should be disabled in the header" do
      as_dt_admin do
        visit root_path
        page.should have_css('li#roadmap.disabled')
      end
    end

    scenario "should be disabled in the footer" do
      as_dt_admin do
        visit root_path
        page.should have_css('li#footer_roadmap.disabled')
      end
    end

    scenario "should not show in the homepage table" do
      as_dt_admin do
        visit root_path
        page.find('.updates_table').should_not have_content roadmap_child.title
      end
    end
  end

  describe "without user guide permissions" do
    before do
      @dt.update_column(:able_to_see_user_guides, false)
    end

    after do
      @dt.update_column(:able_to_see_user_guides, true)
    end

    scenario "should not allow access to user guides" do
      as_dt_admin do
        visit "/guides"
        page.should have_content "403"
      end
    end

    scenario "should be disabled in the header" do
      as_dt_admin do
        visit root_path
        page.should have_css('li#user_manual.disabled')
      end
    end

    scenario "should be disabled in the footer" do
      as_dt_admin do
        visit root_path
        page.should have_css('li#footer_user_manual.disabled')
      end
    end


    scenario "should not show in the homepage table" do
      as_dt_admin do
        visit root_path
        page.find('.updates_table').should_not have_content new_page.title
      end
    end
  end

  describe "without FAQ permissions" do
    before do
      @dt.update_column(:able_to_see_faqs, false)
    end

    after do
      @dt.update_column(:able_to_see_faqs, true)
    end

    scenario "should not allow access to user guides" do
      as_dt_admin do
        visit "/faqs"
        page.should have_content "403"
      end
    end

    scenario "should be disabled in the header" do
      as_dt_admin do
        visit root_path
        page.should have_css('li#faq.disabled')
      end
    end

    scenario "should be disabled in the footer" do
      as_dt_admin do
        visit root_path
        page.should have_css('li#footer_faq.disabled')
      end
    end
  end

  describe "with no account" do
    before do
      Capybara.app_host = "http://docs.lvh.me"
      FactoryGirl.create(:superadmin, :email => "superadmin@appdirect.com", :channel_partner => @appdirect, :name => "superadmin" )
    end

    scenario "it should redirect the user to public pages" do
      as_anon_user do
        visit root_path
        page.should have_content public_page.title
      end
    end

    scenario "it shouldn't allow access to release notes" do
      as_anon_user do
        visit releases_path
        page.should have_content("404")
      end
    end

    scenario "it shouldn't allow access to roadmap" do
      as_anon_user do
        visit "/roadmaps"
        page.should have_content("404")
      end
    end

    scenario "it shouldn't allow access to FAQs" do
      as_anon_user do
        visit "/faqs"
        page.should have_content("404")
      end
    end

    scenario "it shouldn't allow access to guides" do
      as_anon_user do
        visit "/manuals"
        page.should have_content("404")
      end
    end

    scenario "the login page should have the user enter their email address" do
      as_anon_user do
        visit "/login"
        page.should have_css('#user_email')
      end
    end

    scenario "entering an email address should redirect the user to that channel partner subdomain" do
      as_anon_user do
        visit "/login"
        page.fill_in 'user[email]', :with => "superadmin@appdirect.com"
        page.find('input[type="submit"]').click
        #since we mock the appdirect auth response this should allow the login and redirect to root_path
        current_url.should include("ad")
      end
    end

  end

end
