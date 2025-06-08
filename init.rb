Rails.logger.info "[PlanningPoker] Loading plugin..."

Redmine::Plugin.register :openproject_planning_poker do
  name 'OpenProject Planning Poker'
  author 'Paul Hostert'
  version '0.0.1'
  description 'Adds Planning Poker to OpenProject'
  
  requires_openproject '>= 13.0.0'
  
  # Als Projekt-Modul registrieren mit korrekten Permissions
  project_module :planning_poker do
    permission :view_planning_poker, 
               { planning_poker: [:index, :vote, :show_results] },
               public: true,
               require: :loggedin

    permission :manage_planning_poker,
               {planning_poker: [:start_session, :join_session, :save_story_points, :restart_session] },
               require: :member
  end
  
  # Menü-Eintrag
  menu :project_menu,
       :planning_poker,
       { controller: 'planning_poker', action: 'index' },
       caption: 'Planning Poker',
       after: :work_packages,
       icon: 'icon-star',
       if: ->(project) { project.module_enabled?('planning_poker') }
end
