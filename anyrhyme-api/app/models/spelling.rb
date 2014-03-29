class Spelling < ActiveRecord::Base
  has_many :words
  has_many :pronunciations, :through => :words
  validates :label, :presence => true

end

