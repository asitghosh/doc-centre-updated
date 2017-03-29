require 'spec_helper'

feature "Hotfixes", :js => true do
    background do
        init_channel_partners
        Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
        @present = FactoryGirl.create(:release, :published, :present)
        @hotfix = @present.hotfixes.create( :number => "#{@present.title}.1", :content => "This is hotfix content", :pub_status => "published" )
        @hotfix2 = @present.hotfixes.create( :number => "#{@present.title}.2", :content => "This is some AppDirect content", :channel_partner_ids => [@dt.id], :pub_status => "published" )
        @hotfix_channel_specific_content = @hotfix.channel_specific_contents.create( :channel_partner_ids => [@appdirect.id], :content => "this is some content in hotfix1 for AppDirect Only")
        @draft_hotfix = @present.hotfixes.create( :number => "#{@present.title}.3", :content => "This is draft hotfix content", :pub_status => "draft" )
    end

   describe "Homepage" do

        scenario "as a logged in user the release should show a change of hotfix" do
            as_att_admin do
                visit root_path
                page.should have_content "Hotfix #{@hotfix.number}"
            end
        end

        scenario "private hotfixes should display their number to users with access" do
            as_dt_admin do
                visit root_path
                page.should have_content "Hotfix #{@hotfix2.number}"
            end
        end

        scenario "when the release is updated, the status should change to updated" do
            @present.summary = "new summary"
            @present.save

            as_dt_admin do
                visit root_path
                page.should_not have_content "Hotfix #{@hotfix.number}"
            end
        end

        scenario "when another hotfix is added, it should change to hotfix" do
            @present.summary = "new new summary"
            @present.save
            @present.hotfixes.create( :number => "#{@present.title}.3", :content => "a new hotfix", :pub_status => "published")

            as_dt_admin do
                visit root_path
                page.should have_content "Hotfix #{@present.title}.3"
            end
        end

   end

   describe "Releases#show" do
        scenario "The releases index should include the number of the releases" do
            as_dt_admin do
                visit releases_path
                page.find('.icon-hotfix')[:title].should have_content @hotfix.number
            end
        end

        scenario "But it shouldn't show numbers of hotfixes that don't effect your marketplace" do
            as_att_admin do
                visit releases_path
                page.find('.icon-hotfix')[:title].should_not have_content @hotfix2.number
            end
        end

        scenario "it shouldn't show the draft hotfix" do
            as_dt_admin do
                visit releases_path
                page.find('.icon-hotfix')[:title].should_not have_content @draft_hotfix.number
            end
        end
    end
end