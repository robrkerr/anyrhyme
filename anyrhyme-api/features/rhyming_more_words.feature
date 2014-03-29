Feature: Rhyming more words
  In order to find more words that rhyme
  As a user
  I want them to seed the word database properly and to view results on the page
  
  Background: We have more words
    Given I have a bunch of words
    And I am on the homepage

  Scenario: Ignoring identity rhymes
    When I search for "pie"
    Then I should not see "potpie" within "#results_table"
    And I should see "eye" within "#wr_0_"
    # When I search for "eye"
    When I follow "eye" within "#results_table"  
    Then I should see "pie" within "#wr_0_"
    And I should see "potpie" within "#wr_1_"
    # When I search for "potpie"
    When I follow "potpie" within "#wr_1_"
    Then I should not see "pie" within "#results_table"
    And I should see "eye" within "#wr_0_"

  Scenario: Ignoring more identity rhymes
    When I search for "believe"
    Then I should not see "leave" within "#results_table"

  Scenario: Ignoring more identity rhymes again
    When I search for "leave"
    Then I should not see "believe" within "#results_table"

  Scenario: Rhymes that aren't identity rhymes
    When I search for "brightly"
    Then I should see "rightly" within "#wr_0_"
    When I follow "rightly" within "#results_table"  
    Then I should see "brightly" within "#wr_0_"

  Scenario: Other rhymes that aren't identity rhymes
    When I search for "sleep"
    Then I should see "steep" within "#wr_0_"
    And I should see "sheep" within "#wr_1_"
    And I should see "steep" within "#wr_2_"
    And I should see "leap" within "#wr_3_"
    And I should see "seep" within "#wr_4_"
    And I should not see "asleep" within "#results_table"

  Scenario: Using filters
    When I type in "taboo"
    And I select "l" from "query[first_phoneme]"
    And I press "Rap"
    Then I should see "loo" within "#wr_0_"
    And I should not see "canoe" within "#results_table"
    When I select "" from "query[first_phoneme]"
    And I select "2" from "query[num_syllables]"
    And I press "Rap"
    Then I should see "canoe" within "#wr_0_"
    And I should not see "loo" within "#results_table"

  Scenario: Determining perfect rhymes
    When I search for "knightly"
    Then I should see "brightly" within "#wr_0_"
    And I should see "rightly" within "#wr_1_"
    And I should see "quietly" within "#wr_2_"
    When I check "query[perfect]"
    And I press "Rap"
    Then I should see "brightly" within "#wr_0_"
    And I should see "rightly" within "#wr_1_"
    And I should not see "quietly" within "#results_table"

  # Scenario: Searching for a word with multiple pronunciations
    # When I search for "buffet"
    # Then I should see "Please select a pronouncation."
    # And I should see that field "query[text]" does contain "buffet"
    # And I should see "buffet" within "#wr_0_"
    # And I should see "b" within "#wr_0_ div.phonemes"
    # And I should see "ah1" within "#wr_0_ div.phonemes"
    # And I should see "f" within "#wr_0_ div.phonemes"
    # And I should see "ah0" within "#wr_0_ div.phonemes"
    # And I should see "t" within "#wr_0_ div.phonemes"
    # And I should see "buffet" within "#wr_1_"
    # And I should see "b" within "#wr_1_ div.phonemes"
    # And I should see "ah0" within "#wr_1_ div.phonemes"
    # And I should see "f" within "#wr_1_ div.phonemes"
    # And I should see "ey1" within "#wr_1_ div.phonemes"
    # When I follow "buffet" within "#wr_0_"
    # Then I should see "buffet" within "#title_table div.title_word h2"
    # And I should see "buffet" within "#wr_heading_row"
    # And I should see "b" within "#wr_heading_row div.phonemes"
    # And I should see "ah1" within "#wr_heading_row div.phonemes"
    # And I should see "f" within "#wr_heading_row div.phonemes"
    # And I should see "ah0" within "#wr_heading_row div.phonemes"
    # And I should see "t" within "#wr_heading_row div.phonemes"
