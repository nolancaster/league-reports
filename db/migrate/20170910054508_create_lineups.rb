class CreateLineups < ActiveRecord::Migration[5.1]
  def change
    create_table :lineups do |t|
      t.float :score
      t.integer :result
      t.string :team_name
      t.references :team, foreign_key: true
      t.references :owner, foreign_key: true

      t.timestamps
    end
  end
end
