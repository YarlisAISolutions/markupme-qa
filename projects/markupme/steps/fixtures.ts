import { test as base, createBdd } from '@sdods/core/fixtures';
import { PreviewPage } from '../pages/PreviewPage.js';
import { StudioPage } from '../pages/StudioPage.js';

/**
 * Project-level test object: the SDODS merged fixtures plus MarkupMe's page objects.
 * MarkupMe has no sign-in, so there is no auth strategy. playwright-bdd imports this file.
 */
export const test = base.extend<{ previewPage: PreviewPage; studioPage: StudioPage }>({
  previewPage: async ({ pages }, use) => {
    await use(pages.get(PreviewPage));
  },
  studioPage: async ({ pages }, use) => {
    await use(pages.get(StudioPage));
  },
});

export const { Given, When, Then, Step, BeforeScenario, AfterScenario, BeforeStep, AfterStep, BeforeWorker, AfterWorker } =
  createBdd(test);
