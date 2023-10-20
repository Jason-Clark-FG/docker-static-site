FROM alpine:3.18.4 AS builder

WORKDIR /busybox

# Download busybox sources
RUN wget https://www.busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox_HTTPD \
  && mv busybox_HTTPD busybox \
  && chmod +x busybox \
  && adduser -D static

# Switch to the scratch image
FROM scratch

EXPOSE 3000

# Copy over the user
COPY --from=builder /etc/passwd /etc/passwd

# Copy the busybox static binary
COPY --from=builder /busybox/busybox /

# Use our non-root user
USER static
WORKDIR /home/static

# Uploads a blank default httpd.conf
# This is only needed in order to set the `-c` argument in this base file
# and save the developer the need to override the CMD line in case they ever
# want to use a httpd.conf
COPY httpd.conf .

# Copy the static website
# Use the .dockerignore file to control what ends up inside the image!
# NOTE: Commented out since this will also copy the .config file
# COPY . .

# Run busybox httpd
CMD ["/busybox", "httpd", "-f", "-v", "-p", "3000", "-c", "httpd.conf"]
