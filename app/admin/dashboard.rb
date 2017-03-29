ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
  # div :class => "blank_slate_container", :id => "dashboard_default_message" do
  #   span :class => "blank_slate" do
  #     span I18n.t("active_admin.dashboard_welcome.welcome")
  #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
  #   end
  # end

  # Here is an example of a simple dashboard with columns and panels.
  #
  if current_user.has_role? :superadmin
    columns do
      column do
        panel "Lock the Documentation Center" do
          h6 :class => "red" do
            "Pressing this button will prevent anyone but AppDirect employees from accessing the Documentation Center
            and should only be used in situations where sensitive data is believed to have been leaked due to a bug. Please email webadmin@appdirect.com immediately and let us know of the issue."

          end
          span mail_to "webadmin@appdirect.com", "webadmin@appdirect.com"
          br
          span link_to "#{AppSettings.find_by_key("superadmin_only_mode").value == 'true' ? 'Disable' : 'Initiate'} Lockdown Mode", "/toggle_superadmin_only_mode", :class => "button red", :data => { :confirm => "This will make the Doc Center #{AppSettings.find_by_key("superadmin_only_mode").value == 'true' ? 'accessible' : 'unaccessible'}. Are you sure?" }
        end
      end
    end
  end
  columns do
    column do
      panel "Recent Releases" do
        ul do
          Release.recent.limit(5).map do |release|
            li link_to("Release #{release.title}", admin_release_path(release))
          end
        end
      end
    end

    # column do
    #   panel "Recent Features" do
    #     ul do
    #       Feature.recent.limit(5).map do |feature|
    #         li link_to(feature.title, admin_feature_path(feature))
    #       end
    #     end
    #   end
    # end


  end # columns
  # columns do
  #   column do
  #     panel "Doc Center Updates" do
  #       ul do
  #         Update.published.limit(10).map do |update|
  #           li link_to "v#{update.title}, published #{update.release_date.to_s(:long_ordinal)}", updates_path(:anchor => "v#{update.title}")
  #         end
  #       end
  #     end
  #   end
  # end

  columns do
    column do
      panel "Problems?" do
        h6 raw "If you run into any problems, please let <a href='mailto:dan.hoerr@appdirect.com?subject=DocCenter Problem'>Dan</a> or <a href='mailto:alex.emslie@appdirect.com?subject=DocCenter Problem'>Alex</a> know</a>."
      end
    end
  end

  #   column do
  #     panel "Info" do
  #       para "Welcome to ActiveAdmin."
  #     end
  #   end
  # end
  end # content
end
