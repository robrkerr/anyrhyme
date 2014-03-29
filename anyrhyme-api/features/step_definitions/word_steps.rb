
Given(/^there is a word "([^"]*)"$/) do |name|
  @word = FactoryGirl.create(:word, name: name)
end

Given(/^that word has phonemes:$/) do |table|
  n = table.hashes.length
  k = 0
  table.hashes.each_with_index do |attributes,i|
    phoneme = Phoneme.find(:all, :conditions => attributes.slice("name")).first

    k += 1 unless (i==0) || ((attributes[:ptype]=="vowel")==(table.hashes[i-1][:ptype]=="vowel"))
    @word.word_phonemes.create!({:phoneme_id => phoneme.id, 
                                 :position => i, 
                                 :r_position => n-1-i,
                                 :vc_block => k,
                                 :v_stress => attributes[:stress]})
  end
end

When(/^there are (\d+) other words$/) do |number|
  number.to_i.times { FactoryGirl.create!(:word) }
end

Then(/^I should not see all words$/) do
  should_not satisfy { |page| Word.all.map { |word| page.has_content?(word.name) }.all? }
end

Then(/^I should see some words$/) do
  should satisfy { |page| Word.all.map { |word| page.has_content?(word.name) }.any? }
end

When(/^I type in "([^"]*)"$/) do |input|
  steps(%Q{When I fill in "query_text" with "#{input}"})
end

When(/^I search for "([^"]*)"$/) do |input|
  steps(%Q{
    When I type in "#{input}"
    And I press "Rap"
  })
end

When(/^I have a bunch of words$/) do
  seeder = Seeder.new false
  words = PhoneticWordReader.read_words 'data/cmudict.0.7a.partial'
  seeder.seed_words words
end
