require 'spec_helper'

feature "Active Admin" do
  background do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
  end

  context "access rights" do

    scenario "as a channel admin" do
      as_dt_admin do
        visit "/admin"
        page.should_not have_content "Dashboard"
      end
    end

    scenario "as an appdirect employee" do
      as_appdirect_employee do
        visit "/admin"
        page.should_not have_content "Dashboard"
      end
    end

    scenario "as a superuser" do
      as_superadmin do
        visit "/admin"
        page.should have_content "Dashboard"
      end
    end

  end

  context "resque dashboard access" do

    scenario "as channel admin" do
      as_dt_admin do
        visit "/admin/resque/overview"
        page.should_not have_content "Queues"
      end
    end

    scenario "as superadmin" do
      as_superadmin do
        visit "/admin/resque/overview"
        page.should have_content "Queues"
      end
    end

  end
end