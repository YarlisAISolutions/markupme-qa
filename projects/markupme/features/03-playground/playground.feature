@ui @playground
Feature: Playground
  # GOAL: a writer types Markdown and sees the rendered preview, diagrams and diagnostics live.
  # ROLE: anonymous visitor.  ENVS: local.  EVIDENCE: screenshots per scenario.

  Background:
    Given I navigate to the "playground" page

  @smoke
  Scenario: The playground loads with a rendered sample
    Then the page title should contain "MarkupMe playground"
    And the "MarkupMe playground" heading should be visible
    And the element with test id "preview" should contain "Try MarkupMe"
    And the element with test id "status" should contain "Rendered"
    And the Mermaid diagram should finish rendering

  @smoke
  Scenario: Typing updates the preview
    When I fill the "Markdown" field with "## Written by SDODS"
    Then the element with test id "preview" should contain "Written by SDODS"
    And the "Written by SDODS" heading should be visible

  @smoke
  Scenario: Problems show up as diagnostics
    When I fill the "Markdown" field with "See [nothing](#missing-anchor)"
    Then the element with test id "diagnostics" should contain "MM004"
    And the element with test id "diagnostics" should contain "#missing-anchor"

  @smoke @a11y
  Scenario: The playground is accessible
    Then the page should have exactly one level-1 heading
    And the heading levels should not skip a level
    And the page should have no accessibility violations of impact "serious" or worse

  @regression @dark
  Scenario: The theme toggle switches to dark mode
    When I click the "Toggle dark mode" button
    Then the painted page background should be dark
