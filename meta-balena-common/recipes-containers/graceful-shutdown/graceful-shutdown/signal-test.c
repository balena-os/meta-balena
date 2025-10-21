#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <time.h>
#include <string.h>

volatile sig_atomic_t should_exit = 0;
int shutdown_delay = 0;  // Delay in seconds before exiting after signal
int verbose_shutdown = 0;  // Print countdown logs during shutdown delay

void get_timestamp(char *buffer, size_t size) {
    time_t now = time(NULL);
    struct tm *tm_info = localtime(&now);
    strftime(buffer, size, "%Y-%m-%d %H:%M:%S", tm_info);
}

void signal_handler(int signum) {
    char timestamp[64];
    get_timestamp(timestamp, sizeof(timestamp));
    
    const char *signame;
    switch(signum) {
        case SIGTERM: signame = "SIGTERM"; break;
        case SIGINT:  signame = "SIGINT"; break;
        case SIGHUP:  signame = "SIGHUP"; break;
        case SIGUSR1: signame = "SIGUSR1"; break;
        case SIGUSR2: signame = "SIGUSR2"; break;
        default:      signame = "UNKNOWN"; break;
    }
    
    printf("[%s] Received signal %d (%s)\n", timestamp, signum, signame);
    fflush(stdout);
    
    if (signum == SIGTERM || signum == SIGINT) {
        printf("[%s] Initiating graceful shutdown...\n", timestamp);
        fflush(stdout);

        if (shutdown_delay > 0) {
            printf("[%s] Waiting %d seconds before exiting...\n", timestamp, shutdown_delay);
            fflush(stdout);

            if (verbose_shutdown) {
                for (int i = 1; i <= shutdown_delay; i+=2) {
                    sleep(2);
                    get_timestamp(timestamp, sizeof(timestamp));
                    printf("[%s] Shutdown delay: %d/%d seconds elapsed\n", timestamp, i, shutdown_delay);
                    fflush(stdout);
                }
            } else {
                sleep(shutdown_delay);
            }
            get_timestamp(timestamp, sizeof(timestamp));
            printf("[%s] Shutdown delay completed\n", timestamp);
            fflush(stdout);
        }

        should_exit = 1;
    }
}

int main(int argc, char *argv[]) {
    char timestamp[64];

    // Parse command line arguments
    if (argc > 1) {
        shutdown_delay = atoi(argv[1]);
        if (shutdown_delay < 0) {
            fprintf(stderr, "Usage: %s [DELAY_SECONDS] [VERBOSE]\n", argv[0]);
            fprintf(stderr, "  DELAY_SECONDS: Delay in seconds before exiting after signal (default: 0)\n");
            fprintf(stderr, "  VERBOSE:       0 or 1 to enable countdown logs (default: 0)\n");
            return 1;
        }
    }

    if (argc > 2) {
        verbose_shutdown = atoi(argv[2]);
    }

    // Install signal handlers
    signal(SIGTERM, signal_handler);
    signal(SIGINT, signal_handler);
    signal(SIGHUP, signal_handler);
    signal(SIGUSR1, signal_handler);
    signal(SIGUSR2, signal_handler);
    
    get_timestamp(timestamp, sizeof(timestamp));
    printf("[%s] Signal test program started (PID: %d)\n", timestamp, getpid());
    if (shutdown_delay > 0) {
        printf("[%s] Shutdown delay configured: %d seconds (verbose: %s)\n", 
               timestamp, shutdown_delay, verbose_shutdown ? "yes" : "no");
    }
    printf("[%s] Waiting for signals... (Ctrl+C or SIGTERM to exit gracefully)\n", timestamp);
    fflush(stdout);
    
    // Main loop
    while (!should_exit) {
        sleep(5);
        get_timestamp(timestamp, sizeof(timestamp));
        printf("[%s] Still running (PID: %d)...\n", timestamp, getpid());
        fflush(stdout);
    }
    
    get_timestamp(timestamp, sizeof(timestamp));
    printf("[%s] Exiting gracefully. Goodbye!\n", timestamp);
    fflush(stdout);
    
    return 0;
}

