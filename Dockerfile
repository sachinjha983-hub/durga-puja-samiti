FROM node:20-alpine
WORKDIR /app/server
COPY server/package*.json ./
RUN npm install --omit=dev
COPY server/ ./
COPY web/ /app/web/
ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "start"]
