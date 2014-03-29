require 'spec_helper'
require 'seeder'
require 'phoneme_loader'

describe Seeder do
	let(:seeder) { Seeder.new false }
	let(:phonemes) { PhonemeLoader.get_phoneme_data }
	before do			
		seeder.seed_phonemes phonemes
	end

	context "can enter a single phoneme into the phoneme table" do
		let(:phonemes) { [{:name => "aa", :phoneme_type => "vowel"}] }
		let(:phoneme) { Phoneme.first }

		it { Phoneme.count.should eql(1) }
		it { phoneme.name.should eql("aa") }
		it { phoneme.phoneme_type.should eql("vowel") }
	end

	context "can enter multiple phonemes into the phoneme table" do
		let(:phonemes) { [{:name => "aa", :phoneme_type => "vowel"},
											{:name => "n",  :phoneme_type => "nasal"}] }
		let(:phoneme) { Phoneme.first }

		it { Phoneme.count.should eql(2) }
	end

	it "can enter the full set of phonemes into the phoneme tables" do
		Phoneme.count.should eql(39)
	end

	context "can seed words and their pronunciations" do
		context "with a single word" do
			let(:syllables) { [{:onset => ["jh"], :nucleus => ["eh"], :coda => ["s"], :stress => 1},
						 			 			 {:onset => ["t"],  :nucleus => ["er"], :coda => [],    :stress => 0}] }
			let(:word_name) { "jester" }
			let(:pronunciation_label) { "jh-eh1-s-t-er0" }
			let(:words) { [{:name => word_name, :syllables => syllables}] }
			let(:base_source) { 7 }
			before { seeder.seed_words words, base_source }

			context "should insert that word" do
				it { Spelling.count.should eql(1) }
				it { Spelling.first.label.should eql(word_name) }
			end

			context "should insert that word's pronunciation" do
				it { Pronunciation.count.should eql(1) }
				it { Pronunciation.first.label.should eql(pronunciation_label) }
			end

			context "word and pronunciation should be linked" do
				let(:word) { Word.first }

				it "should create a word pronunciation" do 
					Word.count.should eql(1)
				end

				it "should record the source" do
					word.source.should eql(base_source)
				end
				
				context "the link should be correct" do
					it { word.name.should eql(word_name) }
					it { word.pronunciation.label.should eql(pronunciation_label) }
				end
			end

			context "the pronunciation's syllables should be added" do
				let(:syllable1) { Syllable.order("position ASC").first }
				let(:syllable2) { Syllable.order("position ASC").last }

				it { Syllable.count.should eql(2) }
				it { syllable1.pronunciation.label.should eql(pronunciation_label) }
				it { syllable2.pronunciation.label.should eql(pronunciation_label) }
				it { syllable1.position.should eql(0) }
				it { syllable1.r_position.should eql(1) }
				it { syllable1.stress.should eql(1) }
				it { syllable1.label.should eql("jh-eh1-s") }
				it { syllable2.position.should eql(1) }
				it { syllable2.r_position.should eql(0) }
				it { syllable2.stress.should eql(0) }
				it { syllable2.label.should eql("t-er0") }
			end

			context "the syllable segments should be added" do
				it { Segment.count.should eql(6) }
				it { SegmentPhoneme.count.should eql(5) }
			end
		end

		context "with multiple words and pronunciations" do
			let(:word_name1) { "jester" }
			let(:word_name2) { "jestor" }
			let(:syllables1) { [{:onset => ["jh"], :nucleus => ["eh"], :coda => ["s"], :stress => 1},
						 			 		 	  {:onset => ["t"],  :nucleus => ["er"], :coda => [],    :stress => 0}] }
			let(:pronunciation_label1) { "jh-eh1-s-t-er0" }
			let(:syllables2) { [{:onset => ["jh"], :nucleus => ["eh"], :coda => ["s"], :stress => 1},
						 			 			  {:onset => [],     :nucleus => ["er"], :coda => [],    :stress => 0}] }
			let(:pronunciation_label2) { "jh-eh1-s-er0" }
			let(:words) { [{:name => word_name1, :syllables => syllables1},
										 {:name => word_name2, :syllables => syllables1},
										 {:name => word_name1, :syllables => syllables2},
										 {:name => word_name2, :syllables => syllables2}] }
			let(:base_source) { 41 }
			before { seeder.seed_words words, base_source }

			context "should insert both spellings" do
				it { Spelling.count.should eql(2) }
				it { Spelling.order("label ASC").first.label.should eql(word_name1) }
				it { Spelling.order("label ASC").last.label.should eql(word_name2) }
			end

			context "should insert the two different pronunciations" do
				it { Pronunciation.count.should eql(2) }
				it { Pronunciation.order("label ASC").first.label.should eql(pronunciation_label2) }
				it { Pronunciation.order("label ASC").last.label.should eql(pronunciation_label1) }
			end

			context "spellings and their pronunciations should be linked as words" do
				let(:word) { Word.first }

				it "should create all four words" do 
					Word.count.should eql(4)
				end

				it "should record the source" do
					word.source.should eql(base_source)
				end
				
				context "the link should be correct" do
					it { word.name.should eql(word_name1) }
					it { word.pronunciation.label.should eql(pronunciation_label1) }
				end
			end

			context "the pronunciation's syllables should be added" do
				let(:syllable1) { Syllable.order("pronunciation_id ASC, position ASC")[0] }
				let(:syllable2) { Syllable.order("pronunciation_id ASC, position ASC")[1] }
				let(:syllable3) { Syllable.order("pronunciation_id ASC, position ASC")[2] }
				let(:syllable4) { Syllable.order("pronunciation_id ASC, position ASC")[3] }

				it { Syllable.count.should eql(4) }
				it { syllable1.pronunciation.label.should eql(pronunciation_label1) }
				it { syllable2.pronunciation.label.should eql(pronunciation_label1) }
				it { syllable3.pronunciation.label.should eql(pronunciation_label2) }
				it { syllable4.pronunciation.label.should eql(pronunciation_label2) }
			end
		end
	end

	context "can seed words and their lexemes" do
		let(:word_name1) { "jester" }
		let(:word_name2) { "buffet" }
		let(:word_name3) { "word" }
		let(:word_name4) { "dog" }
		let(:word_name5) { "cat" }
		let(:gloss1) { "gloss1" }
		let(:gloss2) { "gloss2" }
		let(:gloss3) { "gloss3' having" }
		let(:gloss4) { "gloss4" }
		let(:empty_syllables) { [] }
		let(:words) { [{:name => word_name1, :syllables => empty_syllables},
									 {:name => word_name2, :syllables => empty_syllables},
									 {:name => word_name3, :syllables => empty_syllables},
									 {:name => word_name4, :syllables => empty_syllables},
									 {:name => word_name5, :syllables => empty_syllables}] }
		let(:base_source) { 41 }
		let(:lexemes) { [{entry_id: 0, word_class: "verb",   gloss: gloss1}, 
										 {entry_id: 1, word_class: "noun",   gloss: gloss2},
										 {entry_id: 2, word_class: "adverb", gloss: gloss3},
										 {entry_id: 3, word_class: "verb",   gloss: gloss4}] }
		let(:word_to_lexemes) { {word_name1 => [lexemes[0]], 
														 word_name2 => [lexemes[1]], 
														 word_name3 => [lexemes[0],lexemes[3]],  
														 word_name5 => [lexemes[0],lexemes[2],lexemes[3]]} }
		before { seeder.seed_words words, base_source }
		before { seeder.seed_lexemes word_to_lexemes, base_source }

		it "should add all lexemes" do
			Lexeme.count.should eql(4)
		end

		it "should add all word-lexeme links" do
			WordLexeme.count.should eql(7)
		end

		it "should have no lexemes for 'dog'" do
			Spelling.where(label: "dog").first.words.first.lexemes.length.should eql(0)
		end

		context "should have the correct lexemes for 'cat'" do
			it { Spelling.where(label: "cat").first.words.first.lexemes.length.should eql(3) }
			it { Spelling.where(label: "cat").first.words.first.lexemes[0].word_class.should eql("verb") }
			it { Spelling.where(label: "cat").first.words.first.lexemes[0].gloss.should eql(gloss1) }
			it { Spelling.where(label: "cat").first.words.first.lexemes[1].word_class.should eql("verb") }
			it { Spelling.where(label: "cat").first.words.first.lexemes[1].gloss.should eql(gloss4) }
			it { Spelling.where(label: "cat").first.words.first.lexemes[2].word_class.should eql("adverb") }
			it { Spelling.where(label: "cat").first.words.first.lexemes[2].gloss.should eql(gloss3) }
		end

		context "should have the correct lexemes for 'jester'" do
			it { Spelling.where(label: "jester").first.words.first.lexemes.length.should eql(1) }
			it { Spelling.where(label: "jester").first.words.first.lexemes[0].word_class.should eql("verb") }
			it { Spelling.where(label: "jester").first.words.first.lexemes[0].gloss.should eql(gloss1) }
			it { Spelling.where(label: "jester").first.words.first.word_lexemes[0].source.should eql(base_source) }
		end
	end
