Rails.application.routes.draw do
  scope 'projects/:project_id' do
    resources :planning_poker, only: [:index] do
      collection do
        post :start_session
        post :join_session
        get :vote
        post :vote
        post :next_story
        get :show_results
        post :save_story_points
        post :restart_session
      end
    end
  end
end
