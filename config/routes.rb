Rails.application.routes.draw do
  scope :module => :blog_service do
    resources :blogs do
      collection do 
        get :count
        get :published
      end
      member do
        put :publish
        put :discard_draft
      end
    end

    match "/posts/published/count(.:format)" => "posts#published_count"
  end
end
