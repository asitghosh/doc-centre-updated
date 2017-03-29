require 'spec_helper'

# THIS MODEL IS NO LONGER USED!

feature "Features" do
  # background do
  #   init_channel_partners
  #   Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
  #   @release = FactoryGirl.create(:release, :past, :published)
  #   @future_release = FactoryGirl.create(:release, :future, :published)
  #   @general_feature = FactoryGirl.create(:feature, :published)
  #   @channel_feature = FactoryGirl.create(:feature, :published, :channel_partner_ids => @dt.id)
  #   @assigned_feature = FactoryGirl.create(:feature, :published, :release_id => @release.id)
  #   @future_feature = FactoryGirl.create(:feature, :published, :release_id => @future_release.id)
  # end

  # #index redirects to first feature user has access to, so we are testing both actions here
  # describe "Index and Show" do
  #   context "as a non-logged in user" do
  #     it "directs the user to log in" do
  #       visit features_path
  #       save_and_open_page
  #       page.should have_selector('#login_link')
  #     end
  #   end

  #   context "access rights" do
  #     scenario "as a non channel admin user" do
  #       as_visitor do
  #         visit features_path
  #         page.should have_content("Access Denied")
  #       end
  #     end

  #     scenario "as a channel admin" do
  #       as_dt_admin do
  #         visit features_path
  #         page.should have_content("Upcoming Features")
  #       end
  #     end

  #     # everyone above channel admin has access, not testing those.

  #   end

  #   context "features_path redirects to first feature" do

  #     scenario "as a channel admin" do
  #       as_dt_admin do
  #         visit features_path
  #         page.should have_content(@general_feature.title)
  #       end
  #     end

  #   end

  #   context "the side nav should show channel-specific features" do

  #     scenario "as channel admin" do
  #       as_dt_admin do
  #         visit features_path
  #         page.should have_link(@channel_feature.title)
  #       end
  #     end

  #   end

  #   context "features assigned to releases should not show up" do

  #     # scenario "as channel admin" do
  #     #   as_dt_admin do
  #     #     visit features_path
  #     #     page.should_not have_link(@assigned_feature.title)
  #     #   end
  #     # end

  #   end

  #   context "features assigned to future releases should show" do

  #     scenario "as channel admin" do
  #       as_dt_admin do
  #         visit features_path
  #         page.should have_link(@future_feature.title)
  #       end
  #     end

  #   end
    
  #end
end