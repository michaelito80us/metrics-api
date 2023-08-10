Rails.application.routes.draw do
  defaults format: :json do
    namespace :api do
      namespace :v1 do
        resources :metrics, only: [:create]
        get '/allmetrics', to: 'metrics#metric_list'
        get '/metric_entries/:name', to: 'metrics#metric_entries'
      end
    end

    match '*unmatched', to: 'application#route404', via: :all
  end
end
