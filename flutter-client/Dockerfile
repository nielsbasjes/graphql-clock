FROM busybox:1.36

# Create a non-root user for Flutter
RUN adduser -D flutter
USER flutter
WORKDIR /home/flutter

# Copy the Flutter generated website
COPY build/web .

# Run BusyBox httpd on 8080
CMD ["busybox", "httpd", "-f", "-p", "8080"]
