# =============================================================================
# Dockerfile — Infracore Landing Page
# -----------------------------------------------------------------------------
# Builds a lightweight nginx container serving the Infracore marketing site.
# A small version bar is injected at build time so the running container
# can be traced back to an exact release, build time, and git commit —
# This is what the CI/CD pipeline displays after every deployment.
# Builds a lightweight nginx container that serves a single HTML page
# displaying build metadata: version, build date, and git commit SHA.
#
# The image is built by the CI/CD pipeline on every release and pushed to
# the private local registry at 192.168.200.115:5000.
#
# Build args are injected by the pipeline:
#   docker build \
#     --build-arg VERSION=1.2.3 \
#     --build-arg BUILD_DATE=2026-06-06T11:00:00Z \
#     --build-arg GIT_SHA=abc1234... \
#     -t 192.168.200.115:5000/mynginx:1.2.3 .
#
# To build and test locally:
#   docker build -t infracore:local .
#   docker run -p 8080:80 infracore:local
#   open http://localhost:8080
# =============================================================================

FROM nginx:alpine

# -----------------------------------------------------------------------------
# Build arguments — injected by the CI/CD pipeline at build time
# -----------------------------------------------------------------------------
ARG VERSION=dev
ARG BUILD_DATE
ARG GIT_SHA

# -----------------------------------------------------------------------------
# Copy the real site into the nginx document root
# -----------------------------------------------------------------------------
COPY site/index.html /usr/share/nginx/html/index.html

# -----------------------------------------------------------------------------
# Substitute the placeholder tokens in the HTML with real build values
# -----------------------------------------------------------------------------
# The index.html ships with three placeholder tokens in the version bar:
#   __VERSION__, __BUILD_DATE__, __GIT_SHA__
# sed replaces them in-place during the image build so the final HTML
# served by nginx always shows accurate release information.
# -----------------------------------------------------------------------------
RUN sed -i \
    -e "s|__VERSION__|${VERSION}|g" \
    -e "s|__BUILD_DATE__|${BUILD_DATE}|g" \
    -e "s|__GIT_SHA__|${GIT_SHA}|g" \
    /usr/share/nginx/html/index.html

EXPOSE 80
