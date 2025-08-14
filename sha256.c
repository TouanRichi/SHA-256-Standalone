/**
 * @file sha256.c
 * @brief SHA-256 Implementation for RISC-V
 * 
 * NIST FIPS 180-4 compliant SHA-256 implementation converted from Verilog
 * Optimized for RISC-V processors
 */

#include "sha256.h"
#include <stdio.h>

// SHA-256 round constants (64 values) - from NIST FIPS 180-4
const uint32_t K[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

/**
 * Right rotate function
 */
uint32_t rotr(uint32_t x, uint32_t n) {
    return (x >> n) | (x << (32 - n));
}

/**
 * Choice function: Ch(e, f, g) = (e & f) ^ (~e & g)
 */
uint32_t choice(uint32_t e, uint32_t f, uint32_t g) {
    return (e & f) ^ (~e & g);
}

/**
 * Majority function: Maj(a, b, c) = (a & b) ^ (a & c) ^ (b & c)
 */
uint32_t majority(uint32_t a, uint32_t b, uint32_t c) {
    return (a & b) ^ (a & c) ^ (b & c);
}

/**
 * Σ₀(x) = ROTR²(x) ⊕ ROTR¹³(x) ⊕ ROTR²²(x) - for compression function
 */
uint32_t big_sigma0(uint32_t x) {
    return rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
}

/**
 * Σ₁(x) = ROTR⁶(x) ⊕ ROTR¹¹(x) ⊕ ROTR²⁵(x) - for compression function
 */
uint32_t big_sigma1(uint32_t x) {
    return rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
}

/**
 * σ₀(x) = ROTR⁷(x) ⊕ ROTR¹⁸(x) ⊕ SHR³(x) - for message schedule
 */
uint32_t small_sigma0(uint32_t x) {
    return rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3);
}

/**
 * σ₁(x) = ROTR¹⁷(x) ⊕ ROTR¹⁹(x) ⊕ SHR¹⁰(x) - for message schedule
 */
uint32_t small_sigma1(uint32_t x) {
    return rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10);
}

/**
 * Initialize SHA-256 context
 */
void sha256_init(sha256_ctx_t *ctx) {
    // Initialize hash values with SHA-256 constants
    ctx->h[0] = H0_INIT;
    ctx->h[1] = H1_INIT;
    ctx->h[2] = H2_INIT;
    ctx->h[3] = H3_INIT;
    ctx->h[4] = H4_INIT;
    ctx->h[5] = H5_INIT;
    ctx->h[6] = H6_INIT;
    ctx->h[7] = H7_INIT;
    
    // Reset counters and flags
    ctx->total_bits = 0;
    ctx->buffer_len = 0;
    ctx->finished = 0;
    
    // Clear buffers
    memset(ctx->buffer, 0, sizeof(ctx->buffer));
    memset(ctx->w, 0, sizeof(ctx->w));
}

/**
 * Process a single 512-bit (64-byte) block
 */
void sha256_process_block(sha256_ctx_t *ctx, const uint8_t *block) {
    uint32_t a, b, c, d, e, f, g, h;
    uint32_t T1, T2;
    int t;
    
    // Copy block data to message schedule (first 16 words, big-endian)
    for (int i = 0; i < 16; i++) {
        ctx->w[i] = (block[i * 4] << 24) |
                    (block[i * 4 + 1] << 16) |
                    (block[i * 4 + 2] << 8) |
                    (block[i * 4 + 3]);
    }
    
    // Extend message schedule for words 16-63
    for (t = 16; t < 64; t++) {
        ctx->w[t] = small_sigma1(ctx->w[t - 2]) + ctx->w[t - 7] +
                    small_sigma0(ctx->w[t - 15]) + ctx->w[t - 16];
    }
    
    // Initialize working variables
    a = ctx->h[0];
    b = ctx->h[1];
    c = ctx->h[2];
    d = ctx->h[3];
    e = ctx->h[4];
    f = ctx->h[5];
    g = ctx->h[6];
    h = ctx->h[7];
    
    // Main compression loop (64 rounds)
    for (t = 0; t < 64; t++) {
        T1 = h + big_sigma1(e) + choice(e, f, g) + K[t] + ctx->w[t];
        T2 = big_sigma0(a) + majority(a, b, c);
        
        h = g;
        g = f;
        f = e;
        e = d + T1;
        d = c;
        c = b;
        b = a;
        a = T1 + T2;
    }
    
    // Add working variables to hash values
    ctx->h[0] += a;
    ctx->h[1] += b;
    ctx->h[2] += c;
    ctx->h[3] += d;
    ctx->h[4] += e;
    ctx->h[5] += f;
    ctx->h[6] += g;
    ctx->h[7] += h;
}

