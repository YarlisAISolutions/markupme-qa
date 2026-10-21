@ui @regression @site
Feature: Static documentation site
  # GOAL: `markupme build examples -o examples/site` produces a working site: an index, one page
  #       per Markdown file, sidebar navigation, client-side search, diagrams and shared assets.
  # ROLE: anonymous reader.  ENVS: local (CI builds the site before starting `markupme serve`).

  Scenario: The generated index lists every page
    Given I navigate to the "site-home" page
    Then the "Docs" heading should be visible
    When I click the "MarkupMe kitchen sink" link
    Then the page URL should contain "kitchen-sink.html"
    And the "MarkupMe kitchen sink" heading should be visible

  Scenario: Pages have sidebar navigation and search
    Given I navigate to the "site-page" page
    Then the "Pages" navigation should be visible
    And searching the site for "callouts" should list "MarkupMe kitchen sink"

  @diagrams
  Scenario: Diagrams render from the site's own assets
    Given I navigate to the "site-page" page
    Then the page should show a rendered "graphviz" diagram
    And the Mermaid diagram should finish rendering

  @a11y
  Scenario: Site pages are accessible
    Given I navigate to the "site-page" page
    Then the page should have exactly one level-1 heading
    And the heading levels should not skip a level
    And the page should have no accessibility violations of impact "serious" or worse
