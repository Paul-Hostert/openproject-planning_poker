# Zusatz für bessere Namespace-Kompatibilität
if defined?(::OpenProject) && !defined?(::Openproject)
  ::Openproject = ::OpenProject
end

Redmine::Plugin.register :openproject_planning_poker do
  name 'OpenProject Planning Poker'
  author 'Paul Hostert'
  version '1.0.0'
  description 'Erweitert OpenProject um Planning Poker'
  
  requires_openproject '>= 13.0.0'
  
  project_module :planning_poker do
    permission :view_planning_poker, 
               { planning_poker: [:index, :vote, :show_results] },
               public: true,
               require: :loggedin

    permission :manage_planning_poker,
               {planning_poker: [:start_session, :join_session, :save_story_points, :restart_session] },
               require: :member
  end
  
  menu :project_menu,
       :planning_poker,
       { controller: 'planning_poker', action: 'index' },
       caption: 'Planning Poker',
       after: :work_packages,
       icon: 'icon-star',
       if: ->(project) { project.module_enabled?('planning_poker') }
end

require File.expand_path('../lib/openproject-planning_poker.rb', __FILE__)
