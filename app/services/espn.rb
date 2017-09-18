module ESPN
  class League
    Office  = Struct.new(:name, :founded, :current_season, :current_week)
    Team    = Struct.new(:id, :name, :owner)
    Matchup = Struct.new(:away, :home)
    Lineup  = Struct.new(:team_id, :team_name, :owner, :score, :result)

    attr_reader :id

    def initialize(id)
      @id = id
      @weeks = Hash.new { |h, k| h[k] = {} }
      @owners = Set.new
      @teams = {}
    end

    def office
      return @office if @office
      scraper = Scraper::Office.new(leagueId: @id)
      scraper.each_team do |team_scraper|
        team = Team.new(team_scraper.id, team_scraper.name, team_scraper.owner)
        @teams[team.id] = team
      end
      @office = Office.new(scraper.name, scraper.founded, scraper.season, scraper.week )
    end

    def owners
      weeks
      @owners
    end

    def teams
      office
      @teams.values
    end

    def team(id)
      office
      @teams[id]
    end

    def weeks
      (office.founded..office.current_season).each do |season|
        weeks_for(season)
      end
      @weeks
    end

    def weeks_for(season)
      #TODO validate season in range
      max_week = current_season?(season) ? office.current_week : 17

      (1..max_week).each do |week|
        week_of(season, week)
      end
      @weeks[season]
    end

    def week_of(season, week)
      return @weeks[season][week] if @weeks[season][week]

      @weeks[season][week] = matchups = []
      return matchups if current_week?(season, week)

      scraper = Scraper::Scoreboard.new(leagueId: @id, seasonId: season, matchupPeriodId: week)
      return matchups unless scraper.is?(season, week)

      scraper.each_matchup do |matchup_scraper|
        matchup = Matchup.new
        Matchup.members.each do |side|
          lineup = Lineup.new
          lineup.team_id = matchup_scraper.team_id(side)
          lineup.team_name = matchup_scraper.team_name(side)
          lineup.owner = matchup_scraper.owner(side)
          lineup.score = matchup_scraper.score(side)
          matchup.send("#{side}=", lineup)
          @owners << lineup.owner
        end
        determine_result(matchup.away, matchup.home)
        matchups << matchup
      end
      matchups
    end

    def current_season?(season)
      season == office.current_season
    end

    def current_week?(season, week)
      current_season?(season) && week == office.current_week
    end

    private

    def determine_result(away, home)
      if away.score == home.score
        away.result = home.result = :draw
      else
        [away, home].max_by(&:score).result = :win
        [away, home].min_by(&:score).result = :loss
      end
    end
  end

  module Scraper
    class Base
      include Scraper
      @@url = 'http://games.espn.com/'

      def initialize(params = {})
        @params = params
        @agent = Mechanize.new
        @page = @agent.get(url)
      end

      def self.url
        URI.join(@@url, self.base_path, self.path).to_s
      end

      def self.base_path
        'ffl/'
      end

      def self.path
        ''
      end

      def url
        uri = URI.parse(self.class.url)
        uri.query = URI.encode_www_form(@params) unless @params.empty?
        uri.to_s
      end

      def season
        /seasonId: (\d+)/.match(@page.content)[1].to_i
      end

      def week
        /scoringPeriodId: (\d+)/.match(@page.content)[1].to_i
      end
    end

    class Office < Base
      def self.path
        'leagueoffice'
      end

      def name
        @page.at('#lo-league-header h1').text
      end

      def founded
        @page.search('#seasonHistoryMenu option').last['value'].to_i
      end

      def each_team
        @page.at('h1:contains("Standings")').next.search("a").each do |team_link|
          yield(Scraper::Team.new(team_link))
        end
      end
    end

    class Scoreboard < Base
      def self.path
        'scoreboard'
      end

      def is?(season, week)
        self.season == season && self.week == week
      end

      def each_matchup
        @page.search('table.matchup').each do |matchup|
          yield(Scraper::Matchup.new(matchup))
        end
      end
    end

    class Partial
      include Scraper
      def initialize(element)
        @element = element
      end
    end

    class Matchup < Partial
      @@sides = [:away, :home]

      def team_id(side)
        id = /_(\d+)_/.match(team_row(side)['id'])[1].to_i
        translate_team_id(id)
      end

      def team_name(side)
        team_row(side).at('.name a').text
      end

      def owner(side)
        team_row(side).at('.owners').text
      end

      def score(side)
        team_row(side).at('td.score')['title'].to_f
      end

      private

      def index(side)
        @@sides.index(side)
      end

      def team_row(side)
        @element.search('tr')[index(side)]
      end
    end

    class Team < Partial
      def id
        id = /teamId=(\d+)/.match(@element['href'])[1].to_i
        translate_team_id(id)
      end

      def name
        match_title[1]
      end

      def owner
        match_title[2]
      end

      private

      def match_title
        /(.+) \((.+)\)/.match(@element['title'])
      end
    end

    def translate_team_id(found)
      mapping = {
        8 => 13
      }

      mapping[found] || found
    end
  end
end
