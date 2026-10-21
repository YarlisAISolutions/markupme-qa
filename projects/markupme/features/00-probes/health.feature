@api @smoke @probes
Feature: Preview server health
  # GOAL: the `markupme serve` process is up and reports who it is.
  # ROLE: anonymous API caller.  ENVS: local.  RISK: every other suite depends on this.

  Background:
    Given I use no authentication

  Scenario: Health reports ok with the product name and version
    When I send a GET request to "/api/health"
    Then the response status should be 200
    And the response JSON path "status" should equal "ok"
    And the response JSON path "name" should equal "markupme"
    And the response JSON path "version" should match "^\d+\.\d+\.\d+$"
    And the response header "x-content-type-options" should contain "nosniff"

  Scenario: Capabilities list built and planned features honestly
    When I send a GET request to "/api/capabilities"
    Then the response status should be 200
    And the response JSON path "$.capabilities[?(@.feature=='PDF')].status" should equal "planned"
    And the response JSON path "$.capabilities[?(@.feature=='Graphviz DOT (WebAssembly)')].status" should equal "built"
