require 'word_lexeme_reader'

describe WordLexemeReader do
	context "can read in a text file containing words and their lexemes" do
		let(:filepath) { "test.txt" }
		let(:text) { 
%Q{00001740 29 v 04 breathe 0 take_a_breath 0 respire 0 suspire 3 021 * 00005041 v 0000 * 00004227 v 0000 + 03121972 a 0301 + 00832852 n 0303 + 04087945 n 0301 + 04257960 n 0105 + 00832852 n 0101 ^ 00004227 v 0103 ^ 00005041 v 0103 $ 00002325 v 0000 $ 00002573 v 0000 ~ 00002573 v 0000 ~ 00002724 v 0000 ~ 00002942 v 0000 ~ 00003826 v 0000 ~ 00004032 v 0000 ~ 00004227 v 0000 ~ 00005041 v 0000 ~ 00006697 v 0000 ~ 00007328 v 0000 ~ 00017024 v 0000 02 + 02 00 + 08 00 | draw air into, and expel out of, the lungs; "I can breathe better when the air is clean"; "The patient is respiring"  
00001740 03 n 01 entity 0 003 ~ 00001930 n 0000 ~ 00002137 n 0000 ~ 04431553 n 0000 | that which is perceived or known or inferred to have its own distinct existence (living or nonliving)
02915411 06 n 03 buffet 0 counter 4 sideboard 0 006 @ 03410635 n 0000 #p 03205385 n 0000 ~ 03134404 n 0000 %p 03238608 n 0000 ~ 03775145 n 0000 %p 04197095 n 0000 | a piece of furniture that stands at the side of a dining room; has shelves and drawers  
01420232 35 v 02 buffet 1 buff 2 001 @ 01402698 v 0000 02 + 08 00 + 09 00 | strike, beat repeatedly; "The wind buffeted him"} }
		let(:word_to_lexeme) { WordLexemeReader.read_lexemes filepath }

		before do	
			File.open(filepath, "w") { |file| file.puts text }
		end

		it { word_to_lexeme.values.flatten.uniq.length.should eql(4) }
		it { word_to_lexeme.keys.length.should eql(8) }
		it { word_to_lexeme["buffet"].length.should eql(2) }
		it { word_to_lexeme["buff"].length.should eql(1) }
		it { word_to_lexeme["buff"][0][:word_class].should eql("verb") }
		it { word_to_lexeme["buff"][0][:gloss].should eql("strike, beat repeatedly; \"The wind buffeted him\"") }

		after do 
			File.delete(filepath)
		end
	end
end
