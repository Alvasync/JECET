Title: UI: add city select (Jacareí + São José disabled) and improve price card

Description:
This PR introduces a small UI improvement and minor backend propagation to support a new `cidade` field in the pricing form.

What changed:
- templates/index.html
  - Added a new `Cidade` select to the pricing form with:
    - `Jacareí` (selectable)
    - `São José dos Campos — Em desenvolvimento` (disabled, shows as in development)
  - Replaced the previous simple result card with the modern `modern-price-result` card to improve readability and styling.

- app.py
  - Read `cidade` from form POST and use it as a parameter when rendering the template result
  - Included `cidade` in the JSON response from `/api/precificar`
  - Default `cidade` when rendering index is now `'Jacareí'` for GET responses

- tools/render_test.py
  - Updated test renderer to pass `cidade` while rendering the template offline for validation.

Why:
- Prepare the app to support additional cities. São José dos Campos is intentionally shown as disabled to inform users it is in development.
- Improve UX of the price result card so the estimated price is clearer and more attractive.

How to test locally:
1) Run the app in your venv:
   python app.py
2) Open http://127.0.0.1:5000
3) Go to the "Precificar" section and verify:
   - The new "Cidade" select appears
   - Jacareí is selectable; São José dos Campos is disabled and shows "Em desenvolvimento"
   - After calculation, the price card uses the new styling and shows the price correctly

Notes:
- This PR does not change pricing logic between cities. Later we can add per-city valuation parameters if needed.
- If you prefer the change applied directly to `main`, use the provided push script to push to `main`; otherwise create a PR and merge after review.
