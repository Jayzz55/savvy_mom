require 'rails_helper'
require 'spec_helper'

feature 'user view posts' do
  scenario 'user view the posts' do
    visit posts_path
    expect(page).to have_content("Description")
  end

end