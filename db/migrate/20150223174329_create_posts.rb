class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :image
      t.text :shop_logo
      t.string :shop
      t.string :description
      t.decimal :price
      t.decimal :saving
      t.string :price_info
      t.string :unit_price
      t.string :saving_info

      t.timestamps
    end
  end
end
