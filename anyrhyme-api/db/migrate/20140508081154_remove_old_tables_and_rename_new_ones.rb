class RemoveOldTablesAndRenameNewOnes < ActiveRecord::Migration
  def up
  	drop_table :words
  	drop_table :syllables
  	drop_table :spellings
  	drop_table :pronunciations
  	drop_table :lexemes
  	drop_table :word_lexemes
  	rename_table :new_syllables, :syllables
  	rename_table :new_words, :words
  end

  def down
  	raise ActiveRecord::IrreversibleMigration
  end
end
