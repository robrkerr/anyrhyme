require 'spec_helper'
require 'ar_helper'

describe ArHelper do
	subject { ArHelper.new }
	context "#find_ids_with_single_column" do
		context "for three spellings" do
			let(:words) { %w(foo bar bash) }

			it "should find no existing spellings" do
				subject.find_ids_with_single_column(Spelling, :label, words).
					should eql({})
			end

			context "with one already existing" do
				before do
					Spelling.create(label: "foo")
				end
				let(:foo_id) { Spelling.where(label: "foo").first.id }

				it "should find one existing spelling" do
					subject.find_ids_with_single_column(Spelling, :label, words).
						should eql({"foo" => foo_id})
				end
			end
		end

		context "for a large set" do
			let(:large_set) { 1000.times.map { |i| "word#{i}" } }
			let(:existing_words) { large_set.sample(100) }
			before do
				existing_words.each do |word_name|
					Spelling.create(label: word_name)
				end
			end
			let(:all_ids) { Hash[Spelling.all.map { |w| [w.label, w.id] }] }

			it "should find all existing spellings" do
				subject.find_ids_with_single_column(Spelling, :label, large_set).
					should eql(all_ids)
			end
		end
	end

	context "#find_ids_with_multiple_columns" do
		context "for words (which are indexed on multiple fields)" do
			let(:key_fields) { [:spelling_id, :pronunciation_id] }
			let(:word_entries) { [[1,1],[1,2],[2,3],[3,4],[2,4]] }

			it "should find no existing words" do
				subject.find_ids_with_multiple_columns(Word, key_fields, word_entries).
					should eql({})
			end

			context "with one word already existing" do
				before do
					Word.create({spelling_id: 1, pronunciation_id: 1, source: 0})
				end
				let(:entry_id) { Word.where({spelling_id: 1, pronunciation_id: 1}).first.id }

				it "should find one existing word" do
					subject.find_ids_with_multiple_columns(Word, key_fields, word_entries).
						should eql({[1,1] => entry_id})
				end
			end
		end
	end
end