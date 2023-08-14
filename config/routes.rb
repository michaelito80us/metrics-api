Rails.application.routes.draw do
  root 'application#route404'
  defaults format: :json do
    namespace :api do
      namespace :v1 do
        resources :metrics, only: [:create]
        get '/metric_list', to: 'metrics#metric_list'
        post '/averages', to: 'metrics#metric_averages'
        post '/detailed_list', to: 'metrics#detailed_list'
      end
    end

    match '*unmatched', to: 'application#route404', via: :all
  end
end
