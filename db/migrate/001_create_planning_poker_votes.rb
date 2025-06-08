class CreatePlanningPokerVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :planning_poker_votes do |t|
      t.references :project, null: false, foreign_key: true
      t.references :work_package, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :session_id, null: false
      t.string :value, null: false
      t.timestamps
    end
    
    add_index :planning_poker_votes, [:session_id, :work_package_id, :user_id], 
              unique: true, 
              name: 'index_poker_votes_on_session_work_package_user'
  end
end
