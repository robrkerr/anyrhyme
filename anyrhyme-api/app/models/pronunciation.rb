class Pronunciation < ActiveRecord::Base
  has_many :syllables, :order => 'position ASC'
  has_many :words
  has_many :spellings, :through => :words
  validates :label, :presence => true

end

