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

ActiveRecord::Schema.define(:version => 20130626011040) do

  create_table "lexemes", :force => true do |t|
    t.integer  "entry_id"
    t.string   "word_class"
    t.text     "gloss"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phonemes", :force => true do |t|
    t.string   "name"
    t.string   "phoneme_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pronunciations", :force => true do |t|
    t.string   "label"
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

  create_table "spellings", :force => true do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "syllables", :force => true do |t|
    t.integer  "pronunciation_id"
    t.integer  "position"
    t.integer  "r_position"
    t.integer  "onset_id"
    t.integer  "nucleus_id"
    t.integer  "coda_id"
    t.integer  "stress"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "syllables", ["pronunciation_id"], :name => "index_syllables_on_pronunciation_id"

  create_table "word_lexemes", :force => true do |t|
    t.integer  "word_id"
    t.integer  "lexeme_id"
    t.integer  "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "word_lexemes", ["lexeme_id"], :name => "index_word_lexemes_on_lexeme_id"
  add_index "word_lexemes", ["word_id"], :name => "index_word_lexemes_on_word_id"

  create_table "words", :force => true do |t|
    t.integer  "spelling_id"
    t.integer  "pronunciation_id"
    t.integer  "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "words", ["pronunciation_id"], :name => "index_words_on_pronunciation_id"
  add_index "words", ["spelling_id"], :name => "index_words_on_spelling_id"

end
