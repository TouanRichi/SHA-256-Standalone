/**
 * @file sha256_example.c
 * @brief Simple SHA-256 Example for RISC-V
 * 
 * Simple example showing how to use the SHA-256 library
 */

#include "sha256.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    uint8_t digest[SHA256_DIGEST_SIZE];
    const char *message;
    
    // Use command line argument or default message
    if (argc > 1) {
        message = argv[1];
    } else {
        message = "Hello, RISC-V World!";
    }
    
    printf("SHA-256 Example for RISC-V\n");
    printf("Message: \"%s\"\n", message);
    printf("Length: %zu bytes\n", strlen(message));
    
    // Compute SHA-256 hash
    sha256_hash((const uint8_t*)message, strlen(message), digest);
    
    // Print result
    printf("SHA-256: ");
    sha256_print_hash(digest);
    printf("\n");
    
    // Also demonstrate incremental hashing
    printf("\nIncremental hashing example:\n");
    
    sha256_ctx_t ctx;
    sha256_init(&ctx);
    
    // Add data in chunks
    const char *part1 = "Hello, ";
    const char *part2 = "RISC-V ";  
    const char *part3 = "World!";
    
    printf("Part 1: \"%s\"\n", part1);
    sha256_update(&ctx, (const uint8_t*)part1, strlen(part1));
    
    printf("Part 2: \"%s\"\n", part2);
    sha256_update(&ctx, (const uint8_t*)part2, strlen(part2));
    
    printf("Part 3: \"%s\"\n", part3);
    sha256_update(&ctx, (const uint8_t*)part3, strlen(part3));
    
    sha256_final(&ctx, digest);
    
    printf("Incremental SHA-256: ");
    sha256_print_hash(digest);
    printf("\n");
    
    return 0;
}