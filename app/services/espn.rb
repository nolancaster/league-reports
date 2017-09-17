module ESPN
  class League
    Office  = Struct.new(:name, :founded, :current_season, :current_week)
    Team    = Struct.new(:id, :name)
    Matchup = Struct.new(:away, :home)
    Lineup  = Struct.new(:team, :team_name, :score, :result)

    attr_reader :id, :owners

    def initialize(id)
      @id = id
      @weeks = Hash.new { |h, k| h[k] = {} }
      @owners = Set.new
      @teams = []
    end

    def office
      return @office if @office
      scraper = Scraper::Office.new(leagueId: @id)
      @office = Office.new(scraper.name, scraper.founded, scraper.season, scraper.week )
    end

    def weeks
      (office.founded..office.current_season).each do |season|
        puts season
        weeks_for(season)
      end
      @weeks
    end

    def weeks_for(season)
      #TODO validate season in range
      max_week = current_season?(season) ? office.current_week : 17

      (1..max_week).each do |week|
        puts week
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
        [:away, :home].each do |side|
          lineup = Lineup.new
          lineup.team_name = matchup_scraper.team_name(side)
          lineup.score = matchup_scraper.score(side)
          matchup.send("#{side}=", lineup)
          @owners << matchup_scraper.owner_name(side)
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
      def initialize(page)
        @page = page
      end
    end

    class Matchup < Partial
      @@sides = [:away, :home]

      def team_name(side)
        team_row(side).at('.name a').text
      end

      def owner_name(side)
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
        @page.search('tr')[index(side)]
      end
    end
  end

  # def team_id(found)
  #   mapping = {
  #     8 => 13
  #   }

  #   mapping[found] || found
  # end
end
