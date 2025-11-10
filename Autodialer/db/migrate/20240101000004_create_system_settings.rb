class CreateSystemSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :system_settings do |t|
      t.string :key, null: false, limit: 100
      t.text :value
      t.string :data_type, default: 'string' # string, integer, boolean, json
      t.text :description
      t.boolean :editable, default: true
      
      t.timestamps
    end
    
    add_index :system_settings, :key, unique: true
  end
end