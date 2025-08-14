/**
 * @file sha256.h
 * @brief SHA-256 Implementation for RISC-V
 * 
 * NIST FIPS 180-4 compliant SHA-256 implementation converted from Verilog
 * Optimized for RISC-V processors
 */

#ifndef SHA256_H
#define SHA256_H

#include <stdint.h>
#include <string.h>

// SHA-256 constants
#define SHA256_BLOCK_SIZE 64    // 512 bits = 64 bytes
#define SHA256_DIGEST_SIZE 32   // 256 bits = 32 bytes

// SHA-256 initial hash values (NIST FIPS 180-4)
#define H0_INIT 0x6A09E667
#define H1_INIT 0xBB67AE85
#define H2_INIT 0x3C6EF372
#define H3_INIT 0xA54FF53A
#define H4_INIT 0x510E527F
#define H5_INIT 0x9B05688C
#define H6_INIT 0x1F83D9AB
#define H7_INIT 0x5BE0CD19

// SHA-256 round constants (K values)
extern const uint32_t K[64];

// SHA-256 context structure
typedef struct {
    uint32_t h[8];           // Hash values H0-H7
    uint32_t w[64];          // Message schedule
    uint64_t total_bits;     // Total message length in bits
    uint8_t buffer[64];      // Input buffer
    uint32_t buffer_len;     // Current buffer length
    uint8_t finished;        // Hash computation finished flag
} sha256_ctx_t;

// Core SHA-256 functions
uint32_t rotr(uint32_t x, uint32_t n);
uint32_t choice(uint32_t e, uint32_t f, uint32_t g);
uint32_t majority(uint32_t a, uint32_t b, uint32_t c);
uint32_t big_sigma0(uint32_t x);
uint32_t big_sigma1(uint32_t x);
uint32_t small_sigma0(uint32_t x);
uint32_t small_sigma1(uint32_t x);

// SHA-256 main functions
void sha256_init(sha256_ctx_t *ctx);
void sha256_update(sha256_ctx_t *ctx, const uint8_t *data, uint32_t len);
void sha256_final(sha256_ctx_t *ctx, uint8_t *digest);
void sha256_hash(const uint8_t *data, uint32_t len, uint8_t *digest);

// Internal processing functions
void sha256_process_block(sha256_ctx_t *ctx, const uint8_t *block);
void sha256_pad_message(sha256_ctx_t *ctx);

// Utility functions
void sha256_print_hash(const uint8_t *hash);
void sha256_bytes_to_hex(const uint8_t *bytes, uint32_t len, char *hex_str);

#endif // SHA256_H