end

	# 	it "can add existing lexemes to words related to existing words with those lexemes" do
	# 		syllables1 = [{:onset => ["jh"], :nucleus => ["eh"], :coda => ["s"], :stress => 1},
	# 					 		 	  {:onset => ["t"],  :nucleus => ["er"], :coda => [],    :stress => 0}]
	# 		syllables2 = [{:onset => ["jh"], :nucleus => ["ow"], :coda => ["k"], :stress => 1},
	# 					 			  {:onset => [],     :nucleus => ["er"], :coda => [],    :stress => 0}]
	# 		words = [{:name => "jester", :syllables => syllables1}]
	# 		seeder.seed_words words, 0
	# 		words = [{:name => "joker",  :syllables => syllables2}]
	# 		seeder.seed_words words, 0
	# 		lexemes = [{:word_class => "noun", :gloss => "jester meaning1"},
	# 							 {:word_class => "verb", :gloss => "jester meaning2"}]
	# 		word_lexemes = [{:word => "jester", :lexemes => lexemes}]
	# 		seeder.seed_lexemes word_lexemes, 0
	# 		related_words = {"jester" => ["joker"]}
	# 		seeder.seed_extra_word_lexemes related_words, 0
	# 		Word.count.should eql(2)
	# 		Lexeme.count.should eql(2)
	# 		WordLexeme.count.should eql(4)
	# 		lexeme_records = Lexeme.order(:id).all
	# 		word_records = Word.order(:id).all
	# 		word_lexemes_records = WordLexeme.order([:word_id,:lexeme_id]).all
	# 		word_lexemes_records[0].word_id.should eql(word_records[0].id)
	# 		word_lexemes_records[0].lexeme_id.should eql(lexeme_records[0].id)
	# 		word_lexemes_records[0].source.should eql(0)
	# 		word_lexemes_records[1].word_id.should eql(word_records[0].id)
	# 		word_lexemes_records[1].lexeme_id.should eql(lexeme_records[1].id)
	# 		word_lexemes_records[1].source.should eql(0)
	# 		word_lexemes_records[2].word_id.should eql(word_records[1].id)
	# 		word_lexemes_records[2].lexeme_id.should eql(lexeme_records[0].id)
	# 		word_lexemes_records[2].source.should eql(0)
	# 		word_lexemes_records[3].word_id.should eql(word_records[1].id)
	# 		word_lexemes_records[3].lexeme_id.should eql(lexeme_records[1].id)
	# 		word_lexemes_records[3].source.should eql(0)
	# 	end

