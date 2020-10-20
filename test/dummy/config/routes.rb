Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  jwauth_routes

  get '/jwauth_test' => 'jwauth_test#index'
end
