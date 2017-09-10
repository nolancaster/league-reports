json.extract! lineup, :id, :score, :result, :team_name, :team_id, :owner_id, :created_at, :updated_at
json.url lineup_url(lineup, format: :json)
