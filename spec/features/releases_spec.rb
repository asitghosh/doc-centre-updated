require 'spec_helper'
include ActionController::Caching::Fragments

feature "Releases" do
  background do
    init_channel_partners
    Capybara.app_host = "http://#{@appdirect.subdomain}.docs.lvh.me"
    @past = FactoryGirl.create(:release, :published, :past)
    @present = FactoryGirl.create(:release, :published, :present)
    @future = FactoryGirl.create(:release, :published, :future)
    @empty = FactoryGirl.create(:release, :empty, :present, :published)
    @partially_empty = FactoryGirl.create(:release, :partially_empty, :present, :published)
    @draft = FactoryGirl.create(:release, :draft, :future)
    @assigned_feature = FactoryGirl.create(:feature, :published, :release_id => @present.id)
    @marketplace_improvement_passage = @present.passages.create(FactoryGirl.attributes_for(:passage, :type_name => "marketplace_improvements"))
    @api_improvement_passage = @present.passages.create({:type_name => "api_improvements", :content => "api improvement passage"})
    @dev_center_improvements_passage = @present.passages.create(FactoryGirl.attributes_for(:passage, :type_name => "devcenter_improvements", :content => "devcenter improvement passage"))
    @manager_improvements_passage = @present.passages.create(FactoryGirl.attributes_for(:passage, :type_name => "manager_improvements"))
    @corporate_portal_passage = @present.passages.create(FactoryGirl.attributes_for(:passage, :type_name => "corporate_portal"))

    @appdirect_specific = @present.channel_specific_contents.create(:channel_partner_ids => [@appdirect.id], :content => "this is some content for AppDirect Specifically", :whitelist => nil)
    @partner_specific = @present.channel_specific_contents.create(:channel_partner_ids => [@dt.id], :content => "this is some content for Partner Channel", :whitelist => true)
    @both_specific = @present.channel_specific_contents.create(:channel_partner_ids => [@appdirect.id,@dt.id], :content => "this is some content for both", :whitelist => true)
    @blacklist_content = @present.channel_specific_contents.create(:channel_partner_ids => [@dt.id], :content => "this is a blacklisted specific content", :whitelist => false )

    @hotfix = @present.hotfixes.create( :number => "#{@present.title}.1", :content => "This is hotfix content", :pub_status => "published" )
    @hotfix2 = @present.hotfixes.create( :number => "#{@present.title}.2", :content => "This is some AppDirect content", :channel_partner_ids => [@appdirect.id], :pub_status => "published" )
    @hotfix_channel_specific_content = @hotfix.channel_specific_contents.create( :channel_partner_ids => [@appdirect.id], :content => "this is some content in hotfix1 for AppDirect Only")

  end
  describe "Index" do

    context "access permissions" do

      scenario "as a non-logged in user" do
          visit releases_path
          # page.save_screenshot(Rails.root.join('tmp', 'screen.png'))
          page.should have_content(/Sign in with/i)
      end

      scenario "as a visitor (non channel admin)" do
        as_visitor do
          visit releases_path
          page.should have_content("Access Denied")
        end
      end

      scenario "as a channel admin" do
        as_dt_admin do
          visit releases_path
          page.should have_content("Release Notes")
        end
      end

    end

    context "release display order", :js => true do
      pending "as a channel admin" do
        as_dt_admin do
          visit releases_path
          order = page.all('.rbox .h1').collect { |r| r.text }
          order.should eq ["#{@future.title}", "#{@present.title}", "#{@partially_empty.title}", "#{@empty.title}","#{@past.title}"]
        end
      end

    end

    context "release display permissions", :js => true do

      scenario "as a channel_admin" do
        as_dt_admin do
          visit releases_path
          page.should_not have_selector(".draft")
        end
      end

      scenario "as an appdirect employee" do
        as_superadmin do
          visit releases_path
          #page.save_screenshot(Rails.root.join('tmp', 'screen4.png'))
          page.should have_selector(".draft")
        end
      end

    end

  end ## describe index


  describe "Show" do

    context "access permissions" do

      scenario "as a user (non channel admin)" do
        as_visitor do
          visit release_path(@present)
          page.should have_content('403')
        end
      end

      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content(@present.title)
        end
      end

    end


    context "sidebar links for channel partners" do

      scenario "as a channel_admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should_not have_content(@appdirect_specific.content)
        end
      end

    end

    context "channel partner specific details" do

      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content(@partner_specific.content)
        end
      end

    end


    context "channel specific blacklisted details" do

      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should_not have_content(@blacklist_content.content)
        end
      end

      scenario "as channel admin from another partner" do
        as_att_admin do
          visit release_path(@present)
          page.should have_content(@blacklist_content.content)
        end
      end

    end

    context "marketplace improvement passages" do
      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content @marketplace_improvement_passage.content
        end
      end
    end

    context "api improvements passages" do
      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content @api_improvement_passage.content
        end
      end
    end

    context "dev center improvements passages" do
      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content @dev_center_improvements_passage.content
        end
      end
    end

    context "manager_improvements passages" do
      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content @manager_improvements_passage.content
        end
      end
    end

    context "corporate_portal passages" do
      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content @corporate_portal_passage.content
        end
      end
    end

    context "features assigned to releases" do

      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content(@assigned_feature.summary)
        end
      end

    end

    context "hotfixes assigned to releases" do

      scenario "as a channel admin" do
        as_dt_admin do
          visit release_path(@present)
          page.should have_content @hotfix.number
        end
      end

      scenario "as a channel admin, AppDirect specific hotfix should not show up" do
        as_dt_admin do
          visit release_path(@present)
          page.should_not have_content @hotfix2.number
        end
      end

      scenario "as a channel admin, channel specific content not assigned to me should not show up" do
        as_dt_admin do
          visit release_path(@present)
          page.should_not have_content @hotfix_channel_specific_content.content
        end
      end

    end

    context "release note without relevant content" do

      scenario "as a channel admin I should see an empty release" do
        as_dt_admin do
          visit releases_path
          page.should have_css("div.release.empty_release", count: 1)
        end
      end
      scenario "as a superadmin I should see all releases" do
        as_superadmin do
          visit releases_path
          page.should_not have_css("div.release.empty_release")
        end
      end
    end

    context "[with caching]" do
      let(:flexbox) { find(:linkhref, release_path(@present)) }
      let(:empty_release) { FactoryGirl.create(:release, :empty, :present, :published) }
      let(:new_draft) { FactoryGirl.create(:release, :draft, :future, title: "draft") }
      let(:new_release) { FactoryGirl.create(:release, :published, :present, title: "new release") }

      after :each do
        Rails.cache.clear
      end

      context "in grid view" do

        scenario "the page loads", caching: true do
          as_dt_admin do
            visit releases_path
            flexbox.should have_content("UNREAD")
          end
        end

        scenario "unread badges aren't cached", caching: true do
          as_dt_admin do
            visit releases_path
            new_release.mark_as_read!(for: User.first)
            visit releases_path
            flexbox = find(:linkhref, release_path(new_release))
            flexbox.text.should_not include("UNREAD")
          end
        end

        scenario "unread badges are hidden if there's no content", caching: true do
          as_dt_admin do
            Release.delete_all
            empty_release
            visit releases_path
            visit releases_path
            page.should_not have_content("UNREAD")
          end
        end

        pending "cache is written", caching: true do
          #TODO Refactor because we're now using cache_digests
          #     and I don't know how to manually create that and add it to the cache key
          as_dt_admin do
            release = @present
            visit releases_path
            flexbox_cache = Rails.cache.read(fragment_cache_key(["flexbox", User.first.channel_partner.id, release]))
            expect(flexbox_cache).to include("<h3 class='h1'>#{release.title}</h3>")
          end
        end

        scenario "previously cached content is used", caching: true do
          as_dt_admin do
            visit releases_path
            Release.any_instance.should_not_receive(:summary)
            visit releases_path
          end
        end

        scenario "content for one user isn't seen by another", caching: true do
          as_superadmin do
            new_draft
            visit releases_path
          end
          as_dt_admin do
            visit releases_path
            page.should_not have_content new_draft.title
          end
        end

        scenario "new content expires the cache", caching: true do
          as_dt_admin do
            visit releases_path
            new_release
            visit releases_path
            page.should have_content new_release.title
          end
        end

        scenario "updated content expires the cache", caching: true do
          as_dt_admin do
            new_release
            visit releases_path
            new_release.update_attributes(title: "updated release")
            visit releases_path
            page.should_not have_content("new release")
          end
        end
      end

      context "in list view" do

        scenario "unread badges are hidden if there's no content", caching: true do
          as_dt_admin do
            Release.delete_all
            empty_release
            visit releases_path
            click_link("list_view")
            visit releases_path
            page.should_not have_content("UNREAD")
          end
        end

        scenario "unread badges aren't cached", caching: true do
          as_dt_admin do
            Release.delete_all
            new_release
            visit releases_path                         #Loads default grid view
            click_link("list_view")         #caches list view
            new_release.mark_as_read!(for: User.first)
            visit releases_path                         #views cached list view
            page.should_not have_text("UNREAD")
          end
        end

        scenario "content for one user isn't seen by another", caching: true do
          as_superadmin do
            new_draft
            visit releases_path
            click_link("list_view")
          end
          as_dt_admin do
            visit releases_path
            click_link("list_view")
            page.should_not have_content new_draft.title
          end
        end
      end

    end


  end ## descibe show
end
