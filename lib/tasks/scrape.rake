task :scrape => :environment do |t|
  Scraper.new.call
end
