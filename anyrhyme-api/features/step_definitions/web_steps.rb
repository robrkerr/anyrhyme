Given(/^I am on the homepage$/) do
  visit "/"
end

Then(/^I should see "([^"]*)"$/) do |text|
  should have_content(text)
end

Then(/^I should not see "([^"]*)"$/) do |text|
  should_not have_content(text)
end

Then(/^I should see "([^"]*)" within "([^"]*)"$/) do |text,obj|
  within(obj) do
    should have_content(text)
  end
end

Then(/^I should not see "([^"]*)" within "([^"]*)"$/) do |text,obj|
  within(obj) do
    should_not have_content(text)
  end
end

Then(/^I should see that field "([^"]*)" does contain "([^"]*)"$/) do |field,text|
  should have_field(field, :with => text)
end

Then(/^I should see that field "([^"]*)" does not contain "([^"]*)"$/) do |field,text|
  should have_field(field)
  should_not have_field(field, :with => text)
end

Then(/^there should be an object "([^"]*)"$/) do |obj|
  should have_css(obj)
end

Then(/^there should not be an object "([^"]*)"$/) do |obj|
  should_not have_css(obj)
end

When(/^I fill in "([^"]*)" with "([^"]*)"$/) do |form_item, input|
  should have_css("#" + form_item, :count => 1)
  fill_in form_item, with: input
  should have_field(form_item, :with => input)
end

When(/^I select "([^"]*)" from "([^"]*)"$/) do |input, sel|
  select input, :from => sel
end

When(/^I press "([^"]*)"$/) do |button|
  click_button button
end

When(/^I check "([^"]*)"$/) do |chbox|
  check chbox
end

When(/^I follow "([^"]*)"$/) do |link|
  click_link link
end

When(/^I follow "([^"]*)" within "([^"]*)"$/) do |link,obj|
  within(obj) do
    click_link link
  end
end

