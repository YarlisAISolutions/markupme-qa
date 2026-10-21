@ui @pages
Feature: Rendered pages
  # GOAL: `markupme serve` renders a Markdown file as a complete page: TOC, alerts, callouts,
  #       highlighted code with copy buttons, server-side and browser diagrams, footnotes.
  # ROLE: anonymous reader.  ENVS: local (serves markupme/examples).

  Background:
    Given I navigate to the "kitchen-sink" page

  @smoke
  Scenario: The kitchen sink renders every block type
    Then the page title should contain "MarkupMe kitchen sink"
    And the "MarkupMe kitchen sink" heading should be visible
    And the table of contents should link to "Alerts and callouts"
    And I should see the text "Useful information."
    And I should see the text "Pro tip"
    And the "Copy code" button should be visible
    And I should see the exact text "GFM"

  @smoke @diagrams
  Scenario: Server-side and browser diagrams render
    Then the page should show a rendered "graphviz" diagram
    And the Mermaid diagram should finish rendering

  @smoke @security
  Scenario: Raw HTML in the source is sanitized in the page
    Then the page should not contain the text "alert('xss')"
    And every image on the page should carry an alt attribute

  @smoke @a11y
  Scenario: The page structure is accessible
    Then the page should have exactly one level-1 heading
    And the heading levels should not skip a level
    And the page should have no accessibility violations of impact "serious" or worse

  @regression
  Scenario: In-page links navigate to their heading
    When I click the "text basics" link
    Then the page URL should contain "#text-basics"
