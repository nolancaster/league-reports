class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.references :league, foreign_key: true
      t.references :owner, foreign_key: true

      t.timestamps
    end
  end
end
