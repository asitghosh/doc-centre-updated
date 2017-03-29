require 'spec_helper'

feature "Login Flow" do

  background  do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
  end

  context "as a non-logged in user" do
    it "shows the page" do
      visit root_path
      page.should have_selector('#login_link')
    end

    it "denies access to the homepage" do
      visit root_path
      page.should have_selector('#login_link')
    end

    it "denies access to features" do
      visit "/releases"
      page.should have_selector('#login_link')
    end

    it "denies access to guides" do
      visit "/guides"
      page.should have_selector('#login_link')
    end

    it "denies access to features" do
      visit "/features"
      page.should have_selector('#login_link')
    end

    it "denies access to faqs" do
      visit "/faqs"
      page.should have_selector('#login_link')
    end
  end

  context "as a multitenant user" do
    background do
      Capybara.app_host = "http://#{@multitenant.subdomain}.docs.lvh.me"
    end
    it "prompts me to log in via MyApps" do
      visit root_path
      page.should have_content("MyApps")
    end
  end


  context "as a non-employee AppDirect.com user" do
    background do
      set_mock_as(:non_user)
    end

    it "disallows access the Doc Center", :js do
      visit root_path
      click_link('login_link')
      page.should have_content("Access Denied")
    end
  end

  context "as a logged-in an AppDirect employee" do
    background do
      set_mock_as(:appdirect_employee)
    end

    it "hides and disallows access to the admin panel", :js do
      visit root_path
      click_link('login_link')
      page.should_not have_content("Admin")
      visit "/admin"
      page.should have_content(/Unauthorized Access!/i)
    end

    it "allows searching releases", :js do
      visit root_path
      click_link('login_link')
      page.should_not have_content("Admin")
      visit "/releases"
      
    end

  end

  context "as a logged-in an Channel Partner admin" do
    background do
      set_mock_as(:channel_admin)
    end

    it "hides and disallows access to the admin panel", :js do
      visit root_path
      click_link('login_link')
      page.should_not have_content("Admin")
      visit "/admin"
      page.should have_content(/Unauthorized Access!/i)
    end
    
  end




  # it "through AppDirect.com", :vcr, :js => true do

  #   binding.pry
  #   click_link('login_link')
  #   fill_in "username", with: "jake.mauer@appdirect.com"
  #   fill_in "Password", with: "adK@m1nsk1"
  #   click on "Allow"
  #   page.should have_content('Successfully authenticated from open_id account.')
  # end

end