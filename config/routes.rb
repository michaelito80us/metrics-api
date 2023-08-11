Rails.application.routes.draw do
  defaults format: :json do
    namespace :api do
      namespace :v1 do
        resources :metrics, only: [:create]
        get '/list', to: 'metrics#metric_list'
        post '/averages', to: 'metrics#metric_averages'
      end
    end

    match '*unmatched', to: 'application#route404', via: :all
  end
end
