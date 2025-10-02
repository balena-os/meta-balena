#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <getopt.h>
#include <signal.h>
#include <sys/stat.h>
#include <systemd/sd-daemon.h>

#define BUFFER_SIZE 512
#define DEFAULT_INTERVAL 10000  /* 10ms in microseconds */

static volatile int running = 1;
static char *test_file = NULL;
static int interval_us = DEFAULT_INTERVAL;
static int verbose_mode = 0;
static int debug_mode = 0;

#define LOG_VERBOSE(fmt, ...) do { \
    if (verbose_mode) { \
        printf(fmt, ##__VA_ARGS__); \
        fflush(stdout); \
    } \
} while(0)

// this test will overwrite the file with test data and check for write errors
int test_write(const char *filename) {
    void *write_buf;
    int fd;
    ssize_t ret;
    int i;
    const int write_chunks = 10; // Write 10 * BUFFER_SIZE

    // it's necessary to align the buffer to the page size because O_DIRECT requires it
    if (posix_memalign(&write_buf, BUFFER_SIZE, BUFFER_SIZE)) {
        fprintf(stderr, "posix_memalign failed for write buffer\n");
        return 1;
    }
    memset(write_buf, 'A', BUFFER_SIZE);

    fd = open(filename, O_CREAT | O_WRONLY | O_TRUNC | O_DIRECT, 0666);
    if (fd < 0) {
        fprintf(stderr, "open failed: %s\n", strerror(errno));
        free(write_buf);
        return 2;
    }

    // Write multiple chunks to test sustained I/O
    for (i = 0; i < write_chunks; i++) {
        ret = write(fd, write_buf, BUFFER_SIZE);
        if (ret < 0) {
            fprintf(stderr, "write failed on chunk %d: %s\n", i, strerror(errno));
            close(fd);
            free(write_buf);
            return 3;
        }
        if (ret != BUFFER_SIZE) {
            fprintf(stderr, "partial write on chunk %d: %zd/%d bytes\n", i, ret, BUFFER_SIZE);
            close(fd);
            free(write_buf);
            return 4;
        }
    }

    if (fsync(fd) < 0) {
        fprintf(stderr, "fsync failed: %s\n", strerror(errno));
        close(fd);
        free(write_buf);
        return 5;
    }

    if (close(fd) < 0) {
        fprintf(stderr, "close failed: %s\n", strerror(errno));
        free(write_buf);
        return 6;
    }

    free(write_buf);

    sync();
    sync();
    return 0; // Success
}

int test_read(const char *filename) {
    void *read_buf;
    int fd;
    off_t file_size;
    off_t bytes_read;
    ssize_t ret;

    // it's necessary to align the buffer to the page size because O_DIRECT requires it
    if (posix_memalign(&read_buf, BUFFER_SIZE, BUFFER_SIZE)) {
        fprintf(stderr, "posix_memalign failed for read buffer\n");
        return 1;
    }
    memset(read_buf, 0, BUFFER_SIZE);

    fd = open(filename, O_RDONLY | O_DIRECT);
    if (fd < 0) {
        fprintf(stderr, "open failed for read: %s\n", strerror(errno));
        free(read_buf);
        return 2;
    }

    file_size = lseek(fd, 0, SEEK_END);
    if (file_size < 0) {
        fprintf(stderr, "lseek failed: %s\n", strerror(errno));
        close(fd);
        free(read_buf);
        return 3;
    }

    lseek(fd, 0, SEEK_SET); // Reset to beginning

    /* For O_DIRECT, only read complete BUFFER_SIZE blocks to avoid alignment issues */
    off_t aligned_size = (file_size / BUFFER_SIZE) * BUFFER_SIZE;
    
    bytes_read = 0;
    while (bytes_read < aligned_size) {
        ret = read(fd, read_buf, BUFFER_SIZE);
        if (ret < 0) {
            fprintf(stderr, "read failed at offset %ld: %s\n", bytes_read, strerror(errno));
            close(fd);
            free(read_buf);
            return 4;
        } else if (ret == 0) {
            fprintf(stderr, "unexpected EOF at offset %ld\n", bytes_read);
            close(fd);
            free(read_buf);
            return 5;
        } else if (ret != BUFFER_SIZE) {
            fprintf(stderr, "partial read at offset %ld: %zd/%d bytes\n", bytes_read, ret, BUFFER_SIZE);
            close(fd);
            free(read_buf);
            return 6;
        }
        bytes_read += ret;
    }

    if (close(fd) < 0) {
        fprintf(stderr, "close failed: %s\n", strerror(errno));
        free(read_buf);
        return 7;
    }

    free(read_buf);
    return 0; // Success
}

static void signal_handler(int sig) {
    (void)sig;
    running = 0;
}

