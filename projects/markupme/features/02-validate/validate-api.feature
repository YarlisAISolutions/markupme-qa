@api @validate
Feature: Validate and stats API
  # GOAL: POST /api/validate finds the problems `markupme validate` finds, with stable codes
  #       and line numbers; POST /api/stats counts the document.
  # ROLE: anonymous API caller.  ENVS: local.

  Background:
    Given I use no authentication

  @smoke
  Scenario: Broken links, skipped headings and missing alt text are reported
    When I send a POST request to "/api/validate" with body:
      """
      { "markdown": "# Title\n\n#### Too deep\n\n![](diagram.png)\n\nSee [missing](#nowhere)." }
      """
    Then the response status should be 200
    And the response JSON path "ok" should equal "false"
    And the response JSON path "errors" should equal "1"
    And the response JSON path "$.diagnostics[?(@.code=='MM004')].line" should equal "7"
    And the response JSON path "$.diagnostics[?(@.code=='MM001')].rule" should equal "heading-increment"
    And the response JSON path "$.diagnostics[?(@.code=='MM005')].severity" should equal "warning"

  @smoke
  Scenario: A clean document passes
    When I send a POST request to "/api/validate" with body:
      """
      { "markdown": "# Title\n\n## Section\n\nLink to [the section](#section)." }
      """
    Then the response status should be 200
    And the response JSON path "ok" should equal "true"
    And the response JSON path "diagnostics" should have 0 items

  @regression
  Scenario: Stats count words, headings, tasks and code languages
    When I send a POST request to "/api/stats" with body:
      """
      { "markdown": "# Two words\n\n- [x] a\n- [ ] b\n\n```ts\nconst x = 1\n```" }
      """
    Then the response status should be 200
    And the response JSON path "headings" should equal "1"
    And the response JSON path "tasks.done" should equal "1"
    And the response JSON path "languages.ts" should equal "1"
