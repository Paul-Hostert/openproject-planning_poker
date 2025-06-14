module OpenProject
  module PlanningPoker
    class Engine < ::Rails::Engine
      engine_name :openproject_planning_poker
      include OpenProject::Plugins::ActsAsOpEngine
      
      register 'openproject-planning_poker',
               author_url: 'https://github.com/Paul-Hostert',
               requires_openproject: '>= 13.0.0' do
        
        project_module :planning_poker do
          permission :view_planning_poker,
                     { planning_poker: [:index, :vote, :show_results, :join_session] },
                     permissible_on: :project,
                     require: :member
                     
          permission :manage_planning_poker,
                     { planning_poker: [:start_session, :next_story, :save_story_points, :restart_session] },
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
