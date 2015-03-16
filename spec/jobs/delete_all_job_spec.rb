require 'rails_helper'
require './app/jobs/delete_all_job.rb'

describe 'delete_all_job' do
  it 'deletes all catalogues and posts in the database' do
    10.times {create :catalogue_with_post}
    expect(Catalogue.all.count).to eq(10)
    expect(Post.all.count).to eq(10)
    DeleteAllJob.new.perform
    expect(Catalogue.all.count).to eq(0)
    expect(Post.all.count).to eq(0)
  end
end