class Scraper
  @@url = 'http://games.espn.com/ffl/'
  @@league_office = 'leagueoffice?leagueId='

  def call(league_id)
    agent = Mechanize.new
    page = agent.get("#{@@url}#{@@league_office}#{league_id}")
    league_name = page.at('#lo-league-header h1').text
    founded = page.search('#seasonHistoryMenu option').last['value'].to_i

    league = League.create(league_id: league_id, name: league_name, founded: founded)

    scoreboard = page.links.find { |l| l.text == 'Scoreboard' }
    page = scoreboard.click
    scoreboard_url = page.uri.to_s.remove(page.uri.query)

    while page
      season_id = /seasonId: (\d+)/.match(page.content)[1].to_i
      scoring_period_id = /scoringPeriodId: (\d+)/.match(page.content)[1].to_i
      scrape_week(page)

      scoring_period_id -= 1
      if scoring_period_id  < 1
        scoring_period_id = 17
        season_id -= 1

        break if season_id < founded
      end

      page = agent.get(scoreboard_url + URI.encode_www_form(
        leagueId: league_id, seasonId: season_id, matchupPeriodId: scoring_period_id))
    end
  end

  def scrape_week(page)
    return unless !page.search('.winning').empty?
    puts page.title
    matchups = page.search('table.matchup')
    matchups.each do |matchup|
      teams = matchup.search('tr')
      info = []
      2.times do |i|
        team_info = {}
        team_node = teams[i]
        team_info[:name] = team_node.at('td.team .name a').text
        score_node = team_node.at('td.score')
        team_info[:score] = score_node.text
        team_info[:winner] = score_node.attr('class').include?('winning')
        info[i] = team_info
      end
      puts info.inspect
    end
  end

  # private

  # def team_id(found)
  #   mapping = {
  #     8 => 13
  #   }

  #   mapping[found] || found
  # end
end
