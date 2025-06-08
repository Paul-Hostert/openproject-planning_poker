class AddStoryIdsToPlanningSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :planning_poker_sessions, :story_ids, :text
  end
end
