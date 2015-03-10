web: bundle exec unicorn -p $PORT -E $RACK_ENV -c ./config/unicorn.rb
before_fork do |server, worker|
   @sidekiq_pid ||= spawn("bundle exec sidekiq -c 2")
end