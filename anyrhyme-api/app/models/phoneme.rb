class Phoneme < ActiveRecord::Base

  def is_vowel
  	phoneme_type == "vowel"
  end

  def possible_stresses
  	is_vowel ? [0,1,2] : [3]
  end

  def stressed_name stress
  	name + (is_vowel ? stress.to_s : "")
  end

  def autocomplete_format 
    possible_stresses.map { |i| {
    	:label => stressed_name(i), 
      :stress => i, 
      :phoneme_id => id,
      :type => phoneme_type
    }}
  end

end
