# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_01_01_000004) do
  create_table "ai_commands", force: :cascade do |t|
    t.text "input_text", null: false
    t.string "command_type"
    t.string "parsed_action"
    t.json "parsed_parameters"
    t.text "response_text"
    t.string "status", default: "pending"
    t.text "error_message"
    t.string "session_id", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["command_type"], name: "index_ai_commands_on_command_type"
    t.index ["created_at"], name: "index_ai_commands_on_created_at"
    t.index ["parsed_action"], name: "index_ai_commands_on_parsed_action"
    t.index ["session_id"], name: "index_ai_commands_on_session_id"
  end

  create_table "call_logs", force: :cascade do |t|
    t.integer "phone_number_id", null: false
    t.string "call_sid", limit: 50
    t.string "status", null: false
    t.string "direction", default: "outbound-api"
    t.datetime "started_at"
    t.datetime "answered_at"
    t.datetime "ended_at"
    t.integer "duration_seconds", default: 0
    t.decimal "cost", precision: 8, scale: 4, default: "0.0"
    t.string "from_number", limit: 15
    t.string "to_number", limit: 15
    t.text "error_message"
    t.text "recording_url"
    t.boolean "simulation", default: true
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["call_sid"], name: "index_call_logs_on_call_sid", unique: true
    t.index ["created_at"], name: "index_call_logs_on_created_at"
    t.index ["phone_number_id", "created_at"], name: "index_call_logs_on_phone_number_id_and_created_at"
    t.index ["phone_number_id"], name: "index_call_logs_on_phone_number_id"
    t.index ["started_at"], name: "index_call_logs_on_started_at"
    t.index ["status"], name: "index_call_logs_on_status"
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.string "number", limit: 15, null: false
    t.string "formatted_number", limit: 20
    t.string "status", default: "pending", null: false
    t.text "notes"
    t.datetime "last_called_at"
    t.integer "call_attempts", default: 0
    t.string "source", default: "manual"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_phone_numbers_on_created_at"
    t.index ["number"], name: "index_phone_numbers_on_number", unique: true
    t.index ["status"], name: "index_phone_numbers_on_status"
  end

  create_table "system_settings", force: :cascade do |t|
    t.string "key", limit: 100, null: false
    t.text "value"
    t.string "data_type", default: "string"
    t.text "description"
    t.boolean "editable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_system_settings_on_key", unique: true
  end

  add_foreign_key "call_logs", "phone_numbers"
end
