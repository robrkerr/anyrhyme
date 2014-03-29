class SegmentPhoneme < ActiveRecord::Base
  belongs_to :syllable_segment
  belongs_to :phoneme

end
