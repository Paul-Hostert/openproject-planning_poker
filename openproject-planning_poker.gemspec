Gem::Specification.new do |spec|
  spec.name          = "openproject-planning_poker"
  spec.version       = "1.0.0"
  spec.authors       = ["Paul Hostert"]
  spec.email         = ["paul.hostert@students.hs-mainz.de"]
  spec.summary       = "Planning Poker Plugin für OpenProject"
  spec.description   = "Erweitert OpenProject um Planning Poker"
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
  
end
