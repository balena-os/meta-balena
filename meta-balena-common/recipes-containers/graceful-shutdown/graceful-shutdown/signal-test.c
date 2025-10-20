#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <time.h>

volatile sig_atomic_t should_exit = 0;

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
        should_exit = 1;
    }
}

int main(int argc, char *argv[]) {
    char timestamp[64];
    
    // Install signal handlers
    signal(SIGTERM, signal_handler);
    signal(SIGINT, signal_handler);
    signal(SIGHUP, signal_handler);
    signal(SIGUSR1, signal_handler);
    signal(SIGUSR2, signal_handler);
    
    get_timestamp(timestamp, sizeof(timestamp));
    printf("[%s] Signal test program started (PID: %d)\n", timestamp, getpid());
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

