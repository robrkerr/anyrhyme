class Word < ActiveRecord::Base
  has_many :syllables, :order => 'position ASC'

end
