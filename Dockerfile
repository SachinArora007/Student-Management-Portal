# ─────────────────────────────────────────────
#  Student Management System — Docker Image
#  Base: nginx:alpine (tiny ~25 MB footprint)
# ─────────────────────────────────────────────

# 1. Use the official lightweight Nginx image
FROM nginx:alpine

# 2. Set a label for image metadata
LABEL maintainer="Your Name <you@example.com>" \
      description="Student Management System served via Nginx" \
      version="1.0"

# 3. Remove the default Nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# 4. Copy our HTML file into Nginx's web root
COPY first.html /usr/share/nginx/html/index.html

# 5. Expose port 80 (HTTP)
EXPOSE 80

# 6. Start Nginx in the foreground (required for Docker)
CMD ["nginx", "-g", "daemon off;"]
