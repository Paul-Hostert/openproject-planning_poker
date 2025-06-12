module OpenProject
  module PlanningPoker
    class Engine < ::Rails::Engine
      engine_name :openproject_planning_poker
      include OpenProject::Plugins::ActsAsOpEngine
      
      register 'openproject-planning_poker',
               author_url: 'https://github.com/Paul-Hostert',
               requires_openproject: '>= 13.0.0' do
        
        project_module :planning_poker, name: 'Planning Poker' do
          permission :view_planning_poker,
                     { planning_poker: [:index, :vote, :show_results] },
                     permissible_on: :project,
                     public: true,
                     require: :loggedin
          permission :manage_planning_poker,
                     { planning_poker: [:start_session, :next_story, :join_session, :save_story_points, :restart_session] },
                     permissible_on: :project,
                     require: :member
        end
        
        menu :project_menu,
             :planning_poker,
             { controller: '/planning_poker', action: 'index' },
             caption: 'Planning Poker',
             after: :work_packages,
             icon: 'star'
      end
    end
  end
end
