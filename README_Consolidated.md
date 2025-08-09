# SHA-256 Consolidated Implementation

## Overview

This is a consolidated SHA-256 implementation that combines all functionality into just **2 files** for easier control and management. The original design had ~85 separate Verilog files with multiple variants (clean, fixed, enhance, etc.) which have been merged into a single, streamlined implementation.

## Consolidated Files

### Core Files
- **`SHA256top.v`** - Complete SHA-256 implementation in a single file (10KB)
  - Contains all SHA-256 functions (Ch, Maj, Σ₀, Σ₁, σ₀, σ₁)
  - Includes complete state machine for hash computation
  - NIST FIPS 180-4 compliant implementation
  - All K constants and initial hash values included

- **`SHA256tb.v`** - Comprehensive testbench in a single file (10KB)
  - Tests multiple SHA-256 test vectors
  - Includes test cases for "abc", "hello world", empty string, etc.
  - Automated pass/fail reporting
  - Performance cycle counting

### Build System
- **`Makefile_Consolidated`** - Simple Makefile for the consolidated design
  - `make -f Makefile_Consolidated build` - Build the design
  - `make -f Makefile_Consolidated test` - Run all tests
  - `make -f Makefile_Consolidated clean` - Clean build artifacts

## Features

- **Single File Design**: All functionality consolidated from ~85 original files
- **NIST FIPS 180-4 Compliant**: Follows the official SHA-256 specification
- **Complete Test Suite**: 6 comprehensive test cases with known good vectors
- **Easy to Control**: No complex file dependencies or module hierarchies
- **Performance Monitoring**: Built-in cycle counting and timing analysis

## Quick Start

```bash
# Build the consolidated design
make -f Makefile_Consolidated build

# Run the test suite
make -f Makefile_Consolidated test

# View project information
make -f Makefile_Consolidated info

# Clean build artifacts
make -f Makefile_Consolidated clean
```

## Original Files Consolidated

The following original files were merged into the consolidated implementation:

### Top-Level Modules (merged into SHA256top.v)
- `SHA256_Top.v`
- `SHA256_Top_Clean.v`
- Various other top-level variants

### Functional Modules (inline functions in SHA256top.v)
- `Ch.v` - Choice function
- `Maj.v` - Majority function  
- `Delta0.v`, `Delta1.v` - Delta functions
- `Sigma0.v`, `Sigma1.v` - Sigma functions
- All `Adder*.v` files - Addition operations
- `FSM_Sha.v` - State machine (integrated)
- `K_Constants.v` - Round constants (integrated)
- All register modules (`Reg*.v`) - Integrated into state machine

### Testbench Modules (merged into SHA256tb.v)
- `SHA256_tb.v`
- `SHA256_Clean_tb.v`
- `SHA256_Fixed_tb.v`
- `SHA256_tb_enhanced.v`

## Technical Specifications

- **Algorithm**: SHA-256 (Secure Hash Algorithm 256-bit)
- **Block Size**: 512 bits (16 × 32-bit words)
- **Hash Size**: 256 bits (8 × 32-bit words)
- **Rounds**: 64 compression rounds
- **Clock Cycles**: ~69 cycles per hash computation
- **Implementation**: Synchronous, clocked design with finite state machine

## Test Vectors

The testbench includes the following standard test vectors:

1. **"abc"** → `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad`
2. **"hello world"** → `b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9`
3. **Empty string ""** → `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
4. **"a"** → `ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb`
5. **"message digest"** → `f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650`
6. **Long message** → `248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1`

## Interface

### Input Ports
- `clk` - System clock
- `reset` - Active low reset
- `start_in` - Start hash computation
- `w0_sha256` to `w15_sha256` - Input message words (512-bit block)
- `A_i` to `H_i` - Initial hash values (optional)

### Output Ports
- `sha256_result[255:0]` - Computed SHA-256 hash
- `sha256_done` - Hash computation complete flag

## Benefits of Consolidation

1. **Simplified Management**: Only 2 files to manage instead of ~85
2. **Reduced Complexity**: No complex module hierarchies or dependencies
3. **Easier Debugging**: All logic in one place for easier tracing
4. **Better Control**: Single point of modification for algorithm changes
5. **Cleaner Repository**: Removes redundant and variant files
6. **Faster Compilation**: Fewer files to process during build

## References

- [NIST FIPS 180-4](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf)
- [RFC 6234 - US Secure Hash Algorithms](https://tools.ietf.org/html/rfc6234)