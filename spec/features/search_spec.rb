require 'spec_helper'

feature "Search", :js => true do

  background do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
  end

  let!(:draft){ FactoryGirl.create(:release, :draft, :future, :title => "draft") }
  let!(:current){ FactoryGirl.create(:release, :present, :published) }
  let!(:att_specific){ current.channel_specific_contents.create(:channel_partner_ids => [@att.id], :content => "attstring", :whitelist => true)}
  let!(:dt_specific){ current.channel_specific_contents.create(:channel_partner_ids => [@dt.id], :content => "dtstring", :whitelist => true)}

  let!(:draft_page){ FactoryGirl.create(:manual, :draft, :title => "pagestringforsearch") }
  let!(:published_page){ FactoryGirl.create(:manual, :title => "publishedpageforsearch") }

  let!(:draft_roadmap){ FactoryGirl.create(:roadmap, :draft, :title => "draftroadmapforsearch") }
  let!(:published_roadmap){ FactoryGirl.create(:roadmap, :planned, :title => "publishedroadmapforsearch") }


  describe "what gets indexed" do
    before do
      Release.reindex
      Manual.reindex
      Support.reindex
      Faq.reindex
      Roadmap.reindex
      sleep 2
    end

    scenario "should not include draft releases" do
      as_dt_admin do
        visit '/search?q=Release%20draft&index=All'
        page.find(".search_results").should_not have_css('.search_result')
      end
    end

    scenario "should not include draft pages" do
      as_dt_admin do
        visit '/search?q=pagestringforsearch&index=All'
        page.find(".search_results").should_not have_css('.search_result')
      end
    end

    scenario "should not include draft roadmaps" do
      as_dt_admin do
        visit '/search?q=draftroadmapforsearch&index=All'
        page.find(".search_results").should_not have_css('.search_result')
      end
    end

    scenario "should include published release" do
      as_dt_admin do
        visit "/search?q=Release%20#{current.title}&index=All"
        #save_and_open_page
        page.find('.search_results').should have_css('.search_result')
      end
    end

    scenario "should include published pages" do
      as_dt_admin do
        visit "/search?q=publishedpageforsearch&index=All"
        #save_and_open_page
        page.find('.search_results').should have_css('.search_result')
      end
    end

    scenario "should include published roadmaps" do
      as_dt_admin do
        visit "/search?q=publishedroadmapforsearch&index=All"
        #save_and_open_page
        page.find('.search_results').should have_css('.search_result')
      end
    end
  end

  describe "what gets returned" do
    before do
      Release.reindex
      Manual.reindex
      Support.reindex
      Faq.reindex
      Roadmap.reindex
      sleep 2
    end
    scenario "dt shouldn't search att strings" do
      as_dt_admin do
        visit '/search?q=attstring&index=All'
        page.find(".search_results").should_not have_css('.search_result')
      end
    end

    scenario "dt should search dt strings" do
      as_dt_admin do
        visit '/search?q=dtstring&index=All'
        page.find(".search_results").should have_css('.search_result')
      end
    end

    scenario "att shouldn't search dt strings" do
      as_att_admin do
        visit '/search?q=dtstring&index=All'
        page.find(".search_results").should_not have_css('.search_result')
      end
    end

    scenario "att should search att strings" do
      as_att_admin do
        visit '/search?q=attstring&index=All'
        page.find(".search_results").should have_css('.search_result')
      end
    end

  end

end
