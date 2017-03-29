require 'resque-retry'
require 'resque-retry/server'

DocCenter::Application.routes.draw do
  mount Rich::Engine => '/rich', :as => 'rich'

  mount Resque::Server, :at => "/admin/resque", constraints: lambda {
   |request|
    request.env['warden'].authenticate!.has_role? :superadmin
  }

  ActiveAdmin.routes(self)

  resources :pages, :features
  resources :releases do
      get 'search', :on => :collection
  end

  match 'print/all/manuals'           => 'pages#print_all'
  match 'print/*path'                => 'pages#print'
  #match 'roadmap/*path'              => 'pages#show_roadmap',        :as => :roadmap

  root :to => "home#index"
  match 'search'                  => 'search#index',               :as => :search
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :sessions => "dc_sessions" }, :path => '', :path_names => { :sign_in => "login", :sign_out => "logout", :sign_up => "register" }
  devise_scope :user do
    match '/login_proxy'            => 'dc_sessions#login_proxy', :as => :login_proxy
  end

  match 'sort_pages'                 => 'pages#sort',                :as => :sort_pages
  match 'sort_roadmaps'              => 'roadmaps#sort',             :as => :sort_roadmaps
  match 'redirect/login'             => 'redirect#login'


  namespace :api do
    namespace :v1 do
      match 'partners'               => 'partners#index'
      post  'partners/new'           => 'partners#new'
      put   'partners/update'        => 'partners#update'
      post  'partners/add_url'       => 'partners#add_to_existing'
      get   'search'                 => 'annotations#search', :defaults => { :format => :json }
      get   'annotations/resolve/:id'=> 'annotations#resolve', :defaults => { :format => :js }, :as => :annotation_resolve
      get   'annotations/user'       => 'annotations#user', :defaults => { :format => :json }
      resources :annotations, :defaults => { :format => :json }

    end
  end


  #TODO: figure out how to not declare these directly.
  post 'admin/pages/:id/rollback'    => 'admin/pages#rollback',      :as => :page_rollback
  post 'admin/releases/:id/rollback' => 'admin/releases#rollback',   :as => :release_rollback
  post 'admin/features/:id/rollback' => 'admin/features#rollback',   :as => :feature_rollback
  post 'admin/passages/:id/rollback' => 'admin/passages#rollback',   :as => :passage_rollback

  put 'autosave'                     => 'autosave#autosave',         :as => :autosave

  get 'updates'                      => 'updates#index'
  post '/dismiss_update_notice'      => 'updates#hide_update'


  post 'recent_changes'              => 'home#changes'
  post '/impersonate/:id'            => 'users/impersonation#impersonate'
  post '/unimpersonate'              => 'users/impersonation#unimpersonate'
  match '/users/iframesettings'            => 'users/settings#edit', :as => :user_iframesettings
  match 'users/settings'             => 'users/settings#settings', :as => :user_settings
  post '/users/update'               => 'users/settings#update', :as => :user_settings_update

  match 'users/test/:to'             => 'users/settings#test', :as => :test_email

  match '/magickly', :to => Magickly::App, :anchor => false
  match '/mark_as_read', :to => 'application#mark_as_read'
  get '/toggle_superadmin_only_mode', :to => 'application#toggle_superadmin_only_mode', constraints: lambda { |request|
    request.env['warden'].authenticate!.has_role? :superadmin
  }
  get '/admin/autocomplete_tags',
    to: 'admin/tags#autocomplete_tags',
    as: 'autocomplete_tags'

  match 'faqs'                       => 'faqs#index',                :as => :faqs
  match 'faqs/:tag'                  => 'faqs#show',                 :as => :faq_tag
  match 'faqs/show/:id'              => 'faqs#show_individual',      :as => :faq

  match 'fm/:fm_id'                  => 'public_pages#framemaker_redirect',  :as => :fm_redirect
  # don't put anything below these
  match '/roadmaps'       => 'roadmaps#index', :as => :roadmaps
  match '/roadmaps/*path' => 'roadmaps#show', :as => :roadmap

  #set up redirects for old /guides paths in case we have bookmarks
  match '/guides/*article'          => redirect('/manuals/%{article}')
  match '/guides/'                  => redirect('/manuals/')

  #set up redirects for marketplace/documentation/ articles
  match '/marketplace/documentation/invite-your-team' => redirect('/marketplace/getting-started/invite-your-team')
  match '/marketplace/documentation/invite-your-team/*path' => redirect('/marketplace/getting-started/invite-your-team/%{path}')
  match '/marketplace/documentation/configure-general-settings' => redirect('/marketplace/getting-started/configure-general-settings')
  match '/marketplace/documentation/configure-general-settings/*path' => redirect('/marketplace/getting-started/configure-general-settings/%{path}')
  match '/marketplace/documentation/configure-billing-settings' => redirect('/marketplace/getting-started/configure-billing-settings')
  match '/marketplace/documentation/configure-billing-settings/*path' => redirect('/marketplace/getting-started/configure-billing-settings/%{path}')
  match '/marketplace/documentation/configure-marketplace-functionality' => redirect('/marketplace/getting-started/configure-marketplace-functionality')
  match '/marketplace/documentation/configure-marketplace-functionality/*path' => redirect('/marketplace/getting-started/configure-marketplace-functionality/%{path}')
  match '/marketplace/documentation/customize-marketplace-ui' => redirect('/marketplace/getting-started/customize-marketplace-ui')
  match '/marketplace/documentation/customize-marketplace-ui/*path' => redirect('/marketplace/getting-started/customize-marketplace-ui/%{path}')
  match '/marketplace/documentation/merchandise-products' => redirect('/marketplace/getting-started/merchandise-products')
  match '/marketplace/documentation/merchandise-products/*path' => redirect('/marketplace/getting-started/merchandise-products/%{path}')
  match '/marketplace/documentation/sell-third-party-products' => redirect('/marketplace/getting-started/sell-third-party-products')
  match '/marketplace/documentation/sell-third-party-products/*path' => redirect('/marketplace/getting-started/sell-third-party-products/%{path}')
  match '/marketplace/documentation/sell-your-own-products' => redirect('/marketplace/getting-started/sell-your-own-products')
  match '/marketplace/documentation/sell-your-own-products/*path' => redirect('/marketplace/getting-started/sell-your-own-products/%{path}')
  match '/marketplace/documentation/manage-your-sales' => redirect('/marketplace/getting-started/manage-your-sales')
  match '/marketplace/documentation/manage-your-sales/*path' => redirect('/marketplace/getting-started/manage-your-sales/%{path}')
  match '/marketplace/documentation/additional-topics' => redirect('/marketplace/getting-started/additional-topics')
  match '/marketplace/documentation/additional-topics/*path' => redirect('/marketplace/getting-started/additional-topics/%{path}')
  
  match '/help-support/'          => 'supports#index', :as => "supports" # supports_path = /supports supports_url
  match '/help-support/*permalink' => "supports#show", :as => "support"

  match '/manuals'                 => 'pages#index', :as => :manuals
  match '/manuals/*path'           => 'pages#show', :as => :manual

  match '/isv-info'                => 'isv#index', :as => :isvinfos
  match '/isv-info/*path'          => 'isv#show', :as => :isvinfo
  #redirect for /billing to new /developer/billing
  match '/billing'                 => redirect('/developer/billing')
  match '/distribution'            => redirect('/developer/distribution')

  # ABSOLUTELY NOTHING BELOW THIS
  match '/help'                    => 'public_pages#index', :as => :help_center
  match '/*path'                   => 'public_pages#show', :as => :api

end
