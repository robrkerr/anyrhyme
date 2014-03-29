class WordLexeme < ActiveRecord::Base
  belongs_to :word
  belongs_to :lexeme

end
