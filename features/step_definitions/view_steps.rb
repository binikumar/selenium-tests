Given /^a simple view$/ do
  @view = Jenkins::View.create_view(@base_url, Jenkins::View.random_name, "List View")
end

Given /^a view$/ do
  @view = Jenkins::View.create_view(@base_url, Jenkins::View.random_name, "List View")
end

When /^I create a view with a type "([^"]*)" and name "([^"]*)"$/ do |type, name|
  @view = Jenkins::View.create_view(@base_url, name, type)
end

When /^I save the view$/ do
  click_button "OK"
end

When /^I visit the view page$/ do
  @view.open
end

When /^I build "([^"]*)" in view$/ do |job|
  find(:xpath, "//a[contains(@href, '/#{job}/build?')]/img[contains(@title, 'Schedule a build')]").click
end

Then /^I should see the view on the main page$/ do
  visit(@base_url)
  page.should have_xpath("//table[@id='viewList']//a[text()='#{@view.name}']")
end
