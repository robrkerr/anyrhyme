class Syllable < ActiveRecord::Base
  belongs_to :pronunciation
  belongs_to :onset, class_name: "Segment"
  belongs_to :nucleus, class_name: "Segment"
  belongs_to :coda, class_name: "Segment"

  def detailed_syllable
  	{
      label: label,
      stress: stress,
      position: position,
      r_position: r_position,
      pronunciation_id: pronunciation_id,
      onset: {
      	id: onset.id,
      	label: onset.label
      },
      nucleus: {
      	id: nucleus.id,
      	label: nucleus.label
      },
      coda: {
      	id: coda.id,
      	label: coda.label
      }
    }
   end
  
end