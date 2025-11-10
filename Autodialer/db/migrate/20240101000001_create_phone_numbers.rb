class CreatePhoneNumbers < ActiveRecord::Migration[7.0]
  def change
    create_table :phone_numbers do |t|
      t.string :number, null: false, limit: 15
      t.string :formatted_number, limit: 20
      t.string :status, default: 'pending', null: false
      t.text :notes
      t.datetime :last_called_at
      t.integer :call_attempts, default: 0
      t.string :source, default: 'manual' # manual, upload, paste
      
      t.timestamps
    end
    
    add_index :phone_numbers, :number, unique: true
    add_index :phone_numbers, :status
    add_index :phone_numbers, :created_at
  end
end