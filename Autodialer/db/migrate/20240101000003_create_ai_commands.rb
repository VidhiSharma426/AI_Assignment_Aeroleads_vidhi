class CreateAiCommands < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_commands do |t|
      t.text :input_text, null: false
      t.string :command_type # text, voice
      t.string :parsed_action # start_calling, make_call, show_logs, etc.
      t.json :parsed_parameters
      t.text :response_text
      t.string :status, default: 'pending' # pending, processed, failed
      t.text :error_message
      t.string :session_id, limit: 50
      
      t.timestamps
    end
    
    add_index :ai_commands, :command_type
    add_index :ai_commands, :parsed_action
    add_index :ai_commands, :created_at
    add_index :ai_commands, :session_id
  end
end