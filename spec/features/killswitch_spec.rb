require 'spec_helper'

feature "Killswitch", :js => true do
	background do
    init_channel_partners # 1 = appdirect, 2 = channel partner
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"

		@backenduser = FactoryGirl.create(:appdirect_employee, :email => "employee@appdirect.com", :channel_partner_id => @appdirect.id)
		@backenduser.add_role(:account_rep)
    @killswitch = AppSettings.find_by_key("superadmin_only_mode")
    @killswitch.update_column(:value, "false")
  end

  after do
    @killswitch.update_column(:value, "false")
  end


  describe "route permissions" do
    scenario 'as a channel admin' do
      as_dt_admin do
        visit '/toggle_superadmin_only_mode'
        page.should have_content '404' # because the route doesn't exist for non superadmins, it will fall into the wildcard for pages and 404
      end
    end

    scenario 'as an appdirect employee' do
    	as_appdirect_employee do
    		visit '/toggle_superadmin_only_mode'
    		page.should have_content '404'
    	end
    end

    scenario 'as a super admin' do
    	as_superadmin do
    		visit '/toggle_superadmin_only_mode'
    		page.should have_content 'Dashboard'
    	end
    end

  end

  describe "dashboard button" do
  	scenario 'as an appdirect employee' do
  		as_appdirect_employee(@backenduser) do
  			visit "/admin"
  			page.should_not have_content "Lock the Documentation Center"
  		end
  	end

  	scenario 'as a superadmin' do
  		as_superadmin do
  			visit "/admin"
  			page.should have_content "Lock the Documentation Center"
  		end
  	end

  end

  describe "enabling killswitch" do
    before do
        @killswitch.update_column(:value, "false")
      end
  	scenario "pushing the button" do

	  	as_superadmin do
	  		visit "/admin"
	  		page.click_link("Initiate Lockdown Mode")
	  		page.evaluate_script('window.confirm = function() { return true; }')
	  		page.should have_content "Public Access is denied."
	  	end
	  end

  end

  describe "while the killswitch is enabled" do
  	before do
      @killswitch.update_column(:value, "true")
  	end

  	scenario "as a channel admin" do
  		as_dt_admin do
  			visit root_path
  			page.should have_content "Sorry!"
  		end
  	end

  	scenario "as an appdirect employee" do
  		as_appdirect_employee do
  			visit root_path
  			page.should have_content "Sorry!"
  		end
  	end

  	scenario "as a superadmin" do
  		as_superadmin do
  			visit root_path
  			page.should have_content "Public Access is denied."
  		end
  	end

  	scenario "impersonation should still work" do
  		as_superadmin do
	  		visit root_path
	      page.select @att.name, :from => 'partner'
	      page.should_not have_link('Admin')
	    end
	  end

  end

  describe "disabling the killswitch" do
    before do
      @killswitch.update_column(:value, "true")
    end
  	scenario "pushing the button" do

  		as_superadmin do
	  		visit "/admin"
	  		page.click_link("Disable Lockdown Mode")
	  		page.evaluate_script('window.confirm = function() { return true; }')
	  		visit root_path
	  		page.should_not have_content "Public Access is denied."
	  	end
	  end

	end

end
