class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :image
      t.string :description
      t.string :saving
      t.string :saving_percentage
      t.string :price_info
      t.string :unit_price
      t.string :saving_info
      t.references :catalogue, index: true

      t.timestamps
    end
  end
end
