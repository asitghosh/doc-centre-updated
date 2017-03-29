require 'spec_helper'

feature "Pages", :js => true do
  background do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
    @guides = FactoryGirl.create(:manual, :redirect, :title => "manuals", :sortable_order => 1)
    @parent_page = @guides.children.create(FactoryGirl.attributes_for(:manual, :redirect, :sortable_order => 2, :type => "Manual"))
    @child_page = @parent_page.children.create(FactoryGirl.attributes_for(:manual, :title => "Child Page", :sortable_order => 3, :type => "Manual"))
    @draft_child = @parent_page.children.create(FactoryGirl.attributes_for(:manual, :draft, :sortable_order => 4, :type => "Manual"))

    # need to run the callbacks to get the permalink to take
    @parent_page.run_callbacks(:save)
    @child_page.run_callbacks(:save)
    @draft_child.run_callbacks(:save)
    @passage = @child_page.passages.create(FactoryGirl.attributes_for(:passage))



    # specfic content for channel partner
    @specific_content = @child_page.channel_specific_contents.create(:channel_partner_ids => [@dt.id], :content => "this is some content for Partner Channel")
  end


  context "Signing In" do

    scenario "as a visitor" do
      visit @parent_page.permalink
      page.should have_selector('#login_link')
    end

    scenario 'as a non-employee' do
      as_visitor do
        visit @parent_page.permalink
        page.should have_content("Access Denied")
      end
    end

    scenario 'as a channel admin' do
      as_dt_admin do
        visit @parent_page.permalink
        page.should have_selector "h1", :text => "Manuals"
      end
    end

  end

  context "redirecting to first child" do

    scenario "as a channel admin" do
      as_dt_admin do
        visit @parent_page.permalink
        current_path.should == @child_page.permalink
      end
    end

  end

  context "include content from passages on page", :js => false do
    # javascript disabled as this sometimes throws an error with the mark as read function
    scenario "as a channel admin" do
      as_dt_admin do
        visit @child_page.permalink
        page.should have_content(@passage.content)
      end
    end
  end

  context "draft page link inclusion" do

    scenario "as a channel admin" do
      as_dt_admin do
        visit @parent_page.permalink
        page.should_not have_link @draft_child.title
      end
    end

    scenario "as an appdirect user" do
      as_appdirect_employee do
        visit @parent_page.permalink
        page.should_not have_link @draft_child.title
      end
    end

    scenario "as a superadmin (who sees all)" do
      as_superadmin do
        visit @parent_page.permalink
        page.should have_link @draft_child.title
      end
    end

  end

  ## HOMEPAGE ----

  describe "homepage" do

    scenario "support links with no support link in the database" do
      as_dt_admin do
        visit root_path
        page.find('aside.right-col').should_not have_content('Support')
      end
    end

  end

  ## ROADMAP ----

  # describe "roadmap" do
  #
  #   context "should have the roadmap headline" do
  #     scenario "as a channel admin" do
  #       as_dt_admin do
  #         visit @roadmap.permalink
  #         page.should have_selector "h1", :text => "Roadmap"
  #       end
  #     end
  #   end
  #
  #   context "should redirect to first child" do
  #     scenario "as a channel admin" do
  #       as_dt_admin do
  #         visit @roadmap.permalink
  #         current_path.should == @quarter.permalink
  #       end
  #     end
  #   end
  #
  #   context "shouldn't show the sidenav for guides" do
  #     scenario "as a channel admin" do
  #       as_dt_admin do
  #         visit @roadmap.permalink
  #         page.should_not have_link @child_page.title
  #       end
  #     end
  #   end
  #
  # end

end
