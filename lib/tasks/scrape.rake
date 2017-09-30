task :scrape => :environment do |t|
  streaks = Hash.new { |h, k| 0 }
  best = Hash.new { |h, k| 0 }
  l = ESPN::League.new(306883)
  all = l.weeks
  all.each do |season, weeks|
    if season > 2014
      weeks.each do |week, games|
        games.each do |game|
            streaks[game.away.owner] += game.home.score
            streaks[game.home.owner] += game.away.score
        end
      end
    end
  end
  puts "Points Against since 2015"
  streaks.sort_by {|_key, value| value}.reverse.each do |id, streak|
    puts "#{id} #{streak}"
  end
end
