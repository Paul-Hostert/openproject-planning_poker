class PlanningPokerVote < ApplicationRecord
  belongs_to :project
  belongs_to :work_package
  belongs_to :user
  
  validates :session_id, presence: true
  validates :value, presence: true
  validates :user_id, uniqueness: { scope: [:session_id, :work_package_id] }
end
