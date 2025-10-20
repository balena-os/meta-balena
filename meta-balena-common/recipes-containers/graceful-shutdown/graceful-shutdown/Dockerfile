FROM alpine:latest

# Install the signal-test binary
COPY signal-test /usr/bin/signal-test
RUN chmod +x /usr/bin/signal-test

# Run the signal test program
CMD ["/usr/bin/signal-test"]

