# Dockerfile

# Builder stage
FROM node:20-slim AS builder

# Set working directory
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package.json and pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# Install dependencies with --prod flag for production
# This ensures only production dependencies are installed in the final image
RUN pnpm install --prod

# Copy the rest of the application
COPY . .

# Build the application
# The standalone output will be generated in the .next/standalone directory
RUN pnpm build

# Runner stage
FROM node:20-slim AS runner

# Set working directory
WORKDIR /app

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy the standalone output from the builder stage
COPY --from=builder /app/.next/standalone ./
# Copy the static assets
COPY --from=builder /app/.next/static ./.next/static
# Copy the public assets
COPY --from=builder /app/public ./public

# Set the correct permissions for the non-root user
USER nextjs

# Expose port 3000
EXPOSE 3000

# Set the HOSTNAME to allow connections from any IP
ENV HOSTNAME "0.0.0.0"

# Start the application
CMD ["node", "server.js"] 