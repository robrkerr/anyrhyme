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

  add_index "segment_phonemes", ["phoneme_id"], :name => "index_segment_phonemes_on_phoneme_id"
  add_index "segment_phonemes", ["segment_id"], :name => "index_segment_phonemes_on_segment_id"

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

  add_index "syllables", ["position", "coda_id", "nucleus_id", "onset_id", "stress"], :name => "ns_index22"
  add_index "syllables", ["position", "coda_id", "nucleus_id", "onset_id"], :name => "ns_index8"
  add_index "syllables", ["position", "coda_id", "nucleus_id", "stress"], :name => "ns_index23"
  add_index "syllables", ["position", "coda_id", "nucleus_id"], :name => "ns_index9"
  add_index "syllables", ["position", "coda_id", "onset_id", "stress"], :name => "ns_index25"
  add_index "syllables", ["position", "coda_id", "onset_id"], :name => "ns_index11"
  add_index "syllables", ["position", "coda_id", "stress"], :name => "ns_index26"
  add_index "syllables", ["position", "coda_id"], :name => "ns_index12"
  add_index "syllables", ["position", "nucleus_id", "onset_id", "stress"], :name => "ns_index24"
  add_index "syllables", ["position", "nucleus_id", "onset_id"], :name => "ns_index10"
  add_index "syllables", ["position", "nucleus_id", "stress"], :name => "ns_index27"
  add_index "syllables", ["position", "nucleus_id"], :name => "ns_index13"
  add_index "syllables", ["position", "onset_id", "stress"], :name => "ns_index28"
  add_index "syllables", ["position", "onset_id"], :name => "ns_index14"
  add_index "syllables", ["r_position", "coda_id", "nucleus_id", "onset_id", "stress"], :name => "ns_index15"
  add_index "syllables", ["r_position", "coda_id", "nucleus_id", "onset_id"], :name => "ns_index1"
  add_index "syllables", ["r_position", "coda_id", "nucleus_id", "stress"], :name => "ns_index16"
  add_index "syllables", ["r_position", "coda_id", "nucleus_id"], :name => "ns_index2"
  add_index "syllables", ["r_position", "coda_id", "onset_id", "stress"], :name => "ns_index18"
  add_index "syllables", ["r_position", "coda_id", "onset_id"], :name => "ns_index4"
  add_index "syllables", ["r_position", "coda_id", "stress"], :name => "ns_index19"
  add_index "syllables", ["r_position", "coda_id"], :name => "ns_index5"
  add_index "syllables", ["r_position", "nucleus_id", "onset_id", "stress"], :name => "ns_index17"
  add_index "syllables", ["r_position", "nucleus_id", "onset_id"], :name => "ns_index3"
  add_index "syllables", ["r_position", "nucleus_id", "stress"], :name => "ns_index20"
  add_index "syllables", ["r_position", "nucleus_id"], :name => "ns_index6"
  add_index "syllables", ["r_position", "onset_id", "stress"], :name => "ns_index21"
  add_index "syllables", ["r_position", "onset_id"], :name => "ns_index7"
  add_index "syllables", ["spelling_word_id"], :name => "index_new_syllables_on_spelling_word_id"

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

  add_index "words", ["spelling", "pronunciation_label"], :name => "index_new_words_on_spelling_and_pronunciation_label"
  add_index "words", ["spelling"], :name => "index_new_words_on_spelling"
  add_index "words", ["spelling_word_id"], :name => "index_new_words_on_spelling_word_id"

end
