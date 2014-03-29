require 'phonetic_word_reader'

describe PhoneticWordReader do
	context "can read in a text file containing words and their phonemes" do
		let(:filepath) { "test.txt" }
		let(:text) { 
%Q{A42128  EY1 F AO1 R T UW1 W AH1 N T UW1 EY1 T
.POINT  P OY1 N T
BRIGHTLY  B R AY1 T L IY0
JOURNALIST(1)  JH ER1 N AH0 L IH0 S T
VIKING'S  V AY1 K IH0 NG Z
TABOO  T AE0 B UW1
(BEGIN-PARENS  B IH0 G IH1 N P ER0 EH1 N Z} }
		let(:words) { PhoneticWordReader.read_words filepath }

		before do	
			File.open(filepath, "w") { |file| file.puts text }
		end

		it { words[0][:name].should eql("brightly") }
		it { words[0][:phonemes].should eql(["b","r","ay1","t","l","iy0"]) }
		it { words[1][:name].should eql("journalist") }
		it { words[1][:phonemes].should eql(["jh","er1","n","ah0","l","ih0","s","t"]) }
		it { words[2][:name].should eql("viking's") }
		it { words[2][:phonemes].should eql(["v","ay1","k","ih0","ng","z"]) }

		after do 
			File.delete(filepath)
		end
	end
end