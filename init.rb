# Zusatz für bessere Namespace-Kompatibilität
if defined?(::OpenProject) && !defined?(::Openproject)
  ::Openproject = ::OpenProject
end

require File.expand_path('../lib/openproject-planning_poker.rb', __FILE__)

# Standard Plugin-Registrierung
Redmine::Plugin.register :openproject_planning_poker do
  name 'OpenProject Planning Poker'
  author 'Paul Hostert'
  version '1.0.0'
  description 'Erweitert OpenProject um Planning Poker'
  url 'https://github.com/Paul-Hostert/openproject-planning_poker'
  requires_openproject '>= 13.0.0'
  
  # Menü hier registrieren (das funktioniert in der Plugin-Registrierung)
  menu :project_menu,
       :planning_poker,
       { controller: 'planning_poker', action: 'index' },
       caption: 'Planning Poker',
       after: :work_packages,
       icon: 'icon-star',
       if: Proc.new { |p| p.module_enabled?('planning_poker') }
end

# Modul-Registrierung - direkt ausführen, nicht in Hooks
begin
  if defined?(OpenProject::AccessControl)
    OpenProject::AccessControl.map do |map|
      map.project_module :planning_poker do |mod|
        mod.permission :view_planning_poker,
                       { planning_poker: [:index, :vote, :show_results, :show_stories] },
                       permissible_on: :project,
                       public: true,
                       require: :loggedin
                       
        mod.permission :manage_planning_poker,
                       { planning_poker: [:start_session, :next_story, :join_session, :save_story_points, :restart_session] },
                       permissible_on: :project,
                       require: :member
      end
    end
    Rails.logger.info "[PlanningPoker] Module registered directly"
  else
    Rails.logger.warn "[PlanningPoker] OpenProject::AccessControl not yet available"
  end
rescue => e
  Rails.logger.error "[PlanningPoker] Error registering module: #{e.message}"
  
  # Fallback: Versuche es später nochmal
  ActiveSupport.on_load(:after_initialize) do
    OpenProject::AccessControl.map do |map|
      map.project_module :planning_poker do |mod|
        mod.permission :view_planning_poker,
                       { planning_poker: [:index, :vote, :show_results, :show_stories] },
                       permissible_on: :project,
                       public: true,
                       require: :loggedin
                       
        mod.permission :manage_planning_poker,
                       { planning_poker: [:start_session, :next_story, :join_session, :save_story_points, :restart_session] },
                       permissible_on: :project,
                       require: :member
      end
    end
    Rails.logger.info "[PlanningPoker] Module registered in fallback"
  end
end
