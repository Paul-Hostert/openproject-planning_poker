class PlanningPokerSession < ApplicationRecord
  belongs_to :project
  
  validates :session_id, presence: true, uniqueness: true
  
  scope :active, -> { where(active: true) }
  
  # Serialisiere story_ids als Array
  serialize :story_ids
  
  def self.current_for_project(project)
    active.where(project: project).order(created_at: :desc).first
  end
end
