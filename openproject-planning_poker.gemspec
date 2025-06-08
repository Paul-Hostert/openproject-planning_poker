# plugins/openproject-planning_poker/openproject-planning_poker.gemspec
Gem::Specification.new do |spec|
  spec.name          = "openproject-planning_poker"
  spec.version       = "0.0.1"
  spec.authors       = ["Paul Hostert"]
  spec.email         = ["your.email@example.com"]
  spec.summary       = "Planning Poker Plugin for OpenProject"
  spec.description   = "Adds Planning Poker functionality to OpenProject"
  spec.license       = "GPL-3.0"
  
  spec.files = Dir[
    "app/**/*",
    "config/**/*", 
    "db/**/*",
    "lib/**/*",
    "frontend/**/*",
    "init.rb",
    "README.md"  
  ].select { |f| File.file?(f) }
  
  # Keine expliziten Abhängigkeiten definieren
  # Das Plugin nutzt die Dependencies von OpenProject
end
