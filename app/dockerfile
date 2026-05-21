# ==========================================
# Stage 1: Build & Dependency Compilation
# ==========================================
FROM python:3.11-slim AS builder

WORKDIR /build

# Install system dependencies needed for compiling wheels (if any)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and compile Python dependencies into a local directory
COPY app/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ==========================================
# Stage 2: Final Secure Runtime Environment
# ==========================================
FROM python:3.11-slim AS runner

WORKDIR /app

# Create a dedicated, non-privileged system user and group
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /bin/false -m appuser

# Copy installed Python packages from the builder stage
COPY --from=builder /root/.local /home/appuser/.local
# Copy application source code
COPY app/ /app/

# Enforce ownership of the application files to the secure user
RUN chown -R appuser:appgroup /app

# Switch the runtime context to the non-root user
USER 10001

# Update environment PATH to include the user-level package binaries
ENV PATH=/home/appuser/.local/bin:$PATH
EXPOSE 8080

# Configure a health check to monitor container health safely
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["python", "main.py"]
