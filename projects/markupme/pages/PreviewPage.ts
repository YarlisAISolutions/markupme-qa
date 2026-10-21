import { expect } from '@playwright/test';
import { BasePage } from '@sdods/core/pages';
import { Fixture, Then } from 'playwright-bdd/decorators';
import type { test } from '../steps/fixtures.js';

/**
 * Rendered MarkupMe output in a page (served pages and the playground preview).
 * GAP: core steps check text and visibility, not that a diagram finished turning into SVG,
 * so these steps wait for the rendered <svg> inside MarkupMe's diagram figures.
 */
@Fixture<typeof test>('previewPage')
export class PreviewPage extends BasePage {
  readonly article = this.heal.locator(this.page.locator('article.markupme').first(), {
    role: 'article',
    description: 'rendered Markdown article',
  });

  @Then('the page should show a rendered {string} diagram')
  async diagramRendered(provider: string) {
    const figure = this.page.locator(`figure.mm-diagram-${provider}`).first();
    await expect(figure, `a ${provider} diagram figure`).toBeVisible();
    await expect(figure.locator('svg').first(), `${provider} diagram SVG`).toBeVisible();
  }

  @Then('the Mermaid diagram should finish rendering')
  async mermaidRendered() {
    const block = this.page.locator('pre.mermaid').first();
    await expect(block, 'Mermaid block processed by the runtime').toHaveAttribute('data-processed', 'true', {
      timeout: 15_000,
    });
    await expect(block.locator('svg').first(), 'Mermaid SVG').toBeVisible();
  }

  @Then('searching the site for {string} should list {string}')
  async siteSearch(query: string, title: string) {
    await this.page.getByRole('searchbox', { name: 'Search pages' }).fill(query);
    const results = this.page.getByRole('search').getByRole('link', { name: title, exact: true });
    await expect(results, `search results for "${query}"`).toBeVisible();
  }

  @Then('the table of contents should link to {string}')
  async tocLinks(name: string) {
    const toc = this.page.getByRole('navigation', { name: 'Table of contents' });
    await expect(toc).toBeVisible();
    await expect(toc.getByRole('link', { name, exact: true })).toBeVisible();
  }
}
