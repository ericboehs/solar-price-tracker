class CreateWatches < ActiveRecord::Migration[8.0]
  def change
    create_table :watches do |t|
      t.string :url, null: false
      t.string :watch_type, null: false, default: 'search'
      t.string :name, null: false
      t.text :description
      t.boolean :active, null: false, default: true
      t.text :omit_terms
      t.boolean :exclude_bundles, null: false, default: true
      t.datetime :last_scraped_at
      t.integer :products_found, default: 0
      t.integer :scrape_count, default: 0
      t.datetime :next_scrape_at

      t.timestamps
    end

    add_index :watches, :active
    add_index :watches, :watch_type
    add_index :watches, :last_scraped_at
    add_index :watches, :next_scrape_at
    add_index :watches, [ :active, :next_scrape_at ]
  end
end
