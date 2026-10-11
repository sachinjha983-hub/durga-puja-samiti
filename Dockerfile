FROM node:20-alpine

WORKDIR /app

# Keep the repository root as Railway's build context.
COPY package.json ./package.json
RUN npm install --omit=dev --no-audit --no-fund

# Root files are copied directly; the full original source folders are retained.
COPY schema.sql ./schema.sql
COPY server.js ./server.js
COPY server/ ./server/
COPY web/ ./web/

ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "start"]
