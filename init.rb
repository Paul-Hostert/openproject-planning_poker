# Zusatz für bessere Namespace-Kompatibilität
if defined?(::OpenProject) && !defined?(::Openproject)
  ::Openproject = ::OpenProject
end

require File.expand_path('../lib/openproject-planning_poker.rb', __FILE__)

Redmine::Plugin.register :openproject_planning_poker do
  name 'OpenProject Planning Poker'
  author 'Paul Hostert'
  version '1.0.0'
  description 'Erweitert OpenProject um Planning Poker'
  url 'https://github.com/Paul-Hostert/openproject-planning_poker'
  requires_openproject '>= 13.0.0'
  
  menu :project_menu,
       :planning_poker,
       { controller: '/planning_poker', action: 'index' },
       caption: 'Planning Poker',
       after: :work_packages,
       icon: 'icon-star',
       param: :project_id,
       if: Proc.new { |p| p.module_enabled?('planning_poker') }
end
