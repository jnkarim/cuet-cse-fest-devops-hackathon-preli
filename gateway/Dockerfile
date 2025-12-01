FROM node:18-alpine AS production


RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./


RUN npm ci --omit=dev && npm cache clean --force


COPY . .

RUN chown -R appuser:appgroup /app

USER appuser


EXPOSE 5921

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:5921/api/health || exit 1

CMD ["node", "src/gateway.js"]