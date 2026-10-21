@api @render
Feature: Render API
  # GOAL: POST /api/render turns Markdown into safe HTML (and md, ast, text) with every
  #       advanced feature MarkupMe claims: GFM, footnotes, alerts, directives, TOC, diagrams.
  # ROLE: anonymous API caller.  ENVS: local.  EVIDENCE: response JSON.

  Background:
    Given I use no authentication

  @smoke
  Scenario: GitHub Flavored Markdown renders tables, task lists and strikethrough
    When I send a POST request to "/api/render" with body:
      """
      { "markdown": "# Report\n\n| Feature | Status |\n| --- | --- |\n| GFM | on |\n\n- [x] done\n- [ ] todo\n\n~~old~~" }
      """
    Then the response status should be 200
    And the response JSON path "format" should equal "html"
    And the response JSON path "title" should equal "Report"
    And the response JSON path "output" should match "<table><thead><tr><th>Feature</th>"
    And the response JSON path "output" should match "<input type=\"checkbox\" checked disabled>"
    And the response JSON path "output" should match "<del>old</del>"
    And the response JSON path "stats.tasks.total" should equal "2"

  @smoke
  Scenario: Footnotes, alerts, directives and heading ids render
    When I send a POST request to "/api/render" with body:
      """
      { "markdown": "## Setup Guide\n\nText[^n].\n\n> [!WARNING]\n> Careful.\n\n:::tip[Pro tip]\nUse it.\n:::\n\nPress :kbd[Ctrl]\n\n[^n]: A note." }
      """
    Then the response status should be 200
    And the response JSON path "output" should match "<h2 id=\"setup-guide\">"
    And the response JSON path "output" should match "class=\"markdown-alert markdown-alert-warning\""
    And the response JSON path "output" should match "<p class=\"mm-callout-title\">Pro tip</p>"
    And the response JSON path "output" should match "<kbd>Ctrl</kbd>"
    And the response JSON path "output" should match "href=\"#fn-n\""
    And the response JSON path "output" should match "id=\"fn-n\""

  @smoke
  Scenario: A table of contents is generated on request
    When I send a POST request to "/api/render" with body:
      """
      { "markdown": "# Doc\n\n## One\n\n### Sub\n\n## Two", "toc": true }
      """
    Then the response status should be 200
    And the response JSON path "output" should match "<nav class=\"mm-toc\" aria-label=\"Table of contents\">"
    And the response JSON path "output" should match "<a href=\"#sub\">Sub</a>"

  @smoke @diagrams
  Scenario: Graphviz, Blueprint and Mermaid diagrams render
    When I send a POST request to "/api/render" with body:
      """
      { "markdown": "```dot\ndigraph G { write -> render }\n```\n\n```ybp\nflowchart \"Flow\"\napi: API [service]\ndb: DB [database]\napi -> db\n```\n\n```mermaid\nflowchart LR\n  A --> B\n```" }
      """
    Then the response status should be 200
    And the response JSON path "output" should match "<figure class=\"mm-diagram mm-diagram-graphviz\"[^>]*><svg"
    And the response JSON path "output" should match "<figure class=\"mm-diagram mm-diagram-blueprint\"[^>]*><svg"
    And the response JSON path "output" should match "<pre class=\"mermaid\">flowchart LR"
    And the response JSON path "diagnostics" should have 0 items

  @smoke @diagrams
  Scenario: A broken diagram is reported, not crashed on
    When I send a POST request to "/api/render" with body:
      """
      { "markdown": "# T\n\n```dot\ndigraph { a -> \n```" }
      """
    Then the response status should be 200
    And the response JSON path "output" should match "class=\"mm-diagram-error\" role=\"alert\""
    And the response JSON path "diagnostics[0].code" should equal "MM040"
    And the response JSON path "diagnostics[0].severity" should equal "error"

  @smoke @security
  Scenario: Untrusted HTML is sanitized even when the caller asks otherwise
    When I send a POST request to "/api/render" with body:
      """
      { "markdown": "<script>alert(1)</script>\n\n<img src=x onerror=\"alert(1)\" alt=\"x\">\n\n[click](javascript:alert(1))\n\n<iframe src=\"https://example.com\"></iframe>", "sanitize": false }
      """
    Then the response status should be 200
    And the response should not contain any of "<script,onerror,javascript:,<iframe"

  @regression
  # title-format: Render as <format>
  Scenario Outline: Other output formats: <format>
    When I send a POST request to "/api/render" with body:
      """
      { "markdown": "# Title\n\n*one* and **two**", "format": "<format>" }
      """
    Then the response status should be 200
    And the response JSON path "format" should equal "<expected>"
    And the response JSON path "output" should match "<pattern>"

    Examples:
      | format   | expected | pattern                 |
      | markdown | markdown | ^# Title\n\n_one_ and   |
      | text     | text     | ^Title\n\none and two   |
      | ast      | ast      | .schemaVersion.: 1      |

  @regression @negative
  Scenario: A body without markdown is rejected
    When I send a POST request to "/api/render" with body:
      """
      { "text": "wrong field" }
      """
    Then the response status should be 400
    And the response JSON path "error.code" should equal "MARKDOWN_REQUIRED"

  @regression @negative
  Scenario: Planned formats answer 501 instead of pretending
    When I send a POST request to "/api/render" with body:
      """
      { "markdown": "# x", "format": "pdf" }
      """
    Then the response status should be 501
    And the response JSON path "error.code" should equal "UNSUPPORTED"

  @regression @negative
  Scenario: GET on a POST route is refused
    When I send a GET request to "/api/render"
    Then the response status should be 405
    And the response header "allow" should contain "POST"