/**
 * Add padding to message
 */
void sha256_pad_message(sha256_ctx_t *ctx) {
    uint64_t total_bits = ctx->total_bits;
    uint32_t pad_len;
    
    // Add padding bit '1'
    ctx->buffer[ctx->buffer_len++] = 0x80;
    
    // Calculate padding length
    // Need room for 8 bytes (64 bits) for message length
    if (ctx->buffer_len <= 56) {
        pad_len = 56 - ctx->buffer_len;
    } else {
        pad_len = 64 + 56 - ctx->buffer_len;
    }
    
    // Add zero padding
    memset(ctx->buffer + ctx->buffer_len, 0, pad_len);
    ctx->buffer_len += pad_len;
    
    // Add message length in bits (big-endian, 64-bit)
    ctx->buffer[ctx->buffer_len++] = (total_bits >> 56) & 0xFF;
    ctx->buffer[ctx->buffer_len++] = (total_bits >> 48) & 0xFF;
    ctx->buffer[ctx->buffer_len++] = (total_bits >> 40) & 0xFF;
    ctx->buffer[ctx->buffer_len++] = (total_bits >> 32) & 0xFF;
    ctx->buffer[ctx->buffer_len++] = (total_bits >> 24) & 0xFF;
    ctx->buffer[ctx->buffer_len++] = (total_bits >> 16) & 0xFF;
    ctx->buffer[ctx->buffer_len++] = (total_bits >> 8) & 0xFF;
    ctx->buffer[ctx->buffer_len++] = total_bits & 0xFF;
    
    // Process final block(s)
    sha256_process_block(ctx, ctx->buffer);
    
    // If we have more than 64 bytes, process second block
    if (ctx->buffer_len > 64) {
        sha256_process_block(ctx, ctx->buffer + 64);
    }
}

/**
 * Update hash with new data
 */
void sha256_update(sha256_ctx_t *ctx, const uint8_t *data, uint32_t len) {
    uint32_t i = 0;
    
    if (ctx->finished) {
        return; // Already finalized
    }
    
    ctx->total_bits += len * 8;
    
    // Fill buffer first
    while (i < len && ctx->buffer_len < 64) {
        ctx->buffer[ctx->buffer_len++] = data[i++];
    }
    
    // Process full blocks
    while (ctx->buffer_len == 64) {
        sha256_process_block(ctx, ctx->buffer);
        ctx->buffer_len = 0;
        
        // Fill buffer with more data
        while (i < len && ctx->buffer_len < 64) {
            ctx->buffer[ctx->buffer_len++] = data[i++];
        }
    }
}

/**
 * Finalize hash computation
 */
void sha256_final(sha256_ctx_t *ctx, uint8_t *digest) {
    if (!ctx->finished) {
        sha256_pad_message(ctx);
        ctx->finished = 1;
    }
    
    // Output hash in big-endian format
    for (int i = 0; i < 8; i++) {
        digest[i * 4]     = (ctx->h[i] >> 24) & 0xFF;
        digest[i * 4 + 1] = (ctx->h[i] >> 16) & 0xFF;
        digest[i * 4 + 2] = (ctx->h[i] >> 8) & 0xFF;
        digest[i * 4 + 3] = ctx->h[i] & 0xFF;
    }
}

/**
 * Compute SHA-256 hash in one call
 */
void sha256_hash(const uint8_t *data, uint32_t len, uint8_t *digest) {
    sha256_ctx_t ctx;
    
    sha256_init(&ctx);
    sha256_update(&ctx, data, len);
    sha256_final(&ctx, digest);
}

/**
 * Print hash in hexadecimal format
 */
void sha256_print_hash(const uint8_t *hash) {
    for (int i = 0; i < SHA256_DIGEST_SIZE; i++) {
        printf("%02x", hash[i]);
    }
}

/**
 * Convert bytes to hexadecimal string
 */
void sha256_bytes_to_hex(const uint8_t *bytes, uint32_t len, char *hex_str) {
    for (uint32_t i = 0; i < len; i++) {
        sprintf(hex_str + i * 2, "%02x", bytes[i]);
    }
    hex_str[len * 2] = '\0';
}