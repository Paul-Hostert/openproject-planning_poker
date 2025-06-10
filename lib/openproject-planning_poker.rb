# Zusatz für bessere Namespace Kompatibilität
if defined?(::OpenProject) && !defined?(::Openproject)
  ::Openproject = ::OpenProject
end

require 'openproject/planning_poker'
