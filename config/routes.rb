Rails.application.routes.draw do
  
  # Session Routes
  post "/login/", to: "sessions#create"
  post "/refresh/", to: "sessions#refresh"
  delete "/logout/", to: "sessions#destroy"

  # User Routes
  get "/user/", to: "users#show"
  post "/register/", to: "users#create"
  delete "/delete/", to: "users#destroy"
  patch "/edit/", to: "users#update"

  # Subreddit Routes
  root "subreddits#index"
  get "/subreddits/", to: "subreddits#show"
  post "/subreddits/new/", to: "subreddits#create"
  patch "/subreddits/edit/", to: "subreddits#update"
  delete "/subreddits/delete/", to: "subreddits#destroy"

  # Comment Routes
  get "/comments/", to: "comments#index"
  get "/comment/", to: "comments#show"
  post "/comments/new/", to: "comments#create"
  patch "/comments/edit/", to: "comments#update"
  delete "/comments/delete/", to: "comments#destroy"
  
end
