# Durga Puja Samiti Management App

Responsive Bengali/English dashboard for committee donations, expenses, budget planning, fund balance, search, summary reports, real Excel workbooks, and browser print/PDF. The Railway deployment runs the Node API and web UI together on one same-origin service, with PostgreSQL as a separate Railway database.

## Roles

- **Admin:** create Admin/User accounts, record donations and expenses, add budgets, delete erroneous transactions, view reports, and export Excel.
- **User:** read-only access to dashboard, fund totals, transaction search, reports, and Excel export. The API enforces this; hiding buttons in the UI is not the only protection.

The first Admin is created at `/` after the app initializes its database schema. The setup form requires the one-time `FIRST_ADMIN_SETUP_KEY`; the endpoint closes after the first account. Passwords are bcrypt hashed. JWT tokens expire after 12 hours and are kept in browser memory (reloading requires signing in again).

## Local run with Docker Compose

1. Install Docker Desktop/Engine with Compose.
2. Copy `.env.example` to `.env`. Replace `POSTGRES_PASSWORD`, `JWT_SECRET`, and `FIRST_ADMIN_SETUP_KEY` with separate random hex values. Example PowerShell command to generate each: `[Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))`. Keep `.env` out of Git.
3. Run `docker compose up --build` from the project root.
4. Open `http://localhost:8080` and create the initial Admin using the `FIRST_ADMIN_SETUP_KEY` from `.env`.
5. Add user accounts in the Admin-only Users tab.

The local Compose setup runs PostgreSQL 16, the API, and Nginx. The API also serves the web files itself so Railway can deploy a single web/API service. Both paths use the same `/api` URLs.

To run the Node service directly, install Node.js 20+ and run `cd server; npm install; npm start` after setting `DATABASE_URL` to a PostgreSQL database URL, `JWT_SECRET`, and `FIRST_ADMIN_SETUP_KEY` (at least 32 characters while the database is empty). The server applies the idempotent initial schema from `server/schema.sql` before opening its port.

## Exact Railway deployment steps

1. Extract this project, commit the project root to a GitHub repository, and push it. The repository root contains `Dockerfile`, `package.json`, `schema.sql`, `server.js`, `server/`, and `web/`; keep the Railway service Root Directory at `/` (blank/default).
2. In Railway, create a project and choose **Deploy from GitHub repo**. Select the repository. Railway uses the root `Dockerfile`; its COPY sources are resolved from the repository root and it bundles the Node API and `web/` into that service.
3. In the project canvas, choose **+ New → Database → PostgreSQL**. Wait for PostgreSQL deployment to finish.
4. Open the app service's **Variables** tab and add:

   ```text
   NODE_ENV=production
   JWT_SECRET=<a unique random value of at least 32 characters>
   FIRST_ADMIN_SETUP_KEY=<a different random value of at least 32 characters>
   DATABASE_URL=${{Postgres.DATABASE_URL}}
   ```

   Replace `Postgres` with the actual database service name if you named it differently. Prefer Railway's **Add Reference Variable** selector so the app follows any later database credential changes. Do not set a literal database password in source control. Railway supplies `PORT`; do not hardcode it. Leave `WEB_ORIGIN` unset because the UI and API share one origin. Leave `PGSSL` unset/false unless your selected connection endpoint requires TLS; if enabling it, this app validates the server certificate.

5. Redeploy the app service after saving variables. `railway.toml` selects the root Dockerfile and checks `/api/health`. The app applies `server/schema.sql` on startup. Confirm the deployment logs say `API and web app ready` and the health check succeeds.
6. Open app service **Settings → Networking → Generate Domain**. Visit the generated HTTPS domain; the page should show Admin/User login or first-Admin setup.
7. Create the first Admin on the setup screen with `FIRST_ADMIN_SETUP_KEY`, sign in, then remove that variable from the app service and redeploy. Setup remains permanently closed after the first account. Create User accounts from **Users**. Run a small test donation, test expense, budget, report, and Excel download before entering genuine committee data.
8. Set up and periodically verify PostgreSQL backups in Railway. This app does not create or verify backups for you. Keep a separate record of the generated `JWT_SECRET`; rotating it invalidates existing sessions/tokens.

The root Dockerfile intentionally copies the root `package.json`, `schema.sql`, and `server.js`, then copies the preserved `server/` and `web/` trees. Do not set Root Directory to `/server`; that changes the Docker build context and makes these root-relative COPY sources unavailable. Railway dashboard labels can change; the service reference syntax and PostgreSQL connection variables above follow Railway's current documentation. The PostgreSQL service should remain private; only the app service needs a public domain.

## Checks performed on the supplied project

The project was run locally against a disposable PostgreSQL-compatible PGlite test server through the standard PostgreSQL wire protocol. Checks covered first-Admin setup/lockout, Admin login and account creation, User login/read access, User denials on transaction/budget/delete writes, donation/expense/fund arithmetic, budget totals, date-filtered reports, text/type search, amount validation, Admin deletion balance recalculation, unauthenticated export denial, and a valid XLSX workbook response. Browser checks at a 390 px mobile viewport covered Admin navigation, entry and report views, User read-only navigation, no horizontal overflow, and a real Excel download.

The in-memory PGlite instance is not a substitute for deployment smoke testing on Railway's managed PostgreSQL. No Railway account or project was connected, so no live Railway deployment was made.

See [VERIFICATION.md](VERIFICATION.md) for the individual checks and the items not run.

## Known limitations

- Reports summarize matching transactions, while budgets are shown as a separate aggregate; no monthly/category budget-versus-actual report is generated.
- Search UI displays at most 1,000 newest matching records; Excel exports every matching record.
- PDF is generated with the browser Print → Save as PDF flow, not a server-side PDF service.
- There is no password reset, MFA, invite flow, user edit/deactivate screen, or audit history for deletions.
- Initial database creation is idempotent, but there is no versioned migration framework or built-in backup/restore process.
- Rate limiting is in process memory; for a multi-replica service, use a shared rate-limit store.
- The browser keeps JWT only in memory, so reloads require sign-in again. Expired or stolen tokens remain valid until their 12-hour expiration unless the signing secret is rotated.
