class WordMatcher

	def self.find_words syllables_to_match, num_syllables, match_at_least_num=true, end_syllable_to_match=false, reverse=false, limit=10, offset = 0
		v = self.where_string(syllables_to_match, num_syllables, match_at_least_num, end_syllable_to_match, reverse)
		where_string = v[0]
		number_to_match = v[1]
		if (limit==false) || (limit > 100) || (limit < 0)
			limit = 100
		end
		if (offset==false) || (offset < 0)
			offset = 0
		end
		NewWord.find_by_sql(<<-SQL)
			SELECT new_words.* 
			FROM new_words
			INNER JOIN
				( SELECT spelling_word_id 
					FROM new_syllables 
					WHERE #{where_string} 
					GROUP BY spelling_word_id 
					HAVING count(1) = #{number_to_match} 
					ORDER BY spelling_word_id 
					LIMIT #{limit} 
					OFFSET #{offset}
				) AS matches
			  ON matches.spelling_word_id = new_words.spelling_word_id
		SQL
		# results = NewWord.find_by_sql("SELECT new_words.* FROM (SELECT word_id FROM new_syllables WHERE #{where_string} GROUP BY word_id HAVING count(1) = #{number_to_match}) matches, new_words WHERE matches.word_id = new_words.id ORDER BY new_words.spelling LIMIT #{num} OFFSET #{offset}
	end

	def self.where_string syllables_to_match, num_syllables, match_at_least_num, end_syllable_to_match, reverse
		syllables_to_match.map! { |s| s ? self.convert_segment_labels_to_ids(s) : s }
		syllable_index_offset = reverse ? syllables_to_match.index { |s| s } : syllables_to_match.reverse.index { |s| s }
		number_to_match = syllables_to_match.count { |e| e }
		if !reverse
			where_string = syllables_to_match.reverse.each_with_index.map { |syllable,i|
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
				where_string += " OR (position = 0"
				where_string += self.sql_string_for_syllable(end_syllable_to_match) + ")"
			end
		else
			where_string = syllables_to_match.each_with_index.map { |syllable,i|
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
				where_string += " OR (r_position = 0"
				where_string += self.sql_string_for_syllable(end_syllable_to_match) + ")"
			end
		end
		return [where_string,number_to_match]
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
					stress = e[0][-1].to_i
					["*",e[1]]
				end
			else
				e[0] = "" if (e[0] == "_")
				segment = Segment.where({label: e[0], segment_type: i}).first
				segment ? [segment.id,e[1]] : ["*",e[1]]
			end
		}
		return converted_syllable + [stress]
	end
end
