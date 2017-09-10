class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.integer :season
      t.integer :week
      t.integer :type
      t.references :away, references: :lineup
      t.references :home, references: :lineup

      t.timestamps
    end
  end
end
