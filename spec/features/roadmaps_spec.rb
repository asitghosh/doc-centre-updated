require 'spec_helper'

feature "Roadmaps", :js => true do
  let!(:year){  FactoryGirl.create(:roadmap, title: "2013") }
  let!(:quarter){ year.children.create(FactoryGirl.attributes_for(:roadmap, title: "q1")) }
  let!(:entry){ quarter.children.create(FactoryGirl.attributes_for(:roadmap, title: "feature 1")) }
  let!(:draft){ quarter.children.create(FactoryGirl.attributes_for(:roadmap, :draft)) }

  background do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"

  end

  describe "permissions" do
    before do
      @dt.update_column(:able_to_see_roadmaps, false)
    end

    after do
      @dt.update_column(:able_to_see_roadmaps, true)
    end

    scenario "should not allow access to releases" do
      as_dt_admin do
        visit roadmaps_path
        page.should have_content "403"
      end
    end
  end

  describe "content" do

    scenario "should be labelled as a Roadmap", :js => false do
      # running this without javascript to prevent the ajax call to mark the record as read which
      # fails for some reason. TODO: fix that.
      as_dt_admin do
        visit roadmaps_path
        page.should have_selector "h1", :text => "Roadmap"
      end
    end
  #
    scenario "the index should redirect to the latest year's quarter" do
      as_dt_admin do
        visit roadmaps_path

        current_path.should == quarter.permalink
      end
    end

  #
    scenario "the draft shouldn't appear in the navigation" do
      as_dt_admin do
        visit roadmaps_path
        #binding.pry
        page.should_not have_link draft.title
      end
    end
  end
end
