# Dockerfile

# 1. Builder stage: Install all dependencies and build the application
FROM node:20-slim AS builder

WORKDIR /app
RUN npm install -g pnpm

# Copy dependency definition files
COPY package.json pnpm-lock.yaml ./

# Install all dependencies (including devDependencies)
RUN pnpm install

# Copy the rest of the application source code
COPY . .

# Build the application
RUN pnpm build


# 2. Production dependencies stage: Install only production dependencies
FROM node:20-slim AS prod-deps

WORKDIR /app
RUN npm install -g pnpm

# Copy dependency definition files
COPY package.json pnpm-lock.yaml ./

# Install only production dependencies
RUN pnpm install --prod


# 3. Runner stage: Create the final, minimal production image
FROM node:20-slim AS runner

WORKDIR /app

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy production node_modules from the prod-deps stage
COPY --from=prod-deps /app/node_modules ./node_modules
# Copy the standalone application from the builder stage
COPY --from=builder /app/.next/standalone ./
# Copy static assets from the builder stage
COPY --from=builder /app/.next/static ./.next/static
# Copy public assets from the builder stage
COPY --from=builder /app/public ./public
# Copy migration files
COPY --from=builder /app/migrations ./migrations
COPY --from=builder /app/better-auth_migrations ./better-auth_migrations

# Install PostgreSQL client for running migrations
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Create cache directory and set proper permissions
RUN mkdir -p /app/.next/cache && chown -R nextjs:nodejs /app

# Create a startup script that runs migrations
RUN echo '#!/bin/bash' > /app/start.sh && \
    echo 'echo "Running database migrations..."' >> /app/start.sh && \
    echo 'if [ -n "$DATABASE_URL" ]; then' >> /app/start.sh && \
    echo '  # Run Better Auth migrations' >> /app/start.sh && \
    echo '  if [ -f "./better-auth_migrations/initial-schema.sql" ]; then' >> /app/start.sh && \
    echo '    echo "Running Better Auth migrations..."' >> /app/start.sh && \
    echo '    psql "$DATABASE_URL" -f ./better-auth_migrations/initial-schema.sql 2>/dev/null || echo "Better Auth tables may already exist"' >> /app/start.sh && \
    echo '  fi' >> /app/start.sh && \
    echo '  # Run application migrations' >> /app/start.sh && \
    echo '  if [ -f "./migrations/001_create_app_schema.sql" ]; then' >> /app/start.sh && \
    echo '    echo "Running application migrations..."' >> /app/start.sh && \
    echo '    psql "$DATABASE_URL" -f ./migrations/001_create_app_schema.sql 2>/dev/null || echo "Application tables may already exist"' >> /app/start.sh && \
    echo '  fi' >> /app/start.sh && \
    echo 'else' >> /app/start.sh && \
    echo '  echo "DATABASE_URL not set, skipping migrations"' >> /app/start.sh && \
    echo 'fi' >> /app/start.sh && \
    echo 'echo "Starting application..."' >> /app/start.sh && \
    echo 'exec node server.js' >> /app/start.sh && \
    chmod +x /app/start.sh && chown nextjs:nodejs /app/start.sh

# Set correct permissions for the non-root user
USER nextjs

EXPOSE 3000
ENV HOSTNAME "0.0.0.0"
ENV PORT 3000

# Start the application with migrations
CMD ["/app/start.sh"] 