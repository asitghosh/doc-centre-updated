require 'spec_helper'

feature "Homepage Grid", :js => true do
  before do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
  end

  let!(:guide){ FactoryGirl.create(:manual) }
  let!(:draft){ FactoryGirl.create(:manual, :draft) }
  let!(:release){ FactoryGirl.create(:release, :published, :present) }
  let!(:old_release){ FactoryGirl.create(:very_old_release, :published, :past) }
  let!(:roadmap_root){ FactoryGirl.create(:roadmap, :in_progress)}
  let!(:roadmap){ roadmap_root.children.create(FactoryGirl.attributes_for(:roadmap, :in_progress))}

  context "tab controls" do

    it "should load with recently published visible" do
      as_dt_admin do
        visit root_path
        expect(page.find('#recently_published')).to be_visible
      end
    end

    it "should show changes when you click on that tab" do
      as_dt_admin do
        visit root_path
        find_link('Changes').click
        expect(page.find('#changes')).to be_visible
      end
    end

  end

  context "time controls" do
    # TODO: figure out how to get around simplestore (js localstorage/cookie library) and test this
    # it "should load with a default state of Unread Only" do
    #   as_dt_admin do
    #     visit root_path
    #     expect(page).to have_css('#rp_time_unread.active')
    #   end
    # end

  end

  context "What it shows" do
    it "should not include drafts" do
      as_dt_admin do
        visit root_path
        wait_for_ajax
        expect(page.find('.updates_table')).to_not have_link(draft.permalink)
      end
    end

    it "should include published guides" do
      as_dt_admin do
        visit root_path
        wait_for_ajax
        expect(page.find('.updates_table')).to have_content(guide.title)
      end
    end

    it "should not include published roadmaps at the first level (years)" do
      as_dt_admin do
        visit root_path
        wait_for_ajax
        expect(page.find('.updates_table')).to_not have_content(roadmap_root.title)
      end
    end

    it "should include published roadmaps beyond the first level" do
      as_dt_admin do
        visit root_path
        wait_for_ajax
        expect(page.find('.updates_table')).to have_content(roadmap.title)
      end
    end

    it "should include published releases" do
      as_dt_admin do
        visit root_path
        wait_for_ajax
        expect(page.find('.updates_table')).to have_content(release.title)
      end
    end

    it "should not include items older than 30 days" do
      as_dt_admin do
        visit root_path
        wait_for_ajax
        expect(page.find('.updates_table #recently_published')).to_not have_content("Release #{old_release.title}")
      end
    end

  end


end
