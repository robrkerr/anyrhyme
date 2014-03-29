class CreateTables < ActiveRecord::Migration
  def change
  	# Spelling table
  	create_table :spellings do |t|
  		t.string :label

  		t.timestamps
  	end
  	# Pronunciation table
  	create_table :pronunciations do |t|
  		t.string :label
  		
  		t.timestamps
  	end
  	# Word table
  	create_table :words do |t|
  		t.integer :spelling_id
  		t.integer :pronunciation_id
  		t.integer :source
  		
  		t.timestamps
  	end
  	add_index :words, :spelling_id
    add_index :words, :pronunciation_id
    # Segment table
  	create_table :segments do |t|
  		t.string :label
      t.integer :segment_type
  		
  		t.timestamps
  	end
  	# Syllables table
  	create_table :syllables do |t|
  		t.integer :pronunciation_id
  		t.integer :position
  		t.integer :r_position
  		t.integer :onset_id
  		t.integer :nucleus_id
  		t.integer :coda_id
  		t.integer :stress
  		t.string :label
  		
  		t.timestamps
  	end
  	add_index :syllables, :pronunciation_id
  	# Phoneme table
  	create_table :phonemes do |t|
  		t.string :name
  		t.string :phoneme_type
  		
  		t.timestamps
  	end
  	# SegmentPhoneme table
  	create_table :segment_phonemes do |t|
  		t.integer :segment_id
  		t.integer :phoneme_id
  		
  		t.timestamps
  	end
  	add_index :segment_phonemes, :segment_id
  	add_index :segment_phonemes, :phoneme_id
  	# Lexeme table
  	create_table :lexemes do |t|
  		t.integer :entry_id
      t.string :word_class
  		t.text :gloss
  		
  		t.timestamps
  	end
  	# WordLexeme table
  	create_table :word_lexemes do |t|
  		t.integer :word_id
  		t.integer :lexeme_id
  		t.integer :source
  		
  		t.timestamps
  	end
  	add_index :word_lexemes, :word_id
  	add_index :word_lexemes, :lexeme_id
  end
end
