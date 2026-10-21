import { test as base, createBdd } from '@sdods/core/fixtures';
import { PreviewPage } from '../pages/PreviewPage.js';

/**
 * Project-level test object: the SDODS merged fixtures plus MarkupMe's page objects.
 * MarkupMe has no sign-in, so there is no auth strategy. playwright-bdd imports this file.
 */
export const test = base.extend<{ previewPage: PreviewPage }>({
  previewPage: async ({ pages }, use) => {
    await use(pages.get(PreviewPage));
  },
});

export const { Given, When, Then, Step, BeforeScenario, AfterScenario, BeforeStep, AfterStep, BeforeWorker, AfterWorker } =
  createBdd(test);
