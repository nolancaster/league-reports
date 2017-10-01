class CreateMatchups < ActiveRecord::Migration[5.1]
  def change
    create_table :matchups do |t|
      t.integer :season
      t.integer :week
      t.integer :type
      t.references :away, references: :lineup
      t.references :home, references: :lineup

      t.timestamps
    end
  end
end
