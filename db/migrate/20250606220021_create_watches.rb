class CreateWatches < ActiveRecord::Migration[8.0]
  def change
    create_table :watches do |t|
      t.string :name, null: false
      t.text :description
      t.references :watchable, polymorphic: true, null: true
      t.boolean :active, default: true
      t.string :url
      t.text :omit_list
      t.boolean :exclude_bundles, default: false

      t.timestamps
    end

    add_index :watches, [ :watchable_type, :watchable_id ]
    add_index :watches, :active
  end
end
