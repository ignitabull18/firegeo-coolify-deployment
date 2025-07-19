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

# Set correct permissions for the non-root user
USER nextjs

EXPOSE 3000
ENV HOSTNAME "0.0.0.0"
ENV PORT 3000

# Start the application
CMD ["node", "server.js"] 