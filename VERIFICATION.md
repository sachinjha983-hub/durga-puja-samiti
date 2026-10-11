# Verification record

Date: 2026-10-11

## Passed

- Node syntax checks: `server/server.js`, `web/app.js`, `web/config.js`; JSON parsing: `server/package.json`, `web/manifest.json`.
- Started the actual Express service and schema against a disposable PGlite instance speaking PostgreSQL's wire protocol.
- API: database health; keyed first-Admin setup and second-setup rejection; Admin login; donation/expense inserts; available-fund arithmetic; budget total; date-filtered report; text/type search; invalid amount precision; Admin user creation; User login/read dashboard; User transaction/budget/delete denials; unauthenticated Excel denial; Admin deletion recalculation.
- Excel: API returned a valid XLSX ZIP container; workbook parsed successfully with ExcelJS. The browser download control produced a workbook with the expected header row.
- Browser at a 390 px mobile viewport: keyed first-Admin setup form, Admin dashboard/navigation, entry and reports tabs; Bengali INR figures and ISO transaction date; User sees Dashboard/Reports only; no horizontal overflow.

## Not run

- Docker Compose was not run because Docker was not available in the environment.
- No live Railway project was created/deployed because no Railway account/project was connected. The deployed environment still needs a smoke check against Railway-managed PostgreSQL.
- The repo does not include an automated test suite; the checks above were executed manually during this review.
