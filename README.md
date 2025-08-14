# SHA-256 Consolidated Implementation

## Overview

This repository contains both **Verilog** and **C** implementations of the SHA-256 cryptographic hash algorithm:

- **Verilog Implementation**: Hardware-oriented SHA-256 for FPGA/ASIC deployment
- **C Implementation**: Software SHA-256 optimized for RISC-V processors

Both implementations are NIST FIPS 180-4 compliant and include comprehensive test suites.

## Implementations

### Verilog Implementation (Hardware)
This is a consolidated SHA-256 implementation that combines all functionality into just **2 files** for easier control and management. The original design had ~85 separate Verilog files with multiple variants (clean, fixed, enhance, etc.) which have been merged into a single, streamlined implementation.

### C Implementation (Software)
A complete C language conversion of the Verilog implementation, optimized for RISC-V processors. This provides the same SHA-256 functionality in software form suitable for embedded systems and general-purpose computing.

## Consolidated Files

### Verilog Implementation (Hardware)
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

### C Implementation (Software)
- **`sha256.h`** - Header file with function declarations and constants
- **`sha256.c`** - Complete SHA-256 implementation in C (7KB)
  - All SHA-256 functions converted from Verilog
  - Incremental hashing support
  - RISC-V optimized code
- **`sha256_test.c`** - Comprehensive test suite (6KB)
  - Mirrors Verilog testbench functionality
  - Same test vectors as hardware implementation
- **`sha256_example.c`** - Simple usage example
- **`Makefile_C`** - Build system with RISC-V cross-compilation support
- **`README_C.md`** - Detailed C implementation documentation

### Build Systems
- **`Makefile`** - Original Verilog build system
- **`Makefile_C`** - C implementation build system with RISC-V support

## Features

### Verilog Implementation
- **Single File Design**: All functionality consolidated from ~85 original files
- **NIST FIPS 180-4 Compliant**: Follows the official SHA-256 specification
- **Complete Test Suite**: 6 comprehensive test cases with known good vectors
- **Easy to Control**: No complex file dependencies or module hierarchies
- **Performance Monitoring**: Built-in cycle counting and timing analysis

### C Implementation
- **RISC-V Optimized**: Designed specifically for RISC-V processor architectures
- **Incremental Hashing**: Process data in chunks for memory efficiency
- **Cross-Platform**: Compiles for both native and RISC-V targets
- **Comprehensive Testing**: 7 test cases matching Verilog testbench
- **Easy Integration**: Simple API for embedding in larger projects

## Quick Start

### Verilog Implementation (Hardware)
```bash
# Build the consolidated design
make build

# Run the test suite
make test

# View project information
make info

# Clean build artifacts
make clean
```

### C Implementation (Software)
```bash
# Build native C implementation
make -f Makefile_C all

# Run tests
make -f Makefile_C test

# Run example program
make -f Makefile_C example

# Build for RISC-V (requires toolchain)
make -f Makefile_C riscv

# Get help
make -f Makefile_C help
```

## Implementation Comparison

| Aspect | Verilog (Hardware) | C (Software) |
|--------|-------------------|--------------|
| **Target** | FPGA/ASIC | RISC-V/General CPU |
| **Execution** | Parallel hardware | Sequential software |
| **Clock Cycles** | ~69 cycles | N/A (function calls) |
| **Memory Usage** | Registers/Block RAM | Stack/Heap |
| **Throughput** | High (pipelined) | Moderate (sequential) |
| **Portability** | Hardware specific | Cross-platform |
| **Integration** | HDL projects | C/C++ projects |
| **Power Consumption** | Low (optimized) | CPU dependent |

Both implementations produce identical results and use the same test vectors for verification.

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

## Usage Examples

### C Implementation
```c
#include "sha256.h"
#include <stdio.h>

int main() {
    uint8_t digest[SHA256_DIGEST_SIZE];
    const char *message = "Hello, RISC-V!";
    
    // Compute SHA-256 hash
    sha256_hash((const uint8_t*)message, strlen(message), digest);
    
    // Print result
    printf("SHA-256: ");
    sha256_print_hash(digest);
    printf("\n");
    
    return 0;
}
```

### Verilog Integration
```verilog
// Instantiate SHA-256 module
SHA256top sha256_inst (
    .clk(clk),
    .reset(reset),
    .start_in(start_hash),
    .w0_sha256(message_word_0),
    // ... more message words
    .sha256_result(hash_result),
    .sha256_done(hash_complete)
);
```

## Interface

### Verilog Module Ports
**Input Ports**
- `clk` - System clock
- `reset` - Active low reset
- `start_in` - Start hash computation
- `w0_sha256` to `w15_sha256` - Input message words (512-bit block)
- `A_i` to `H_i` - Initial hash values (optional)

**Output Ports**
- `sha256_result[255:0]` - Computed SHA-256 hash
- `sha256_done` - Hash computation complete flag

### C API Functions
**Core Functions**
- `sha256_init(ctx)` - Initialize context
- `sha256_update(ctx, data, len)` - Add data to hash
- `sha256_final(ctx, digest)` - Finalize and get result
- `sha256_hash(data, len, digest)` - One-shot hashing

**Utility Functions**
- `sha256_print_hash(hash)` - Print hash in hex
- `sha256_bytes_to_hex(bytes, len, hex_str)` - Convert to hex string

## RISC-V Deployment

The C implementation is specifically optimized for RISC-V processors:

### Compilation for RISC-V
```bash
# Install RISC-V toolchain (Ubuntu/Debian)
sudo apt-get install gcc-riscv64-linux-gnu qemu-user-static

# Cross-compile for RISC-V
make -f Makefile_C riscv

# Run on RISC-V with QEMU emulation
make -f Makefile_C test-riscv
```

### Integration in RISC-V Projects
```c
// Include in your RISC-V project
#include "sha256.h"

// Link with the library
// riscv64-linux-gnu-gcc your_code.c -lsha256 -o your_program.riscv
```

### Performance Characteristics
- Optimized for RISC-V instruction set
- Efficient 32-bit operations
- Minimal memory footprint
- Cache-friendly access patterns

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