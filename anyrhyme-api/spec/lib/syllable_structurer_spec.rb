require 'syllable_structurer'
require 'phonetic_word_reader'

describe SyllableStructurer do
	let(:syllables) { SyllableStructurer.new.group_phonemes phonemes }

	context "can identify the syllable in the word 'trust' correctly" do
		let(:phonemes) { ["t","r","ah1","s","t"] }
		
		it do
			syllables.length.should eql(1)
			syllables[0][:onset].should eql(["t","r"])
			syllables[0][:nucleus].should eql(["ah"])
			syllables[0][:coda].should eql(["s","t"])
			syllables[0][:stress].should eql(1)
		end
	end

	context "can identify the syllables in the word 'bandwagon' correctly" do
		let(:phonemes) { ["b","ae1","n","d","w","ae2","g","ah0","n"] }

		it do 
			syllables.length.should eql(3)
			syllables[0][:onset].should eql(["b"])
			syllables[0][:nucleus].should eql(["ae"])
			syllables[0][:coda].should eql(["n","d"])
			syllables[0][:stress].should eql(1)
			syllables[1][:onset].should eql(["w"])
			syllables[1][:nucleus].should eql(["ae"])
			syllables[1][:coda].should eql([])
			syllables[1][:stress].should eql(2)
			syllables[2][:onset].should eql(["g"])
			syllables[2][:nucleus].should eql(["ah"])
			syllables[2][:coda].should eql(["n"])
			syllables[2][:stress].should eql(0)
		end
	end

	context "can identify the syllables in the word 'postscripts' correctly" do
		let(:phonemes) { ["p","ow1","s","t","s","k","r","ih2","p","t","s"] }
		
		it do 
			syllables.length.should eql(2)
			syllables[0][:onset].should eql(["p"])
			syllables[0][:nucleus].should eql(["ow"])
			syllables[0][:coda].should eql(["s","t"])
			syllables[0][:stress].should eql(1)
			syllables[1][:onset].should eql(["s","k","r"])
			syllables[1][:nucleus].should eql(["ih"])
			syllables[1][:coda].should eql(["p","t","s"])
			syllables[1][:stress].should eql(2)
		end
	end

	context "can identify the syllables in the word 'strongholds' correctly" do
		let(:phonemes) { ["s","t","r","ao1","ng","hh","ow2","l","d"] }
		
		it do
			syllables.length.should eql(2)
			syllables[0][:onset].should eql(["s","t","r"])
			syllables[0][:nucleus].should eql(["ao"])
			syllables[0][:coda].should eql(["ng"])
			syllables[0][:stress].should eql(1)
			syllables[1][:onset].should eql(["hh"])
			syllables[1][:nucleus].should eql(["ow"])
			syllables[1][:coda].should eql(["l","d"])
			syllables[1][:stress].should eql(2)
		end
	end

	context "can identify the syllables in the word 'octopus' correctly" do
		let(:phonemes) { ["aa1","k","t","ah0","p","uh2","s"] }
		
		it do 
			syllables.length.should eql(3)
			syllables[0][:onset].should eql([])
			syllables[0][:nucleus].should eql(["aa"])
			syllables[0][:coda].should eql(["k"])
			syllables[0][:stress].should eql(1)
			syllables[1][:onset].should eql(["t"])
			syllables[1][:nucleus].should eql(["ah"])
			syllables[1][:coda].should eql([])
			syllables[1][:stress].should eql(0)
			syllables[2][:onset].should eql(["p"])
			syllables[2][:nucleus].should eql(["uh"])
			syllables[2][:coda].should eql(["s"])
			syllables[2][:stress].should eql(2)
		end
	end

	context "can identify the syllables in the word 'outright' correctly" do
		let(:phonemes) { ["aw1", "t", "r", "ay1", "t"] }
		
		it do 
			syllables.length.should eql(2)
			syllables[0][:onset].should eql([])
			syllables[0][:nucleus].should eql(["aw"])
			syllables[0][:coda].should eql(["t"])
			syllables[0][:stress].should eql(1)
			syllables[1][:onset].should eql(["r"])
			syllables[1][:nucleus].should eql(["ay"])
			syllables[1][:coda].should eql(["t"])
			syllables[1][:stress].should eql(1)
		end
	end

	context "can identify the syllables in the word 'abreast' correctly" do
		let(:phonemes) { ["ah0", "b", "r", "eh1", "s", "t"] }
		
		it do
			syllables.length.should eql(2)
			syllables[0][:onset].should eql([])
			syllables[0][:nucleus].should eql(["ah"])
			syllables[0][:coda].should eql([])
			syllables[0][:stress].should eql(0)
			syllables[1][:onset].should eql(["b","r"])
			syllables[1][:nucleus].should eql(["eh"])
			syllables[1][:coda].should eql(["s","t"])
			syllables[1][:stress].should eql(1)
		end
	end

	context "can identify the syllables in the word 'redrawing' correctly" do
		let(:phonemes) { ["r", "iy0", "d", "r", "ao1", "ih0", "ng"] }
		
		it do 
			syllables.length.should eql(3)
			syllables[0][:onset].should eql(["r"])
			syllables[0][:nucleus].should eql(["iy"])
			syllables[0][:coda].should eql([])
			syllables[0][:stress].should eql(0)
			syllables[1][:onset].should eql(["d","r"])
			syllables[1][:nucleus].should eql(["ao"])
			syllables[1][:coda].should eql([])
			syllables[1][:stress].should eql(1)
			syllables[2][:onset].should eql([])
			syllables[2][:nucleus].should eql(["ih"])
			syllables[2][:coda].should eql(["ng"])
			syllables[2][:stress].should eql(0)
		end
	end

	context "can identify the syllables in the word 'comply' correctly" do
		let(:phonemes) { ["k", "ah0", "m", "p", "l", "ay1"] }
		
		it do 
			syllables.length.should eql(2)
			syllables[0][:onset].should eql(["k"])
			syllables[0][:nucleus].should eql(["ah"])
			syllables[0][:coda].should eql(["m"])
			syllables[0][:stress].should eql(0)
			syllables[1][:onset].should eql(["p","l"])
			syllables[1][:nucleus].should eql(["ay"])
			syllables[1][:coda].should eql([])
			syllables[1][:stress].should eql(1)
		end
	end

	context "can identify the syllables in the word 'abandon' correctly" do
		let(:phonemes) { ["ah0", "b", "ae1", "n", "d", "ah0", "n"] }
		
		it do 
			syllables.length.should eql(3)
			syllables[0][:onset].should eql([])
			syllables[0][:nucleus].should eql(["ah"])
			syllables[0][:coda].should eql([])
			syllables[0][:stress].should eql(0)
			syllables[1][:onset].should eql(["b"])
			syllables[1][:nucleus].should eql(["ae"])
			syllables[1][:coda].should eql(["n","d"])
			syllables[1][:stress].should eql(1)
			syllables[2][:onset].should eql([])
			syllables[2][:nucleus].should eql(["ah"])
			syllables[2][:coda].should eql(["n"])
			syllables[2][:stress].should eql(0)
		end
	end

	context "can identify the syllables in (and prepare) a whole bunch of words without issue" do
		let(:read_words) { PhoneticWordReader.read_words "data/cmudict.0.7a.partial" }
		let(:words) { SyllableStructurer.new.prepare_words read_words }
		
		it { words.length.should eql(57) }
	end
end

