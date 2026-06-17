# =============================================================================
# Dockerfile — My Nginx App
# -----------------------------------------------------------------------------
# Builds a lightweight nginx container that serves a single HTML page
# displaying build metadata: version, build date, and git commit SHA.
#
# The image is built by the CI/CD pipeline on every release and pushed to
# the private local registry at 192.168.178.115:5000.
#
# Build args are injected by the pipeline:
#   docker build \
#     --build-arg VERSION=1.2.3 \
#     --build-arg BUILD_DATE=2026-06-05T11:00:00Z \
#     --build-arg GIT_SHA=abc1234... \
#     -t 192.168.178.115:5000/mynginx:1.2.3 .
#
# To build and test locally:
#   docker build -t mynginx:local .
#   docker run -p 8080:80 mynginx:local
#   open http://localhost:8080
# =============================================================================

# -----------------------------------------------------------------------------
# Base image
# -----------------------------------------------------------------------------
# nginx:alpine uses the official nginx image built on Alpine Linux.
# Alpine is chosen for its minimal size (~25MB vs ~140MB for debian-based),
# reducing attack surface and speeding up pulls across cluster nodes.
# -----------------------------------------------------------------------------
FROM nginx:alpine

# -----------------------------------------------------------------------------
# Build arguments
# -----------------------------------------------------------------------------
# ARGs are variables passed in at build time via --build-arg flags.
# They are NOT available at container runtime (use ENV for that).
# Each has a default value used when building locally without the pipeline.
#
# VERSION    — semver release tag (e.g. 1.2.3), set by semantic-release
# BUILD_DATE — ISO 8601 timestamp of when the image was built
# GIT_SHA    — full git commit SHA for traceability back to the source code
# -----------------------------------------------------------------------------
ARG VERSION=dev        # Default 'dev' used for local builds outside the pipeline
ARG BUILD_DATE         # No default — will show empty if built without --build-arg
ARG GIT_SHA            # No default — will show empty if built without --build-arg

# -----------------------------------------------------------------------------
# Build the HTML page
# -----------------------------------------------------------------------------
# Uses a single RUN command to generate the index.html file that nginx serves.
# The build args are interpolated here — this is the only place they are used.
#
# Why a single RUN command?
#   Each RUN instruction creates a new image layer. Combining into one
#   keeps the image small and the layer count low.
#
# The HTML table displays:
#   Version  — confirms which release is running
#   Built    — timestamp for debugging stale deployments
#   Commit   — links the running container back to an exact git commit
#   Status   — static operational message (extend this for health checks)
#
# Output is written to /usr/share/nginx/html/index.html which is the
# default document root served by nginx on port 80.
# -----------------------------------------------------------------------------
RUN echo "<html> \
  <head><title>My Nginx App</title></head> \
  <body> \
    <h1>My Nginx App v1.2</h1> \
    <table> \
      <tr><td><b>Version</b></td><td>${VERSION}</td></tr> \
      <tr><td><b>Built</b></td><td>${BUILD_DATE}</td></tr> \
      <tr><td><b>Commit</b></td><td>${GIT_SHA}</td></tr> \
      <tr><td><b>Status</b></td><td>All systems operational</td></tr> \
    </table> \
  </body> \
</html>" > /usr/share/nginx/html/index.html

# -----------------------------------------------------------------------------
# Expose port
# -----------------------------------------------------------------------------
# Documents that the container listens on port 80.
# EXPOSE does not publish the port — it is informational only.
# The actual port mapping is handled by Kubernetes (containerPort: 80)
# or by docker run -p 8080:80 when running locally.
# -----------------------------------------------------------------------------
EXPOSE 80
