class WordMatcher

	def self.find_words syllables_to_match, num_syllables, match_at_least_num=true, end_syllable_to_match=false, reverse=false, num=10
		syllables_to_match.map! { |s| s ? self.convert_segment_labels_to_ids(s) : s }
		syllable_index_offset = reverse ? syllables_to_match.index { |s| s } : syllables_to_match.reverse.index { |s| s }
		number_to_match = syllables_to_match.count { |e| e }
		if !reverse
			sql_string = syllables_to_match.reverse.each_with_index.map { |syllable,i|
				if syllable
					new_i = syllables_to_match.first ? i-syllable_index_offset : i+syllable_index_offset
					string = "(r_position = #{new_i}"
					string += " AND position #{match_at_least_num ? ">" : ""}= #{num_syllables-1-new_i}" if new_i == 0
					string + self.sql_string_for_syllable(syllable) + ")"
				else 
					""
				end
			}.select { |str| str != "" }.join(" OR ")
			if end_syllable_to_match
				end_syllable_to_match = self.convert_segment_labels_to_ids(end_syllable_to_match)
				number_to_match += 1
				sql_string += " OR (position = 0"
				sql_string += self.sql_string_for_syllable(end_syllable_to_match) + ")"
			end
		else
			sql_string = syllables_to_match.each_with_index.map { |syllable,i|
				if syllable
					new_i = syllables_to_match.first ? i+syllable_index_offset : i-syllable_index_offset
					string = "(position = #{new_i}"
					string += " AND r_position #{match_at_least_num ? ">" : ""}= #{num_syllables-1-new_i}" if new_i == 0
					string + self.sql_string_for_syllable(syllable) + ")"
				else 
					""
				end
			}.select { |str| str != "" }.join(" OR ")
			if end_syllable_to_match
				end_syllable_to_match = self.convert_segment_labels_to_ids(end_syllable_to_match)
				number_to_match += 1
				sql_string += " OR (r_position = 0"
				sql_string += self.sql_string_for_syllable(end_syllable_to_match) + ")"
			end
		end
		if num==false
			num = 100
		end
		results = Syllable.where(sql_string)
									 		.select(:pronunciation_id)
				  				 		.group(:pronunciation_id)
				  				 		.having("count(1) = #{number_to_match}")
				  				 		.order("pronunciation_id ASC")
				  				 		.limit(num)
		pron_ids = results.map { |r| r.pronunciation_id }
		pronunciations = Pronunciation.find(pron_ids).group_by(&:id)
		pron_ids.map { |id| pronunciations[id].first }
	end

	def self.sql_string_for_syllable syllable
		string = ""
		string += " AND onset_id #{syllable[0][1] ? "=" : "!="} #{syllable[0][0]}" unless syllable[0][0]=="*"
		if syllable[3] == 3
			if syllable[1][1]
				string += " AND nucleus_id = #{syllable[1][0]}"
				string += " AND stress > 0"
			else
				string += " AND (nucleus_id != #{syllable[1][0]}"
				string += " OR stress = 0)"
			end
		elsif syllable[3]
			if syllable[1][1]
				string += " AND nucleus_id = #{syllable[1][0]}"
				string += " AND stress = #{syllable[3]}"
			else
				string += " AND (nucleus_id != #{syllable[1][0]}"
				string += " OR stress != #{syllable[3]})"
			end
		else
			string += " AND nucleus_id #{syllable[1][1] ? "=" : "!="} #{syllable[1][0]}" unless syllable[1][0]=="*"
		end
		string += " AND coda_id #{syllable[2][1] ? "=" : "!="} #{syllable[2][0]}" unless syllable[2][0]=="*"
		return string
	end

	def self.convert_segment_labels_to_ids syllable
		stress = false
		converted_syllable = syllable.each_with_index.map { |e,i|
			if e[0] == "*"
				e
			elsif (i==1) && (e[0] =~ /\d/)
				segment = Segment.where({label: e[0][0..-2], segment_type: i}).first
				if segment
					stress = e[0][-1].to_i
					[segment.id,e[1]]
				else
					["*",e[1]]
				end
			else
				segment = Segment.where({label: e[0], segment_type: i}).first
				segment ? [segment.id,e[1]] : ["*",e[1]]
			end
		}
		return converted_syllable + [stress]
	end
end
