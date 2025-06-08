module OpenProject
  module PlanningPoker
    class Engine < ::Rails::Engine
      engine_name :openproject_planning_poker
      include OpenProject::Plugins::ActsAsOpEngine
      
      register 'openproject-planning_poker',
               author_url: 'https://github.com/Paul-Hostert',
               requires_openproject: '>= 13.0.0'
    end
  end
end
