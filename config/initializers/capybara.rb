Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 60, js_errors: false)
end
if Rails.env.test?

  Capybara.register_driver :selenium_chrome_billy do |app|
    Capybara::Selenium::Driver.new(
      app, browser: :chrome,
      switches: [
          "--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}"
          # "--ignore-certificate-errors" # May be needed in future
        ]
      )
  end
  Capybara.default_driver = :poltergeist_billy
  # Capybara.default_driver = :selenium_chrome_billy
else
  Capybara.default_driver = :poltergeist
end
Capybara.default_wait_time = 20