static void print_usage(const char *prog_name) {
    printf("Usage: %s [OPTIONS]\n", prog_name);
    printf("Disk watchdog daemon that monitors disk I/O health\n\n");
    printf("Options:\n");
    printf("  -f, --file PATH      Test file path (required)\n");
    printf("  -i, --interval MS    Test interval in milliseconds (default: %d)\n", DEFAULT_INTERVAL / 1000);
    printf("  -h, --help           Show this help message\n");
    printf("  -v, --verbose        Enable verbose output\n");
    printf("  -d, --debug          Debug mode (verbose + no systemd notify)\n");
}

static int parse_args(int argc, char *argv[]) {
    int opt;

    static struct option long_options[] = {
        {"file",     required_argument, 0, 'f'},
        {"interval", required_argument, 0, 'i'},
        {"help",     no_argument,       0, 'h'},
        {"verbose",  no_argument,       0, 'v'},
        {"debug",    no_argument,       0, 'd'},
        {0, 0, 0, 0}
    };

    while ((opt = getopt_long(argc, argv, "f:i:hvd", long_options, NULL)) != -1) {
        switch (opt) {
            case 'f':
                test_file = strdup(optarg);
                if (!test_file) {
                    fprintf(stderr, "Failed to allocate memory for file path\n");
                    return -1;
                }
                break;
            case 'i':
                interval_us = atoi(optarg) * 1000; /* Convert ms to us */
                if (interval_us <= 0) {
                    fprintf(stderr, "Invalid interval: %s\n", optarg);
                    return -1;
                }
                break;
            case 'v':
                verbose_mode = 1;
                break;
            case 'd':
                debug_mode = 1;
                verbose_mode = 1;
                break;
            case 'h':
                print_usage(argv[0]);
                exit(0);
            default:
                print_usage(argv[0]);
                return -1;
        }
    }

    if (!test_file) {
        fprintf(stderr, "Error: Test file path is required\n");
        print_usage(argv[0]);
        return -1;
    }

    /* Check if systemd watchdog is enabled and adjust interval if not manually set */
    if (!debug_mode) {
        uint64_t watchdog_usec = 0;
        int watchdog_enabled = sd_watchdog_enabled(0, &watchdog_usec);
        if (watchdog_enabled > 0) {
            LOG_VERBOSE("Systemd watchdog enabled: timeout = %lu microseconds (%.1f seconds)\n",
                       watchdog_usec, watchdog_usec / 1000000.0);
            /* Always override interval when systemd watchdog is enabled for safety */
            if (interval_us != DEFAULT_INTERVAL) {
                LOG_VERBOSE("Overriding user-specified interval (%d ms) for watchdog safety\n", interval_us / 1000);
            }
            /* Use half the watchdog timeout as our test interval for safety margin */
            interval_us = watchdog_usec / 2;
            LOG_VERBOSE("Using watchdog-safe interval: %d ms\n", interval_us / 1000);
            LOG_VERBOSE("Systemd watchdog integration: ENABLED\n");
        }
    }

    LOG_VERBOSE("Configuration:\n");
    LOG_VERBOSE("  Test file: %s\n", test_file);
    LOG_VERBOSE("  Interval: %d ms\n", interval_us / 1000);
    if (debug_mode) {
        LOG_VERBOSE("  Debug mode: ON (systemd notify disabled)\n");
    }

    return 0;
}

static int check_test_file(const char *filepath) {
    struct stat st;

    if (stat(filepath, &st) < 0) {
        fprintf(stderr, "Test file %s does not exist: %s\n", filepath, strerror(errno));
        return -1;
    }

    if (!S_ISREG(st.st_mode)) {
        fprintf(stderr, "Test file %s is not a regular file\n", filepath);
        return -1;
    }

    if (st.st_size == 0) {
        fprintf(stderr, "Test file %s is empty\n", filepath);
        return -1;
    }

    return 0;
}

int main(int argc, char *argv[]) {
    int iteration = 0;
    int read_result;
    
    /* Parse command line arguments */
    if (parse_args(argc, argv) < 0) {
        return 1;
    }

    /* Set up signal handlers */
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    /* Check test file exists and has content */
    if (check_test_file(test_file) < 0) {
        free(test_file);
        return 1;
    }

    /* Notify systemd that we're ready */
    if (!debug_mode) {
        sd_notify(0, "READY=1");
    }
    
    LOG_VERBOSE("Disk watchdog started (PID: %d)\n", getpid());
    LOG_VERBOSE("Monitoring: %s\n", test_file);

    while (running) {
        LOG_VERBOSE("=== Iteration %d ===\n", ++iteration);
        
        read_result = test_read(test_file);
        if (read_result != 0) {
            fprintf(stderr, "Read test failed with code %d\n", read_result);
            fflush(stderr);
            /* Don't reset watchdog on failure - let systemd handle timeout */
        } else {
            LOG_VERBOSE("read ok\n");
            /* Reset systemd watchdog timer on successful read */
            if (!debug_mode) {
                sd_notify(0, "WATCHDOG=1");
            }
        }

        usleep(interval_us);
    }

    LOG_VERBOSE("Disk watchdog shutting down\n");
    free(test_file);
    return 0;
}

