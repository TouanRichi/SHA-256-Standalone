# Chuyển đổi SHA-256 từ Verilog sang C cho RISC-V

## Tổng quan về quá trình chuyển đổi (Conversion Overview)

Dự án này thực hiện việc chuyển đổi hoàn chỉnh thuật toán SHA-256 từ ngôn ngữ Verilog (thiết kế phần cứng) sang ngôn ngữ C (phần mềm) được tối ưu cho vi xử lý RISC-V.

This project provides a complete conversion of the SHA-256 algorithm from Verilog (hardware design) to C language (software) optimized for RISC-V processors.

## Chi tiết quá trình chuyển đổi (Conversion Process Details)

### 1. Phân tích thiết kế Verilog gốc (Original Verilog Analysis)
- **SHA256top.v**: Module chính chứa toàn bộ logic SHA-256
- **SHA256tb.v**: Testbench với các test vectors chuẩn
- **Các thành phần được chuyển đổi**:
  - State machine (IDLE → INIT → PROCESS → FINALIZE → DONE)
  - SHA-256 constants (K values, initial hash values H0-H7)
  - Core functions: rotr, choice, majority, big_sigma0/1, small_sigma0/1
  - Message scheduling (W[0] to W[63])
  - 64 rounds của compression function

### 2. Kiến trúc C được tối ưu (Optimized C Architecture)

#### Cấu trúc dữ liệu chính (Main Data Structures):
```c
typedef struct {
    uint32_t h[8];           // Hash values H0-H7
    uint32_t w[64];          // Message schedule
    uint64_t total_bits;     // Total message length in bits
    uint8_t buffer[64];      // Input buffer
    uint32_t buffer_len;     // Current buffer length
    uint8_t finished;        // Hash computation finished flag
} sha256_ctx_t;
```

#### Các hàm core được chuyển đổi:
1. **Right rotation**: `rotr(x, n)` - Từ Verilog function sang C function
2. **Choice function**: `choice(e, f, g)` - Logic bitwise operations
3. **Majority function**: `majority(a, b, c)` - Boolean logic
4. **Sigma functions**: `big_sigma0/1`, `small_sigma0/1` - Bit manipulations

### 3. Tối ưu hóa cho RISC-V (RISC-V Optimizations)

#### Đặc điểm tối ưu:
- **32-bit operations**: Tận dụng kiến trúc 32/64-bit của RISC-V
- **Efficient rotations**: Sử dụng shift và OR operations
- **Memory alignment**: Đảm bảo data alignment tối ưu
- **Compiler optimizations**: Flags `-O2` và `-march=rv64gc`

#### So sánh performance:
| Metric | Verilog (Hardware) | C (RISC-V Software) |
|--------|-------------------|---------------------|
| Clock cycles | ~69 cycles | ~500-1000 instructions |
| Throughput | Parallel execution | Sequential execution |
| Power consumption | Very low | CPU dependent |
| Flexibility | Fixed logic | Programmable |

## Kết quả testing (Testing Results)

### Test Vectors được chuyển đổi:
Tất cả test cases từ Verilog testbench được implement trong C:

1. **"abc"** → `ba7816bf...` ✓
2. **"hello world"** → `b94d27b9...` ✓
3. **""** (empty) → `e3b0c442...` ✓
4. **"a"** → `ca978112...` ✓
5. **"message digest"** → `f7846f55...` ✓
6. **Long message** → `cf5b16a7...` ✓
7. **Incremental update** → `b94d27b9...` ✓

**Kết quả: 7/7 tests PASSED (100% success rate)**

## Cách sử dụng trong dự án RISC-V (RISC-V Project Integration)

### 1. Thêm vào embedded project:
```c
#include "sha256.h"

int main() {
    uint8_t hash[32];
    char *message = "Hello RISC-V";
    
    sha256_hash((uint8_t*)message, strlen(message), hash);
    
    // Use hash...
    return 0;
}
```

