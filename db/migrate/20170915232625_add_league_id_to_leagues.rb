class AddLeagueIdToLeagues < ActiveRecord::Migration[5.1]
  def change
    add_column :leagues, :league_id, :integer
  end
end
