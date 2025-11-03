Rails.application.routes.draw do
  resources :courses
  resources :fields
  resources :students
  resources :groups
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'course/:id/group/:group_id', to: 'courses#grade', as: 'grade_course'
  get 'course/:id/group/:group_id/grade', to: 'courses#grade_set', as: 'grade_set'
  post 'course/:id/group/:group_id/save', to: 'courses#grade_save', as: 'grade_save'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
