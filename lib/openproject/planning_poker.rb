module OpenProject
  module PlanningPoker
    # Version des Plugins
    VERSION = '0.0.1'
    
    # Lade die Engine
    require_relative 'planning_poker/engine'
    
    # Weitere Module können hier geladen werden
    # require_relative 'planning_poker/hooks'
    # require_relative 'planning_poker/patches'
  end
end
