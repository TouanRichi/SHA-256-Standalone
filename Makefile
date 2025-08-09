# Makefile for SHA-256 Standalone Implementation

CC = gcc
CFLAGS = -Wall -O2 -D_POSIX_C_SOURCE=199309L
SRCDIR = Source

# Directories
C_COMPARE_DIR = $(SRCDIR)/C_Compare
SHA256_C_DIR = $(C_COMPARE_DIR)/Sha256_C
C_CODE_DIR = $(SRCDIR)/C_code

# Targets
SHA256_REF = $(C_COMPARE_DIR)/SHA256
SHA256_OPT = $(SHA256_C_DIR)/sha256_test
DATA_FORMATTER1 = $(C_CODE_DIR)/C1
DATA_FORMATTER2 = $(C_CODE_DIR)/C2

# Test files
TESTFILE = $(C_COMPARE_DIR)/testFile1.txt

.PHONY: all build test clean help

all: build

help:
	@echo "Available targets:"
	@echo "  build    - Build all SHA-256 implementations"
	@echo "  test     - Run tests on all implementations"
	@echo "  clean    - Remove all build artifacts"
	@echo "  help     - Show this help message"

build: $(SHA256_REF) $(SHA256_OPT) $(DATA_FORMATTER1) $(DATA_FORMATTER2)
	@echo "All SHA-256 implementations built successfully!"

# Reference implementation
$(SHA256_REF): $(C_COMPARE_DIR)/SHA256.c
	$(CC) $(CFLAGS) -o $@ $<
	@echo "Built reference SHA-256 implementation"

# Optimized implementation  
$(SHA256_OPT): $(SHA256_C_DIR)/example.c $(SHA256_C_DIR)/sha256.c $(SHA256_C_DIR)/sha256.h
	$(CC) $(CFLAGS) -o $@ $<
	@echo "Built optimized SHA-256 implementation"

# Data formatters
$(DATA_FORMATTER1): $(C_CODE_DIR)/C1.c
	$(CC) $(CFLAGS) -o $@ $<
	@echo "Built data formatter C1"

$(DATA_FORMATTER2): $(C_CODE_DIR)/C2.c  
	$(CC) $(CFLAGS) -o $@ $<
	@echo "Built data formatter C2"

test: build
	@echo "Testing reference implementation..."
	@if [ -f $(TESTFILE) ]; then \
		cd $(C_COMPARE_DIR) && ./SHA256 testFile1.txt; \
	else \
		echo "Test file not found, creating basic test..."; \
		echo "hello world" > $(TESTFILE); \
		cd $(C_COMPARE_DIR) && ./SHA256 testFile1.txt; \
	fi
	@echo ""
	@echo "Testing optimized implementation..."
	@cd $(SHA256_C_DIR) && ./sha256_test
	@echo ""
	@echo "All tests completed!"

clean:
	rm -f $(SHA256_REF)
	rm -f $(SHA256_OPT)
	rm -f $(DATA_FORMATTER1)
	rm -f $(DATA_FORMATTER2)
	rm -f $(C_COMPARE_DIR)/*.o
	rm -f $(SHA256_C_DIR)/*.o
	rm -f $(C_CODE_DIR)/*.o
	@echo "Clean completed!"

# Individual test targets
test-ref: $(SHA256_REF)
	@echo "Testing reference implementation..."
	@cd $(C_COMPARE_DIR) && ./SHA256 testFile1.txt

test-opt: $(SHA256_OPT)
	@echo "Testing optimized implementation..."
	@cd $(SHA256_C_DIR) && ./sha256_test

# Development targets
debug: CFLAGS += -g -DDEBUG
debug: build

benchmark: CFLAGS += -O3 -DBENCHMARK
benchmark: build