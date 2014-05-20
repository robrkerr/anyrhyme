class Word < ActiveRecord::Base
  has_many :syllables, :primary_key => 'spelling_word_id', :foreign_key => 'spelling_word_id', :order => 'position ASC'

end
