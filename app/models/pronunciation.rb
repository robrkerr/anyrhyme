class Pronunciation < ActiveRecord::Base
  has_many :syllables, :order => 'position ASC'
  has_many :words
  has_many :spellings, :through => :words
  validates :label, :presence => true

  def label_with_syllable_breaks
  	syllables.map { |s| s.label }.join(" . ")
  end
  
end

