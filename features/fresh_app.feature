Feature: Fresh app
  Scenario: All pages are generated proprerly
    Given the Server is running at "fresh-app"
    When I go to "/portfolio.html"
    Then I should see 2 images