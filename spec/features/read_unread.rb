require 'spec_helper'

feature "Read/Unread -" do
  background do
    init_channel_partners # 1 = appdirect, 2 = channel partner
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
    @release_past = FactoryGirl.create(:release, :published, :past)
    @release_present = FactoryGirl.create(:release, :published, :present)
    @page_present = FactoryGirl.create(:page)
    @channel_admin = FactoryGirl.create(:channel_admin, :channel_partner_id => @dt.id)
    ReadMark.delete_all
  end

  context "display should be available for everyone" do

    scenario "as channel admin" do
      as_dt_admin(@channel_admin) do
        visit release_path(@release_present)
        page.source.should have_selector('.indicator')
      end
    end

    scenario "as appdirect employee" do
      as_appdirect_employee do
        visit release_path(@release_present)
        page.source.should have_selector('.indicator')
      end
    end

  end

  context "pages marked as read should not display that to the user" do

    scenario "as channel admin" do
      as_dt_admin(@channel_admin) do
        @release_present.mark_as_read!( :for => @channel_admin)
        visit release_path(@release_present)
        page.source.should_not have_selector('.read.indicator')
      end
    end

  end

  context "unread pages should automatically mark themselves as read on load", :js => true do

    scenario "as channel admin" do
      as_dt_admin(@channel_admin) do
        ReadMark.delete_all
        visit release_path(@release_past)
        sleep(2)
        page.source.should have_selector('.read.indicator')        
      end
    end

  end

  context "the homepage should load with recently published > unread only as default", :js => true do

    scenario "as channel admin" do
      as_dt_admin(@channel_admin) do
        ReadMark.delete_all
        visit root_path
        page.should have_selector('div.unread', :count => 3)
      end
    end

  end

  context "read items should not appear in unread only", :js => true do

    scenario "as channel admin" do
      as_dt_admin(@channel_admin) do
        ReadMark.delete_all
        @page_present.mark_as_read!( :for => @channel_admin )
        visit root_path
        page.should have_selector('div.unread', :count => 2)
      end
    end

  end

  context "count should match the number of unread items", :js => true do

    scenario "as channel admin" do
      as_dt_admin(@channel_admin) do
        ReadMark.delete_all
        visit root_path
        page.should have_selector('span.count', :text => "3")
      end
    end

  end

  context "read items within the last 30 days should appear in 30 day tab", :js => true do

    scenario "as channel admin" do
      as_dt_admin(@channel_admin) do
        ReadMark.delete_all
        @page_present.mark_as_read!( :for => @channel_admin )
        visit root_path
        page.find("#rp_time_30days").click
        page.should have_selector('div.read', :count => 1)
      end
    end

  end

end