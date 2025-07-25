# Coolify Deployment Guide for firegeo-coolify-deployment

This guide provides step-by-step instructions for deploying your application to a Coolify instance.

## Prerequisites

- A running Coolify instance.
- A GitHub account with access to the `ignitabull18/firegeo-coolify-deployment` repository.

## Deployment Steps

1.  **Log in to your Coolify instance.**

2.  **Create a New Application:**
    - Navigate to the "Applications" section.
    - Click on "Create New Application."

3.  **Select Your Source:**
    - Choose "Git Repository" as the source.
    - Select the `ignitabull18/firegeo-coolify-deployment` repository from your GitHub account. If it's not listed, you may need to grant Coolify access to it.

4.  **Configure Build Settings:**
    - **Build Pack:** Coolify should automatically detect the `Dockerfile`. If not, manually select the `Dockerfile` build pack.
    - **Dockerfile Location:** Ensure the path is set to `./Dockerfile` (the root of the repository).

5.  **Configure Network Settings:**
    - In the "Network" tab, you need to expose the port that the application runs on.
    - The `Dockerfile` exposes port `3000`. Set the "Exposed Port" to `3000`. Coolify will handle mapping this to a public-facing port.

6.  **Configure Environment Variables:**
    - Go to the "Environment Variables" tab.
    - Add all the necessary environment variables for your application. This includes database connection strings, API keys, and any other secrets required for your application to run.
    - **Important:** Make sure to check the "Available during build time?" option for each variable, as the `next build` process requires them.
    - **Important:** Do not commit your `.env` file to the repository. All secrets should be managed through the Coolify UI.

    ### Required Environment Variables
    - `DATABASE_URL`: Your PostgreSQL connection string.
    - `BETTER_AUTH_SECRET`: A secret key for Better Auth. You can generate one with `openssl rand -hex 32`.
    - `NEXT_PUBLIC_APP_URL`: The public URL of your application (e.g., `https://firegeo.yourdomain.com`).
    - `AUTUMN_SECRET_KEY`: Your Autumn secret key.
    - `FIRECRAWL_API_KEY`: Your Firecrawl API key for web scraping.

    ### Optional Environment Variables
    - `STRIPE_SECRET_KEY`
    - `STRIPE_PUBLISHABLE_KEY`
    - `STRIPE_WEBHOOK_SECRET`
    - `RESEND_API_KEY`
    - `OPENAI_API_KEY`
    - `ANTHROPIC_API_KEY`
    - `GOOGLE_GENERATIVE_AI_API_KEY`
    - `PERPLEXITY_API_KEY`

7.  **Deploy:**
    - Once you have configured the build, network, and environment variables, click the "Deploy" button.
    - Coolify will start the deployment process, which includes:
        - Cloning the repository.
        - Building the Docker image from the `Dockerfile`.
        - Starting a container from the built image.
        - Making the application available at a generated URL (or your custom domain if you configure one).

8.  **Monitor and Troubleshoot:**
    - You can monitor the deployment logs in real-time from the Coolify dashboard.
    - If the deployment fails, the logs will provide detailed information to help you identify and resolve the issue.

By following these steps, you will have your application running on Coolify. 