require 'spec_helper'

feature "Public Pages" do
	# for now, the public pages redirects to "billing", so we'll call our first page that
	let!(:public_page){ FactoryGirl.create(:api, :with_children, :title => "Billing", :sortable_order => 7) }
  let!(:sibling_page){ public_page.siblings.create(FactoryGirl.attributes_for(:api)) }
	let!(:child_page){ public_page.children.create(FactoryGirl.attributes_for(:api, :sortable_order => 8)) }
  let!(:draft_page){ public_page.children.create(FactoryGirl.attributes_for(:api, :draft)) }
	#TODO: create a child and a sibling to test navigation

	background do
	    init_channel_partners
	    public_page.run_callbacks(:save)
	    child_page.run_callbacks(:save)
      # @create_children = public_page.children.create(FactoryGirl.create_list(:api_with_children, 5))
	    Capybara.app_host = "http://docs.lvh.me"
  	end

  	scenario "the main navigation shouldn't include releases" do
      as_anon_user do
        visit root_path
        page.should_not have_selector(:link_or_button, 'Release Notes')
      end
  	end

  	scenario "the main navigation shouldn't include roadmaps" do
      as_anon_user do
        visit root_path
        page.should_not have_selector(:link_or_button, 'Roadmap')
      end
  	end

  	scenario "the main navigation shouldn't include FAQs" do
      as_anon_user do
        visit root_path
        page.should_not have_selector(:link_or_button, 'FAQs')
      end
  	end

  	scenario "the main navigation shouldn't include Manuals" do
      as_anon_user do
        visit root_path
        page.should_not have_selector(:link_or_button, 'Manuals')
      end
  	end

  	pending "the navigation should reflect a root level page's child pages" do
      as_anon_user do
        visit root_path
        public_page.children.each do |child|
          expect(find('.subnavigation')).to have_text child.title
        end
      end
    end

    pending "the navigation should not include sibling pages of the root level pages" do
      as_anon_user do
        visit child_page.permalink
        find('.subnavigation, .side-nav').should_not have_selector(:link_or_button, sibling_page.title)
      end         
   	end

   	scenario "the parent page should have .active when visiting its children" do
      as_anon_user do
        visit child_page.permalink
        expect(find('.dynamic-nav li.channel_color_border a.active')).to have_text child_page.title
      end
   	end

   	scenario "the navigation should be labelled with the root level page title" do
   		as_anon_user do
   			visit child_page.permalink
   			#save_and_open_page
   			expect(find('.dynamic-nav li.bold')).to have_text public_page.title
   		end
   	end

   	scenario "the navigation search should be limited to APIs" do
   		#check the value of index input is set to "Api"
      as_anon_user do
        visit root_path
        find('.header-search input#index')['value'].should == "Api"
      end
   	end

    scenario "the navigation should have a login link" do
    	as_anon_user do
    		visit root_path
    		#save_and_open_page
    		page.should have_selector(:link_or_button, 'Log In')
    	end
    end

    pending "anon users shouldn't see drafts" do
      as_anon_user do
        visit root_path
        find('.page_nav').should_not have_text draft_page.title
      end
    end
end