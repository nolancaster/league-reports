class CreateOwners < ActiveRecord::Migration[5.1]
  def change
    create_table :owners do |t|
      t.string :first_name
      t.string :last_name
      t.references :league, foreign_key: true

      t.timestamps
    end
  end
end
