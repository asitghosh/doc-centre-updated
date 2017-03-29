require 'spec_helper'

feature "Impersonation -" do
  background do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
    @past = FactoryGirl.create(:release, :published, :past)
    @present = FactoryGirl.create(:release, :published, :present)
    @future = FactoryGirl.create(:release, :published, :future)
    @draft = FactoryGirl.create(:release, :draft, :future)
    @appdirect_specific = @present.channel_specific_contents.create(:channel_partner_ids => [@appdirect.id], :content => "this is some content for AppDirect Specifically")
    @partner_specific = @present.channel_specific_contents.create(:channel_partner_ids => [@dt.id], :content => "this is some content for Partner Channel")
  end

  context "impersonation display" do

    scenario "as channel admin" do
      as_dt_admin do
        visit root_path
        page.should_not have_content("View Site As")
      end
    end

    scenario "as appdirect employee" do
      as_appdirect_employee do
        visit root_path
        page.source.should have_selector '.impersonation'
      end
    end

  end


  context "impersonation request" do

    scenario "as channel admin" do
      as_dt_admin do
        visit "/impersonate/2"
        page.should have_content "404"
      end
    end

  end


  context "unimpersonate request" do

    scenario "as channel admin" do
      as_dt_admin do
        visit "/unimpersonate"
        page.should have_content "404"
      end
    end

  end

  context "see all.js inclusion on page", :js => true do

    scenario "as channel admin" do
      as_dt_admin do
        visit root_path
        page.source.should_not have_xpath("//script[contains(@src, 'see_all.js')]")
      end
    end

    scenario "as appdirect employee" do
      as_superadmin do
        visit root_path
        page.source.should have_xpath("//script[contains(@src, 'see_all.js')]")
      end
    end

  end

  context "chosen.css inclusion on page", :js => true do
    # CHOSEN IS GLOBAL IN OUR NEW POST-SEARCH WORLD.
    # scenario "as channel admin" do
    #   as_dt_admin do
    #     visit root_path
    #     page.source.should_not have_xpath("//link[contains(@href, 'chosen.css')]")
    #   end
    # end
    #
    # scenario "as appdirect employee" do
    #   as_superadmin do
    #     visit root_path
    #     page.source.should have_xpath("//link[contains(@href, 'chosen.css')]")
    #   end
    # end

  end

  context "selecting a channel to impersonate", :js => true do

    scenario "should cause the admin link to dissapear" do
      as_superadmin do
        visit root_path
        page.select @att.name , :from => 'partner'
        sleep(4)
        page.should_not have_link('Admin')
      end
    end

    scenario "should remove draft releases" do
      as_superadmin do
        visit root_path
        page.select @att.name , :from => 'partner'
        visit releases_path
        page.source.should_not have_selector(".draft")
      end
    end

    scenario "should remove the status bar" do
      as_superadmin do
        visit root_path
        page.select @att.name, :from => 'partner'
        visit release_path(@present)
        page.source.should_not have_selector('.flash_container')
      end
    end

    scenario "other partner specific data" do
      as_superadmin do
        visit root_path
        page.select @att.name, :from => 'partner'
        visit release_path(@present)
        # save_and_open_page
        page.should_not have_content(@appdirect_specific.content)
      end
    end

    scenario "the impersonation bar should persist" do
      as_superadmin(@superadmin) do
        visit root_path
        page.select @att.name, :from => 'partner'
        visit release_path(@present)
        #page.save_screenshot(Rails.root.join('tmp', 'screen4.png'))
        find("body").should have_content("Viewing Site As")
      end
    end

  end

  context "stop impersonation", :js => true do

    scenario "admin link should return afterwards" do
      as_superadmin do
        visit root_path
        page.select @att.name, :from => 'partner'
        sleep(1)
        click_button('Stop Impersonating')
        sleep(2)
        #page.save_screenshot(Rails.root.join('tmp', 'screen3.png'))
        page.source.should have_selector('#admin', :visible => false)
      end
    end

  end

end
