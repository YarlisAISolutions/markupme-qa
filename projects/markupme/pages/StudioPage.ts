import { expect } from '@playwright/test';
import { BasePage } from '@sdods/core/pages';
import { Fixture, When } from 'playwright-bdd/decorators';
import type { test } from '../steps/fixtures.js';

/**
 * MarkupMe Studio (apps/studio, served at /studio/).
 * GAP: typing multi-line Markdown into CodeMirror with `fill` is not possible (it is a
 * contenteditable, not a field), so documents are set through the Studio's test hook
 * `window.markupmeStudio.setMarkdown`, which goes through the same update path as typing.
 */
@Fixture<typeof test>('studioPage')
export class StudioPage extends BasePage {
  readonly editor = this.heal.locator(this.page.getByTestId('editor'), {
    testId: 'editor',
    description: 'Markdown source editor',
  });

  @When('I set the studio document to:')
  async setDocument(markdown: string) {
    await expect(await this.editor.resolve()).toBeVisible();
    await this.page.waitForFunction(() => 'markupmeStudio' in window);
    await this.page.evaluate((text) => {
      (window as unknown as { markupmeStudio: { setMarkdown(t: string): void } }).markupmeStudio.setMarkdown(text);
    }, markdown);
  }

  @When('I open the studio command palette')
  async openPalette() {
    await this.editor.click();
    await this.page.keyboard.press('Control+k');
    await expect(this.page.getByTestId('command-palette')).toBeVisible();
  }
}
