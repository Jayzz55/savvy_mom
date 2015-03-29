require 'heroku-api'
desc "Scale UP dynos"
  task :spin_up => :environment do
  heroku = Heroku::API.new(:api_key => ENV["heroku_api_key"])
  heroku.post_ps_scale(ENV['APP_NAME'], 'web', 1)
end

desc "Scale Down dynos"
  task :spin_down => :environment do
  heroku = Heroku::API.new(:api_key => ENV["heroku_api_key"])
  heroku.post_ps_scale(ENV['APP_NAME'], 'web', 0)
end