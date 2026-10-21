@ui @studio
Feature: MarkupMe Studio
  # GOAL: a writer edits Markdown in the browser and sees a live, safe preview with diagrams,
  #       an outline and problems, switches views, uses the command palette and exports.
  # ROLE: anonymous visitor.  ENVS: local (CI copies apps/studio/dist to examples/studio).

  Background:
    Given I navigate to the "studio" page

  @smoke
  Scenario: The studio loads with the welcome document rendered
    Then the page title should contain "MarkupMe Studio"
    And the element with test id "preview" should contain "Welcome to MarkupMe Studio"
    And the element with test id "outline" should contain "Diagrams"
    And the page should show a rendered "graphviz" diagram
    And the page should show a rendered "blueprint" diagram
    And the Mermaid diagram should finish rendering

  @smoke
  Scenario: Editing updates the preview, outline and word count
    When I set the studio document to:
      """
      ## Release notes

      ### Fixed

      Written by **SDODS** with a [link](#fixed).
      """
    Then the element with test id "preview" should contain "Written by SDODS"
    And the "Release notes" heading should be visible
    And the element with test id "outline" should contain "Fixed"
    And the element with test id "word-count" should contain "words"

  @smoke
  Scenario: Problems are listed with their rule codes
    When I set the studio document to:
      """
      ## Draft

      See [nothing](#missing-anchor).
      """
    Then the element with test id "diagnostics" should contain "MM004"
    And the element with test id "diagnostics-count" should contain "1"

  @smoke
  Scenario: Untrusted HTML in the document is sanitized in the preview
    When I set the studio document to:
      """
      ## Safe

      <img src="x" onerror="document.title='pwned'" alt="probe">
      """
    Then the element with test id "preview" should contain "Safe"
    And the page title should contain "MarkupMe Studio"

  @smoke
  Scenario: View modes switch between source and preview
    When I click the element with test id "mode-preview"
    Then the element with test id "editor" should not be visible
    And the element with test id "preview" should be visible
    When I click the element with test id "mode-source"
    Then the element with test id "preview" should not be visible
    And the element with test id "editor" should be visible

  @smoke
  Scenario: The command palette opens from the keyboard and closes with Escape
    When I open the studio command palette
    And I fill the element with test id "command-input" with "export"
    Then the element with test id "command-palette" should contain "Export"
    When I press "Escape"
    Then the element with test id "command-palette" should not be visible

  @smoke @a11y
  Scenario: The studio is accessible
    Then the page should have exactly one level-1 heading
    And the heading levels should not skip a level
    And the page should have no accessibility violations of impact "serious" or worse

  @regression @dark
  Scenario: The theme toggle switches to dark mode
    When I click the element with test id "theme-toggle"
    Then the painted page background should be dark

  @regression
  Scenario: The document exports as Markdown
    When I set the studio document to:
      """
      ## Exported
      """
    And I click the element with test id "export-menu"
    And I click the element with test id "export-markdown" and capture the download
    Then the downloaded file name should contain ".md"
    And the downloaded text should contain "## Exported"
