class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.string :url, null: false
      t.string :slug, null: false
      t.string :image_url
      t.decimal :price, precision: 8, scale: 2
      t.datetime :last_scraped_at

      t.timestamps
    end

    add_index :products, :slug, unique: true
  end
end
