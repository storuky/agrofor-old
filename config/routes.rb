# require "resque_web"

Rails.application.routes.draw do

  # resque_web_constraint = lambda { |request| request.remote_ip == '127.0.0.1' }
  # constraints resque_web_constraint do
  #   mount ResqueWeb::Engine => "/resque_web"
  # end

  get "markers" => "application#markers"
  scope :search do
    get "all" => "search#all"
    post "by_params" => "search#by_params"
    post "suitable" => "search#suitable"
  end

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }
  root "application#index"


  scope :ajax do
    scope :reputations do
      post '/' => "reputations#create"
    end

    scope :settings do
      get "/" => "settings#index"
      post "/" => "settings#update"
    end

    scope :help do
      get "/" => "help#index"
    end

    scope :profile do
      get "/" => "profile#index"
      put "/edit" => "profile#edit"
      post "/avatar" => "profile#avatar"

      get "/:id" => "profile#show"
    end

    scope :correspondences do
      get "/" => "correspondences#index"
      get "with" => "correspondences#with"
      get "connection_id" => "correspondences#connection_id"
      get "find_correspondence" => "correspondences#find_correspondence"
      get "messages_page" => "correspondences#messages_page"
      get "reset_count" => "correspondences#reset_count"
      post "start" => "correspondences#start"
      post "new_message" => "correspondences#new_message"
      post "upload" => "correspondences#upload"
      delete "file" => "correspondences#delete_file"

      get "/:id" => "correspondences#show"
    end

    resource :offers
    delete "offers/reset_counter" => "offers#reset_counter"

    resources :positions do
      collection do
        get "form" => "positions#form"
        get "show" => "positions#show"
        get "toggle_favorite" => "positions#toggle_favorite"
        get "template" => "positions#template"
        get "deal_complete" => "positions#deal_complete"
        delete "delete_photo" => "positions#delete_photo"
        delete "templates" => "positions#delete_template"
        
        put "archive" => "positions#archive"
        put "restore" => "positions#restore"

        put "agree" => "positions#agree"
        put "complete" => "positions#complete"
        delete "withdraw" => "positions#withdraw"
        delete "reject" => "positions#reject"
      end
    end
    
    scope :search do
      get "/" => "search#index"
      get "map" => "search#map"
      get "list" => "search#list"
    end

    scope :categories do
      get "init_category" => "categories#init_category" 
    end
  end

  match "websocket", :to => WebsocketRails::ConnectionManager.new, via: [:get, :post]
  get "/*path" => "application#index"
end

