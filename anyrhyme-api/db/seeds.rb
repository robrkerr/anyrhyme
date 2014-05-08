# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'seeder'
require 'syllable_structurer'
require 'phoneme_loader'
require 'phonetic_word_reader'
require 'word_lexeme_reader'

def seed_timer task_msg
  print task_msg
  time = Time.now
  yield
  print "Done. (#{Time.now-time}s)\n"
end

seeder = Seeder.new
seed_timer("Clearing tables... ") {
  seeder.clear_tables
}
seed_timer("Seeding phonemes... ") {
  seeder.seed_phonemes PhonemeLoader.get_phoneme_data
}
`split -a 2 -l 5000 data/cmudict.0.7a data/word_batch_`
Dir[Rails.root + "data/word_batch_*"].each_with_index do |file,i|
  puts "Loading words: Batch #{i+1}"
  read_words = []; words = []
  seed_timer("  Reading words... ") {
  	read_words = PhoneticWordReader.read_words(file)
  }
  seed_timer("  Grouping phonemes into syllables... ") {
    words = SyllableStructurer.new.prepare_words read_words
  }
  seed_timer("  Populating word tables... ") {
  	seeder.seed_words words, 0
  }
end
`rm data/word_batch_*`
`rm data/lexeme_batch_*`
seeder.clear_lexemes
cnt = 0
Dir[Rails.root + "data/wordnet/data.*"].each do |file|
  `split -a 1 -l 5000 #{file} data/lexeme_batch_`
  Dir[Rails.root + "data/lexeme_batch_*"].each do |split_file|
    cnt += 1
    puts "Loading lexemes: Batch #{cnt}"
    word_to_lexemes = {}
    seed_timer("  Reading lexemes... ") {
      word_to_lexemes = WordLexemeReader.read_lexemes split_file
    }
    seed_timer("  Populating lexeme tables... ") {
      seeder.seed_lexemes word_to_lexemes, 0
    }
  end
  `rm data/lexeme_batch_*`
end
# Dir[Rails.root + "data/wordnet/*.exc"].each_with_index do |file,i|
#   puts "Loading extra word relations: Batch #{i+1}"
#   word_relations = {}
#   seed_timer("  Reading word relations... ") {
#     word_relations = WordLexemeReader.read_word_relations(file)
#   }
#   seed_timer("  Populating word-lexemes table... ") {
#     seeder.seed_extra_word_lexemes word_relations
#   }
# end


