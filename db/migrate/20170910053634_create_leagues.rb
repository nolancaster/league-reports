class CreateLeagues < ActiveRecord::Migration[5.1]
  def change
    create_table :leagues do |t|
      t.string :name
      t.string :url
      t.integer :founded

      t.timestamps
    end
  end
end
