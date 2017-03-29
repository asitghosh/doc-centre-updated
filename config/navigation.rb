# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  # navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  # navigation.selected_class = 'your_selected_class'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  # navigation.active_leaf_class = 'your_active_leaf_class'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  # navigation.autogenerate_item_ids = false

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  # navigation.name_generator = Proc.new {|name| "<span>#{name}</span>"}

  # The auto highlight feature is turned on by default.
  # This turns it off globally (for the whole plugin)
  # navigation.auto_highlight = false

  # Define the primary navigation
  navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>:if => Proc.new { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>:unless => Proc.new { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.  You may also use a proc, or the symbol <tt>:subpath</tt>.
    #

      primary.item :appdirect, "Home", root_path

      # primary.item :billing_manual, "Developer", "/developer",
      #               :highlights_on => /developer?/,
      #               :unless => Proc.new { current_user }
      primary.item :guides, "User Guides", "#",
                   :html => {
                    :class => "subnav "
                   },
                   :unless => Proc.new { current_user },
                   :highlights_on => /(marketplace?\b|billing?\b)\/?/ do |subnav|

        subnav.item :marketplace_manual, "Marketplace", "/marketplace",
                    :highlights_on => /marketplace?/,
                    :unless => Proc.new { current_user }

        subnav.item :billing_manual, "Developer", "/developer",
                    :highlights_on => /developer?/,
                    :unless => Proc.new { current_user }

        # subnav.item :marketplace_manual, "Marketplace Manager", "/marketplace-manager",
        #             :highlights_on => /marketplace-manager?/,
        #             :unless => Proc.new { current_user } 
      end

      # primary.item :distribution, "Distribution", "/distribution",
      #              :unless => Proc.new { current_user }

      # WE NOW RESUME THE LOGGED IN MENU
      primary.item :guides, 'User Guides', '#',
                   :html => {
                      :class => "subnav #{'disabled' unless current_user && current_user.channel_partner.able_to_see_guides?}"
                    },
                   :if => Proc.new { current_user },
                   :highlights_on => /(faqs?\b|manuals?\b)\/?/ do |subnav|

        # subnav.item :user_guide, "User Guide", "#",
        #             :highlights_on => /asdasd/

        subnav.item :marketplace_manual, "Marketplace", "/marketplace",
                    :highlights_on => /marketplace?/,
                    :if => Proc.new { current_user }

        # subnav.item :marketplace_manual, "Marketplace Manager", "/marketplace-manager",
        #             :highlights_on => /marketplace-manager?/,
        #             :if => Proc.new { current_user } 

        subnav.item :billing_manual, "Developer", "/developer",
                    :highlights_on => /developer?/,
                    :if => Proc.new { current_user }


        subnav.item :user_manual, "Manuals", "/manuals/",
                    :highlights_on => /manuals?/,
                    :html => {
                      :class => "#{'disabled' unless current_user && current_user.channel_partner.able_to_see_user_guides?}"
                    },
                    :if => Proc.new { current_user }
        subnav.item :isv_info, "ISV App Info", "/isv-info",
                    :highlights_on => /isv-info?/,
                    :html => {
                      :class => "#{'disabled' unless current_user && current_user.channel_partner.able_to_see_isv?}"
                    },
                    :if => Proc.new { current_user }

        # subnav.item :supports, 'Support Guides', "/support-guides/", :highlights_on => /supports?/, :class => "#{'disabled' unless current_user.channel_partner.able_to_see_supports?}"
                    #:if => Proc.new { current_user }

        subnav.item :faq, 'FAQs', faqs_path,
                    :html => {
                      :class => "#{'disabled' unless current_user && current_user.channel_partner.able_to_see_faqs?}"
                    },
                    :if => Proc.new { current_user }
      end
      primary.item :product_changes, 'Product Changes', "#",
                   :html => {
                    :class => "subnav #{'disabled' unless current_user && current_user.channel_partner.able_to_see_product_changes?}"
                   },
                   :if => Proc.new { current_user },
                   :highlights_on => /(release(s)?|\/feature(s)?)/ do |subnav|
        subnav.item :releases, 'Release Notes', releases_path,
                    :highlights_on => /releases?/,
                    :html => { 
                      :class => "#{'disabled' unless current_user && current_user.channel_partner.able_to_see_releases?}"
                    },
                    :if => Proc.new { current_user }
        subnav.item :roadmap, 'Roadmap', '/roadmaps',
                    :highlights_on => /roadmaps/,
                    :html => {
                      :class => "#{'disabled' unless current_user && current_user && current_user.channel_partner.able_to_see_roadmaps?}"
                    },
                    :if => Proc.new { current_user }
    end
  end
end
      #subnav.item :features, 'Upcoming Features', features_path, :highlights_on => /features?/
