Feature: Rhyming some words
  In order to find some words that rhyme
  As a user
  I want them to to view results on the page
  
  Background: We have some words
    Given there is a word "dog"
    And that word has phonemes:
      | name    | stress  |
      | d       | 3       |
      | ao      | 1       |
      | g       | 3       |
    And there is a word "cat"
    And that word has phonemes:
      | name    | stress  |
      | k       | 3       |
      | ae      | 1       |
      | t       | 3       |
    And there is a word "hat"
    And that word has phonemes:
      | name    | stress  |
      | hh      | 3       |
      | ae      | 1       |
      | t       | 3       |
    And there is a word "apple"
    And that word has phonemes:
      | name    | stress  |
      | ae      | 1       |
      | p       | 3       |
      | ah      | 3       |
      | l       | 3       |
    And I am on the homepage

  Scenario: Entering a word
    When I type in "hat"
    And I press "Rap"
    Then I should see "hat" within "#title_banner div.title_word h2"
    And I should see that field "query[text]" does contain "hat"
    # And I should see "hat" within "#wr_heading_row"
    And I should see "hh" within "#wr_heading_row div.phonemes"
    And I should see "ae1" within "#wr_heading_row div.phonemes"
    And I should see "t" within "#wr_heading_row div.phonemes"
    And I should see "cat" within "div.result_simple"
    And I should see "cat" within "#wr_0_"
    And I should see "k" within "#wr_0_ div.phonemes"
    And I should see "ae1" within "#wr_0_ div.phonemes"
    And I should see "t" within "#wr_0_ div.phonemes"
    And I should not see "dog" within "div.result_simple"

  Scenario: Clicking on word
    When I search for "hat"
    And I follow "cat" within "div.result_simple"
    Then I should see "cat" within "#title_banner div.title_word h2"
    And I should not see "hat" within "#title_banner div.title_word h2"
    
  Scenario: Entering a invalid word
    When I search for "gggggg"
    Then I should see "The word you entered doesn't match any we know of."
    And I should see that field "query[text]" does contain "gggggg"

