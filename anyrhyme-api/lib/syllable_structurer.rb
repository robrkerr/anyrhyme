require 'phoneme_loader'

class SyllableStructurer

	def initialize
		@sonority_by_type = build_sonority_hash
		@phonemes = PhonemeLoader.phonemes_hash
	end

	def prepare_words read_words
		read_words.map { |word| 
      syllables = group_phonemes word[:phonemes]
      if syllables.length > 0
        {:name => word[:name], :syllables => syllables}
      else
        nil
      end
    }.compact
	end

	def group_phonemes word_phonemes
		types = word_phonemes.map { |ph| @phonemes[get_phoneme_without_stress(ph)]}
		vowel_stresses = word_phonemes.map { |ph| get_vowel_stress(ph) }.select { |stress| stress }
		chunked_types = []; chunk = []
		types.each { |t| 
			if t == "vowel"
				chunked_types << chunk
				chunked_types << [t]
				chunk = []
			else
				chunk << t
			end
		}
		chunked_types << chunk
		if chunked_types.length <= 1
			return []
		else
			syllables = chunked_types.each_slice(2).map { |e| e << [] }
			if chunked_types.last != ["vowel"]
				syllables = syllables[0..-2]
				syllables[-1][-1] = chunked_types.last
			end
		end
		1.upto(syllables.length-1) { |i|
			split_group = split_consonant_group(syllables[i][0],vowel_stresses[i-1..i])
			syllables[i-1][2] = split_group.first
			syllables[i][0] = split_group.last
		}
		word_phonemes = word_phonemes.reverse
		syllables.map { |e|
			hash = {}
			hash[:onset] = word_phonemes.pop(e[0].length).reverse
			vowel = word_phonemes.pop(e[1].length).reverse.first
			hash[:nucleus] = [get_phoneme_without_stress(vowel)]
			hash[:coda] = word_phonemes.pop(e[2].length).reverse
			hash[:stress] = get_vowel_stress(vowel)
			hash
		}
	end

	private

	def get_vowel_stress vowel
		stress = vowel[%r/[^a-z]/]
		stress.to_i if stress
	end

	def get_phoneme_without_stress phoneme
		phoneme[%r/[a-z]*/]
	end

	def split_consonant_group group, stresses
		stresses = stresses.map { |s| (s>0) ? (3-s) : s }
		if group.length < 2
			[[],group]
		else
			if stresses.first >= stresses.last
				1.upto(group.length-1).each { |i|
					sonority_increased = @sonority_by_type[group[i]] >= @sonority_by_type[group[i-1]]
					if sonority_increased
						return [group.take(i),group.drop(i)]
					end
				}
				return [group.take(group.length),group.drop(group.length)]
			else
				(group.length-2).downto(0).each { |i|
					sonority_increased = @sonority_by_type[group[i]] >= @sonority_by_type[group[i+1]]
					if sonority_increased
						return [group.take(i+1),group.drop(i+1)]
					end
				}
				return [group.take(0),group.drop(0)]
			end
		end
	end

	def build_sonority_hash
		sonority_order = ["vowel","aspirate","semivowel","liquid",
							"nasal","fricative","affricate","stop"]
		Hash[sonority_order.each_with_index.to_a.map { |e,i| [e,-i]}]
	end

end
