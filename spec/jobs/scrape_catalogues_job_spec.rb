require 'rails_helper'
require './app/jobs/scrape_catalogues_job.rb'

describe "scrape_catalogues_job#saving" do
  it "returns ['',''] when price_info = 'Combo $57.00' and saving_info = '' " do
    price_info = 'Combo $57.00'
    saving_info = ''
    expect(ScrapeCataloguesJob.new.saving(price_info,saving_info)).to eq([0.0,0])
  end

  it "returns ['14.00',''] when price_info = 'Any 2 for $30.00' and saving_info = 'Save from $14.00' " do
    price_info = 'Any 2 for $30.00'
    saving_info = 'Save from $14.00'
    expect(ScrapeCataloguesJob.new.saving(price_info,saving_info)).to eq([14,0])
  end

  it "returns ['10.00','50%'] when price_info = '$10.00 each' and saving_info = '1/2 Price, Save up to $10.00' " do
    price_info = '$10.00 each'
    saving_info = '1/2 Price, Save up to $10.00'
    expect(ScrapeCataloguesJob.new.saving(price_info,saving_info)).to eq([10,50])
  end

  it "returns ['1.79','42%'] when price_info = '$2.50 each' and saving_info = 'Introductory offer  Standard shelf price $4.29 each ' " do
    price_info = '$2.50 each'
    saving_info = 'Introductory offer  Standard shelf price $4.29 each '
    expect(ScrapeCataloguesJob.new.saving(price_info,saving_info)).to eq([1,42])
  end

  it "returns ['',''] when price_info = '$14.98 per dozen' and saving_info = ' $7.49 1/2 dozen' " do
    price_info = '$14.98 per dozen'
    saving_info = ' $7.49 1/2 dozen'
    expect(ScrapeCataloguesJob.new.saving(price_info,saving_info)).to eq([0,0])
  end

  it "returns ['',''] when price_info = nil and saving_info = nil " do
    price_info = nil
    saving_info = nil
    expect(ScrapeCataloguesJob.new.saving(price_info,saving_info)).to eq([0,0])
  end

  it "returns ['1.0','20%'] when price_info = '$4.00 each' and saving_info = 'Lower Price Every Day  Was $5.00' " do
    price_info = '$4.00 each'
    saving_info = 'Lower Price Every Day  Was $5.00'
    expect(ScrapeCataloguesJob.new.saving(price_info,saving_info)).to eq([1,20])
  end
end
