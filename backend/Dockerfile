# ── Stage 1: Build ──
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build

# ── Stage 2: Runtime ──
FROM node:20-alpine
WORKDIR /app

# Non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Only production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy compiled files and migration assets
COPY --from=builder /app/dist ./dist
COPY migrations/ ./migrations/
COPY scripts/ ./scripts/

USER appuser
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:3000/api/health || exit 1

# Run migrations then start server
CMD ["npm", "run", "start:migrate"]
