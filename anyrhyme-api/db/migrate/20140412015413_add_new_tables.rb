class AddNewTables < ActiveRecord::Migration
  def change
  	# New Syllable Table
  	create_table :new_syllables do |t|
      t.string :spelling_word_id
  		t.integer :position
  		t.integer :r_position
  		t.integer :onset_id
  		t.integer :nucleus_id
  		t.integer :coda_id
  		t.string :onset_label
  		t.string :nucleus_label
  		t.string :coda_label
  		t.integer :stress
  		t.string :label
  		
  		t.timestamps
  	end
    add_index :new_syllables, :spelling_word_id
    add_index :new_syllables, [:r_position, :coda_id, :nucleus_id, :onset_id], name: 'ns_index1'
    add_index :new_syllables, [:r_position, :coda_id, :nucleus_id], name: 'ns_index2'
    add_index :new_syllables, [:r_position, :nucleus_id, :onset_id], name: 'ns_index3'
    add_index :new_syllables, [:r_position, :coda_id, :onset_id], name: 'ns_index4'
    add_index :new_syllables, [:r_position, :coda_id], name: 'ns_index5'
    add_index :new_syllables, [:r_position, :nucleus_id], name: 'ns_index6'
    add_index :new_syllables, [:r_position, :onset_id], name: 'ns_index7'
    add_index :new_syllables, [:position, :coda_id, :nucleus_id, :onset_id], name: 'ns_index8'
    add_index :new_syllables, [:position, :coda_id, :nucleus_id], name: 'ns_index9'
    add_index :new_syllables, [:position, :nucleus_id, :onset_id], name: 'ns_index10'
    add_index :new_syllables, [:position, :coda_id, :onset_id], name: 'ns_index11'
    add_index :new_syllables, [:position, :coda_id], name: 'ns_index12'
    add_index :new_syllables, [:position, :nucleus_id], name: 'ns_index13'
    add_index :new_syllables, [:position, :onset_id], name: 'ns_index14'
    add_index :new_syllables, [:r_position, :coda_id, :nucleus_id, :onset_id, :stress], name: 'ns_index15'
    add_index :new_syllables, [:r_position, :coda_id, :nucleus_id, :stress], name: 'ns_index16'
    add_index :new_syllables, [:r_position, :nucleus_id, :onset_id, :stress], name: 'ns_index17'
    add_index :new_syllables, [:r_position, :coda_id, :onset_id, :stress], name: 'ns_index18'
    add_index :new_syllables, [:r_position, :coda_id, :stress], name: 'ns_index19'
    add_index :new_syllables, [:r_position, :nucleus_id, :stress], name: 'ns_index20'
    add_index :new_syllables, [:r_position, :onset_id, :stress], name: 'ns_index21'
    add_index :new_syllables, [:position, :coda_id, :nucleus_id, :onset_id, :stress], name: 'ns_index22'
    add_index :new_syllables, [:position, :coda_id, :nucleus_id, :stress], name: 'ns_index23'
    add_index :new_syllables, [:position, :nucleus_id, :onset_id, :stress], name: 'ns_index24'
    add_index :new_syllables, [:position, :coda_id, :onset_id, :stress], name: 'ns_index25'
    add_index :new_syllables, [:position, :coda_id, :stress], name: 'ns_index26'
    add_index :new_syllables, [:position, :nucleus_id, :stress], name: 'ns_index27'
    add_index :new_syllables, [:position, :onset_id, :stress], name: 'ns_index28'

  	# New Word Table
  	create_table :new_words do |t|
  		t.string :spelling
  		t.string :pronunciation_label
  		t.text :lexeme_string
      t.text :syllable_string
      t.integer :source
      t.string :spelling_word_id

  		t.timestamps
  	end
    add_index :new_words, [:spelling, :pronunciation_label]
    add_index :new_words, :spelling
    add_index :new_words, :spelling_word_id
  end
end
