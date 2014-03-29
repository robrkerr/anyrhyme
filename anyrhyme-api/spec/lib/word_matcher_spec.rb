require 'word_matcher'
require 'spec_helper'
require 'seeder'
require 'syllable_structurer'
require 'phonetic_word_reader'

describe WordMatcher do
	subject { WordMatcher }

	# context "can find some rhymes (in the test word set)" do
	# 	let(:rhyming_pronunciations) { subject.find_rhymes pronunciation }
	# 	before do 
	# 		read_words = PhoneticWordReader.read_words "data/cmudict.0.7a.partial"
	# 		words = SyllableStructurer.new.prepare_words read_words
	# 		Seeder.new(false).seed_words words, 0
	# 	end

	# 	context "when it finds what rhymes with house" do
	# 		let(:pronunciation) { Spelling.where(label: "house").first.words.first.pronunciation }
			
	# 		it { rhyming_pronunciations.length.should eql(1) }
	# 		it { rhyming_pronunciations.first.spellings.first.label.should eql("mouse") }
	# 	end

	# 	context "when it finds what rhymes with mouse" do
	# 		let(:pronunciation) { Spelling.where(label: "mouse").first.words.first.pronunciation }
			
	# 		it { rhyming_pronunciations.length.should eql(1) }
	# 		it { rhyming_pronunciations.first.spellings.first.label.should eql("house") }
	# 	end

	# 	context "when it finds what rhymes with cutthroat" do
	# 		let(:pronunciation) { Spelling.where(label: "cutthroat").first.words.first.pronunciation }

	# 		it { rhyming_pronunciations.length.should eql(0) }
	# 	end
	# end

	context "can find matching words (from the test word set)" do
		let(:matching_pronunciations) { subject.find_words syllables_to_match, num_syllables }
		before do 
			read_words = PhoneticWordReader.read_words "data/cmudict.0.7a.partial"
			words = SyllableStructurer.new.prepare_words read_words
			Seeder.new(false).seed_words words, 0
		end

		context "when it finds words that rhyme" do
			let(:syllables_to_match) { 
				new_syllables = pronunciation.syllables.map { |s| 
					[[s.onset.label,true],[s.nucleus.label + "#{s.stress}",true],[s.coda.label,true]] 
				} 
				new_syllables.first[0][1] = false
				new_syllables
			}
			let(:num_syllables) { pronunciation.syllables.length }

			context "with house" do
				let(:pronunciation) { Spelling.where(label: "house").first.words.first.pronunciation }
				
				it { matching_pronunciations.length.should eql(1) }
				it { matching_pronunciations.first.spellings.first.label.should eql("mouse") }
			end

			context "with mouse" do
				let(:pronunciation) { Spelling.where(label: "mouse").first.words.first.pronunciation }
				
				it { matching_pronunciations.length.should eql(1) }
				it { matching_pronunciations.first.spellings.first.label.should eql("house") }
			end

			context "with cutthroat" do
				let(:pronunciation) { Spelling.where(label: "cutthroat").first.words.first.pronunciation }

				it { matching_pronunciations.length.should eql(0) }
			end
		end
	end
end



# When I search for "pie"
#     Then I should not see "potpie" within "#results_table"
#     And I should see "eye" within "#wr_0_"
#     # When I search for "eye"
#     When I follow "eye" within "#results_table"  
#     Then I should see "pie" within "#wr_0_"
#     And I should see "potpie" within "#wr_1_"
#     # When I search for "potpie"
#     When I follow "potpie" within "#wr_1_"
#     Then I should not see "pie" within "#results_table"
#     And I should see "eye" within "#wr_0_"

#   Scenario: Ignoring more identity rhymes
#     When I search for "believe"
#     Then I should not see "leave" within "#results_table"

#   Scenario: Ignoring more identity rhymes again
#     When I search for "leave"
#     Then I should not see "believe" within "#results_table"

#   Scenario: Rhymes that aren't identity rhymes
#     When I search for "brightly"
#     Then I should see "rightly" within "#wr_0_"
#     When I follow "rightly" within "#results_table"  
#     Then I should see "brightly" within "#wr_0_"

#   Scenario: Other rhymes that aren't identity rhymes
#     When I search for "sleep"
#     Then I should see "steep" within "#wr_0_"
#     And I should see "sheep" within "#wr_1_"
#     And I should see "steep" within "#wr_2_"
#     And I should see "leap" within "#wr_3_"
#     And I should see "seep" within "#wr_4_"
#     And I should not see "asleep" within "#results_table"

#   Scenario: Using filters
#     When I type in "taboo"
#     And I select "l" from "query[first_phoneme]"
#     And I press "Rap"
#     Then I should see "loo" within "#wr_0_"
#     And I should not see "canoe" within "#results_table"
#     When I select "" from "query[first_phoneme]"
#     And I select "2" from "query[num_syllables]"
#     And I press "Rap"
#     Then I should see "canoe" within "#wr_0_"
#     And I should not see "loo" within "#results_table"

#   Scenario: Determining perfect rhymes
#     When I search for "knightly"
#     Then I should see "brightly" within "#wr_0_"
#     And I should see "rightly" within "#wr_1_"
#     And I should see "quietly" within "#wr_2_"
#     When I check "query[perfect]"
#     And I press "Rap"
#     Then I should see "brightly" within "#wr_0_"
#     And I should see "rightly" within "#wr_1_"
#     And I should not see "quietly" within "#results_table"

#   