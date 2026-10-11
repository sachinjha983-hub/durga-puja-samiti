FROM node:20-alpine

WORKDIR /app

# Railway builds from the repository root, so every source path is root-relative.
COPY server/package.json ./package.json
RUN npm install --omit=dev --no-audit --no-fund

COPY server/server.js ./server.js
COPY server/schema.sql ./schema.sql
COPY web/ ./web/

ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "start"]
