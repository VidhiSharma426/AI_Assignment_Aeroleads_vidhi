class CreateCallLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :call_logs do |t|
      t.references :phone_number, null: false, foreign_key: true
      t.string :call_sid, limit: 50 # Simulated Twilio Call SID
      t.string :status, null: false # queued, ringing, in-progress, completed, busy, failed, no-answer
      t.string :direction, default: 'outbound-api'
      t.datetime :started_at
      t.datetime :answered_at
      t.datetime :ended_at
      t.integer :duration_seconds, default: 0
      t.decimal :cost, precision: 8, scale: 4, default: 0.0
      t.string :from_number, limit: 15
      t.string :to_number, limit: 15
      t.text :error_message
      t.text :recording_url
      t.boolean :simulation, default: true
      t.json :metadata # Store additional call details
      
      t.timestamps
    end
    
    add_index :call_logs, :call_sid, unique: true
    add_index :call_logs, :status
    add_index :call_logs, :started_at
    add_index :call_logs, :created_at
    add_index :call_logs, [:phone_number_id, :created_at]
  end
end