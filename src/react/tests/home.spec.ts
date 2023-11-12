import { test, expect } from '@playwright/test';

test.describe('Home page', () => {
  
  test('has title', async ({ page }) => {
    await page.goto('/');

    await expect(page).toHaveTitle(/Template App/);
  });

})
