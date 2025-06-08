class CreatePlanningPokerSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :planning_poker_sessions do |t|
      t.references :project, null: false, foreign_key: true
      t.string :session_id, null: false
      t.boolean :active, default: true
      t.timestamps
    end
    
    add_index :planning_poker_sessions, [:project_id, :active]
    add_index :planning_poker_sessions, :session_id, unique: true
  end
end
