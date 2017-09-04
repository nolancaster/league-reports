class Scraper
  def call
    url = 'http://games.espn.com/ffl/'
    league_id = 306883

    agent = Mechanize.new
    page = agent.get("#{url}clubhouse?leagueId=#{league_id}")
    scoreboard = page.links.find { |l| l.text == 'Scoreboard' }
    page = scoreboard.click

    while page
      season_id = /seasonId: (\d+)/.match(page.content)[1].to_i
      scoring_period_id = /scoringPeriodId: (\d+)/.match(page.content)[1].to_i
      scrape_week(page)

      scoring_period_id -= 1
      if scoring_period_id  < 1
        scoring_period_id = 17
        season_id -= 1

        break if season_id < 2016
      end

      page = agent.get(
        "#{url}scoreboard?leagueId=#{league_id}&seasonId=#{season_id}&matchupPeriodId=#{scoring_period_id}")
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
