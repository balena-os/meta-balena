FROM alpine:latest

# Install the signal-test binary
COPY signal-test /usr/bin/signal-test
RUN chmod +x /usr/bin/signal-test

# Environment variables for signal-test configuration
# SHUTDOWN_DELAY_SECONDS: Delay in seconds before exiting after signal (default: 0)
# VERBOSE_SHUTDOWN: Enable countdown logs during shutdown delay (default: 0)
ENV SHUTDOWN_DELAY_SECONDS=0
ENV VERBOSE_SHUTDOWN=0

# Run the signal test program
# Pass env vars as command-line arguments to signal-test
CMD /bin/sh -c "/usr/bin/signal-test ${SHUTDOWN_DELAY_SECONDS} ${VERBOSE_SHUTDOWN}"