### 2. Biên dịch cho RISC-V:
```bash
# Cross-compile
riscv64-linux-gnu-gcc -O2 -march=rv64gc your_program.c sha256.c -o program.riscv

# Hoặc dùng Makefile
make -f Makefile_C riscv
```

### 3. Chạy trên RISC-V hardware hoặc emulator:
```bash
# Với QEMU emulation
qemu-riscv64 program.riscv

# Trên RISC-V hardware thật
./program.riscv
```

## So sánh với implementation gốc (Comparison with Original)

### Ưu điểm của phiên bản C:
- ✅ **Portability**: Chạy được trên mọi RISC-V processor
- ✅ **Flexibility**: Có thể customize và extend dễ dàng
- ✅ **Integration**: Dễ tích hợp vào existing software projects
- ✅ **Debugging**: Dễ debug hơn so với hardware
- ✅ **Incremental**: Hỗ trợ hash dữ liệu theo chunks

### Nhược điểm:
- ❌ **Speed**: Chậm hơn hardware implementation
- ❌ **Power**: Tiêu thụ điện năng cao hơn
- ❌ **Parallelism**: Không thể parallel như hardware

### Khi nào nên dùng từng implementation:
- **Verilog/Hardware**: FPGA, ASIC, high-throughput applications
- **C/Software**: Embedded systems, general computing, prototype development

## Tính tương thích (Compatibility)

### RISC-V ISA support:
- **RV64GC**: Full support với 64-bit addressing
- **RV32GC**: Compatible với 32-bit RISC-V cores
- **Custom extensions**: Có thể optimize cho specific RISC-V implementations

### Compiler support:
- **GCC**: `riscv64-linux-gnu-gcc` (recommended)
- **Clang**: `clang --target=riscv64-linux-gnu`
- **Embedded toolchains**: Tương thích với bare-metal toolchains

## Benchmarking

### Test performance trên các platform:

```bash
# Chạy performance test
make -f Makefile_C performance

# So sánh với OpenSSL (nếu có)
time ./sha256_test
time openssl dgst -sha256 /dev/null
```

### Expected performance:
- **x86_64**: ~100MB/s (reference)  
- **RISC-V (QEMU)**: ~10MB/s (emulated)
- **RISC-V hardware**: ~20-50MB/s (tùy clock speed)

## Tài liệu kỹ thuật (Technical Documentation)

### Files structure:
```
├── sha256.h           # Header với API definitions
├── sha256.c           # Core implementation  
├── sha256_test.c      # Test suite (mirrors Verilog TB)
├── sha256_example.c   # Usage examples
├── Makefile_C         # Build system với RISC-V support
├── README_C.md        # Detailed C documentation
└── VERILOG_TO_C.md    # This conversion guide
```

### API Overview:
```c
// Core API
void sha256_init(sha256_ctx_t *ctx);
void sha256_update(sha256_ctx_t *ctx, const uint8_t *data, uint32_t len);
void sha256_final(sha256_ctx_t *ctx, uint8_t *digest);
void sha256_hash(const uint8_t *data, uint32_t len, uint8_t *digest);

// Utilities
void sha256_print_hash(const uint8_t *hash);
void sha256_bytes_to_hex(const uint8_t *bytes, uint32_t len, char *hex_str);
```

## Kết luận (Conclusion)

Việc chuyển đổi từ Verilog sang C đã thành công hoàn toàn:

- ✅ **100% functional compatibility** - Tất cả test cases pass
- ✅ **RISC-V optimized** - Tối ưu cho RISC-V architecture
- ✅ **Easy integration** - API đơn giản, dễ sử dụng
- ✅ **Comprehensive testing** - Test suite đầy đủ
- ✅ **Cross-compilation support** - Build được cho multiple targets

Implementation C này cho phép developers sử dụng SHA-256 trên RISC-V processors một cách hiệu quả, với performance tốt và tính tương thích cao.

The C implementation provides developers with an efficient way to use SHA-256 on RISC-V processors, offering good performance and high compatibility.