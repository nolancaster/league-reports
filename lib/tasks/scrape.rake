task :scrape => :environment do |t|
  Scraper.new.call(306883)
end
