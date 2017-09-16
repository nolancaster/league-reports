module ESPN
  class League
    Office = Struct.new(:name, :founded, :current_season, :current_week)
    Week = Struct.new(:season, :number, :data)

    attr_reader :id

    def initialize(id)
      @id = id
      @weeks = Hash.new { |h, k| h[k] = {} }
      @test
    end

    def office
      return @office if @office
      scraper = Scraper::Office.new(leagueId: @id)
      @office = Office.new(scraper.name, scraper.founded, scraper.current_season, scraper.current_week )
    end

    def weeks
      (office.founded..office.current_season).each do |season|
        weeks_for(season)
      end

      @weeks
    end

    def weeks_for(season)
      #TODO validate season in range
      max_week = (season == office.current_season) ? office.current_week : 17

      (1..max_week).each do |week|
        week_of(season, week)
      end

      @weeks[season]
    end

    def week_of(season, week)
      return @weeks[season][week] if @weeks[season][week]
      scraper = Scraper::Week.new(leagueId: @id, seasonId: season, matchupPeriodId: week)
      @weeks[season][week] = Week.new(season, week, scraper.title)
      #TODO test week is actually given week

      # if scraper.completed?
      #   puts page.title
      #   weeks = page.search('table.matchup')
      #   weeks.each do |matchup|
      #     teams = matchup.search('tr')
      #     info = []
      #     2.times do |i|
      #       team_info = {}
      #       team_row = teams[i]
      #       team_node = team_row.at('td.team')
      #       score_node = team_row.at('td.score')
      #       team_info[:team_name] = team_node.at('.name a').text
      #       team_info[:owner_name] = team_node.at('.owners').text
      #       team_info[:score] = score_node['title'].to_f
      #       team_info[:winner] = score_node.attr('class').include?('winning')
      #       info[i] = team_info
      #     end
      #     puts info.inspect
      #   end
      # end
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

      def current_season
        /seasonId: (\d+)/.match(@page.content)[1].to_i
      end

      def current_week
        /scoringPeriodId: (\d+)/.match(@page.content)[1].to_i
      end
    end

    class Week < Base
      def self.path
        'scoreboard'
      end

      def title
        @page.title
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
