/**
 * @file sha256_test.c
 * @brief SHA-256 Test Program for RISC-V
 * 
 * Comprehensive test program that mirrors the Verilog testbench functionality
 * Tests multiple SHA-256 test vectors to ensure correctness
 */

#include "sha256.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Test case structure
typedef struct {
    const char *name;
    const char *input;
    uint32_t input_len;
    const char *expected_hex;
} test_case_t;

// Test result tracking
static int passed_tests = 0;
static int total_tests = 0;

// Test cases matching the Verilog testbench
static const test_case_t test_cases[] = {
    {
        "Test Case 1: Message 'abc'",
        "abc",
        3,
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
    },
    {
        "Test Case 2: Message 'hello world'", 
        "hello world",
        11,
        "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"
    },
    {
        "Test Case 3: Empty string",
        "",
        0,
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    },
    {
        "Test Case 4: Message 'a'",
        "a",
        1,
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
    },
    {
        "Test Case 5: Message 'message digest'",
        "message digest",
        14,
        "f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650"
    },
    {
        "Test Case 6: Long message",
        "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
        112,
        "cf5b16a778af8380036ce59e7b0492370b249b11e8f07a51afac45037afee9d1"
    }
};

static const int num_test_cases = sizeof(test_cases) / sizeof(test_cases[0]);

/**
 * Convert hexadecimal string to bytes
 */
void hex_to_bytes(const char *hex_str, uint8_t *bytes) {
    int len = strlen(hex_str);
    for (int i = 0; i < len; i += 2) {
        sscanf(hex_str + i, "%2hhx", &bytes[i / 2]);
    }
}

/**
 * Compare two byte arrays
 */
int bytes_equal(const uint8_t *a, const uint8_t *b, int len) {
    return memcmp(a, b, len) == 0;
}

/**
 * Run a single test case
 */
void run_test(const test_case_t *test) {
    uint8_t digest[SHA256_DIGEST_SIZE];
    uint8_t expected[SHA256_DIGEST_SIZE];
    char hex_result[65]; // 32 bytes * 2 + null terminator
    
    total_tests++;
    
    printf("\n=== %s ===\n", test->name);
    printf("Input: \"%s\" (length: %u bytes)\n", test->input, test->input_len);
    
    // Compute SHA-256 hash
    sha256_hash((const uint8_t*)test->input, test->input_len, digest);
    
    // Convert result to hex string
    sha256_bytes_to_hex(digest, SHA256_DIGEST_SIZE, hex_result);
    
    // Convert expected result to bytes
    hex_to_bytes(test->expected_hex, expected);
    
    printf("Computed:  %s\n", hex_result);
    printf("Expected:  %s\n", test->expected_hex);
    
    // Compare results
    if (bytes_equal(digest, expected, SHA256_DIGEST_SIZE)) {
        printf("✓ %s PASSED!\n", test->name);
        passed_tests++;
    } else {
        printf("✗ %s FAILED!\n", test->name);
        printf("  Difference found in hash computation\n");
    }
}

/**
 * Test the incremental update functionality
 */
void test_incremental_update() {
    printf("\n=== Test Case 7: Incremental Update Test ===\n");
    printf("Input: \"hello\" + \" \" + \"world\" (incremental)\n");
    
    total_tests++;
    
    sha256_ctx_t ctx;
    uint8_t digest[SHA256_DIGEST_SIZE];
    uint8_t expected[SHA256_DIGEST_SIZE];
    char hex_result[65];
    
    // Expected result for "hello world"
    const char *expected_hex = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9";
    
    // Initialize and update incrementally
    sha256_init(&ctx);
    sha256_update(&ctx, (const uint8_t*)"hello", 5);
    sha256_update(&ctx, (const uint8_t*)" ", 1);
    sha256_update(&ctx, (const uint8_t*)"world", 5);
    sha256_final(&ctx, digest);
    
    // Convert result to hex string
    sha256_bytes_to_hex(digest, SHA256_DIGEST_SIZE, hex_result);
    
    // Convert expected result to bytes
    hex_to_bytes(expected_hex, expected);
    
    printf("Computed:  %s\n", hex_result);
    printf("Expected:  %s\n", expected_hex);
    
    // Compare results
    if (bytes_equal(digest, expected, SHA256_DIGEST_SIZE)) {
        printf("✓ Incremental Update Test PASSED!\n");
        passed_tests++;
    } else {
        printf("✗ Incremental Update Test FAILED!\n");
        printf("  Difference found in hash computation\n");
    }
}

/**
 * Test performance measurement
 */
void test_performance() {
    printf("\n=== Performance Test ===\n");
    
    const char *test_data = "The quick brown fox jumps over the lazy dog";
    const int iterations = 10000;
    uint8_t digest[SHA256_DIGEST_SIZE];
    
    printf("Computing SHA-256 for \"%s\" %d times...\n", test_data, iterations);
    
    // Simple performance test (no actual timing measurement in basic implementation)
    for (int i = 0; i < iterations; i++) {
        sha256_hash((const uint8_t*)test_data, strlen(test_data), digest);
    }
    
    printf("Performance test completed.\n");
    printf("Final hash: ");
    sha256_print_hash(digest);
    printf("\n");
}

/**
 * Display test summary
 */
void display_summary() {
    printf("\n==================================================\n");
    printf("=== SHA-256 Test Summary ===\n");
    printf("Total tests: %d\n", total_tests);
    printf("Passed: %d\n", passed_tests);
    printf("Failed: %d\n", total_tests - passed_tests);
    printf("Success rate: %.1f%%\n", total_tests ? (100.0 * passed_tests / total_tests) : 0.0);
    
    if (passed_tests == total_tests) {
        printf("All tests PASSED! SHA-256 implementation is correct.\n");
    } else {
        printf("Some tests FAILED. Please check the implementation.\n");
    }
    printf("==================================================\n");
}

/**
 * Main test program
 */
int main(int argc, char *argv[]) {
    printf("=== SHA-256 RISC-V Implementation Test Suite ===\n");
    printf("NIST FIPS 180-4 Compliant Test Vectors\n");
    printf("Converted from Verilog testbench\n");
    
    // Run all basic test cases
    for (int i = 0; i < num_test_cases; i++) {
        run_test(&test_cases[i]);
    }
    
    // Run additional tests
    test_incremental_update();
    
    // Performance test (optional)
    if (argc > 1 && strcmp(argv[1], "--performance") == 0) {
        test_performance();
    }
    
    // Display summary
    display_summary();
    
    return (passed_tests == total_tests) ? 0 : 1;
}