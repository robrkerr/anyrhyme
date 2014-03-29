Feature: Adding new words
  In order to add new words to the dictionary
  As a user
  I want them to view existing words and enter the details of the new word 
  
  Background: We have existing words
    Given I have a bunch of words
    And I am on the homepage
    And I follow "Dictionary" within "#links"

  Scenario: Adding the new word "muffin"
    When I type in "muffin"
    And I press "Search"
    Then I should not see "muffin" within "#results_table"
    And I should see "add new word..." within "#results_table"
    When I follow "add new word..." within "#results_table"
    Then I should see "muffin" within "#title_banner div.title_word h2"
    When I fill in "new_phoneme" with "b"
    And I press "Create Word"


    