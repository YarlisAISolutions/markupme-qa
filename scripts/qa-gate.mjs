#!/usr/bin/env node
/**
 * The QA gate. CI calls this, not `sdods run` directly.
 *
 * Two facts about the runner make this script necessary rather than decorative:
 *
 *  1. The `gates:` block in sdods.project.yaml is declared intent. Nothing reads
 *     it at run time, and the runner's exit code ignores it. If CI trusts that
 *     exit code, a suite can degrade indefinitely without turning a check red.
 *
 *  2. A run that matches no scenarios WARNS and exits 0. A single typo in a tag
 *     expression therefore produces a green check over zero tests — the most
 *     dangerous failure mode a test suite has, because it looks like success.
 *
 * So: an empty run is a failure here, and the thresholds are enforced here.
 */
import { readFileSync, readdirSync, existsSync } from 'node:fs'
import { join } from 'node:path'
import { parseArgs } from 'node:util'

const { values } = parseArgs({
  options: {
    run: { type: 'string' },
    suite: { type: 'string' },
    'min-scenarios': { type: 'string' },
    'runs-dir': { type: 'string', default: '.sdods/runs' },
  },
})

const runsDir = values['runs-dir']

function latestRunId() {
  if (!existsSync(runsDir)) return null
  const entries = readdirSync(runsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .sort()
  return entries.at(-1) ?? null
}

const runId = values.run ?? latestRunId()

if (!runId) {
  fail(
    'No run found.',
    `Looked in ${runsDir}. The suite did not run at all — which is not the same as passing.`
  )
}

const summaryPath = join(runsDir, runId, 'summary.json')

if (!existsSync(summaryPath)) {
  fail(`Run ${runId} has no summary.json.`, 'The run did not complete; treat it as a failure.')
}

const summary = JSON.parse(readFileSync(summaryPath, 'utf8'))
const totals = summary.totals ?? {}
const { total = 0, passed = 0, failed = 0, skipped = 0, flaky = 0 } = totals

const problems = []

// The empty-run trap. This check must come first: every ratio below is
// meaningless — or flatteringly perfect — when the denominator is zero.
if (total === 0) {
  problems.push(
    'The run matched zero scenarios. A tag expression is probably wrong. ' +
      'An empty run is a failure, not a pass.'
  )
}

const minScenarios = values['min-scenarios'] ? Number(values['min-scenarios']) : null
if (minScenarios !== null && total < minScenarios) {
  problems.push(
    `Only ${total} scenarios ran; this tier requires at least ${minScenarios}. ` +
      'Coverage shrank, or the selection is narrower than intended.'
  )
}

if (failed > 0) problems.push(`${failed} scenario(s) failed.`)
if (flaky > 0) problems.push(`${flaky} scenario(s) were flaky. A retry that passes is still a defect.`)

report()

function report() {
  const label = values.suite ? `${values.suite} ` : ''
  console.log(
    `\nqa-gate — ${label}run ${runId}\n` +
      `  total ${total}  passed ${passed}  failed ${failed}  skipped ${skipped}  flaky ${flaky}`
  )

  if (problems.length === 0) {
    console.log('\n  gate passed\n')
    process.exit(0)
  }

  console.error('\n  gate FAILED:')
  for (const problem of problems) console.error(`    - ${problem}`)
  console.error('')
  process.exit(1)
}

function fail(headline, detail) {
  console.error(`\nqa-gate — ${headline}\n  ${detail}\n`)
  process.exit(1)
}
