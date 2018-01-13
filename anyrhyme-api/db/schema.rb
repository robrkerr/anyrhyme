# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140508081154) do

  create_table "phonemes", :force => true do |t|
    t.string   "name"
    t.string   "phoneme_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segment_phonemes", :force => true do |t|
    t.integer  "segment_id"
    t.integer  "phoneme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segments", :force => true do |t|
    t.string   "label"
    t.integer  "segment_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "syllables", :force => true do |t|
    t.string   "spelling_word_id"
    t.integer  "position"
    t.integer  "r_position"
    t.integer  "onset_id"
    t.integer  "nucleus_id"
    t.integer  "coda_id"
    t.string   "onset_label"
    t.string   "nucleus_label"
    t.string   "coda_label"
    t.integer  "stress"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "words", :force => true do |t|
    t.string   "spelling"
    t.string   "pronunciation_label"
    t.text     "lexeme_string"
    t.text     "syllable_string"
    t.integer  "source"
    t.string   "spelling_word_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
