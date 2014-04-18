class NewSyllable < ActiveRecord::Base
  belongs_to :word
  belongs_to :onset, class_name: "Segment"
  belongs_to :nucleus, class_name: "Segment"
  belongs_to :coda, class_name: "Segment"
  
end