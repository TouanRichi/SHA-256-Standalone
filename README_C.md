# SHA-256 Implementation for RISC-V

## Tổng quan (Overview)

Đây là phiên bản chuyển đổi từ Verilog sang ngôn ngữ C của thuật toán SHA-256, được tối ưu hóa cho vi xử lý RISC-V. Implementation tuân thủ chuẩn NIST FIPS 180-4 và bao gồm tất cả các tính năng từ bản thiết kế Verilog gốc.

This is a C language conversion of the SHA-256 Verilog implementation, optimized for RISC-V processors. The implementation is NIST FIPS 180-4 compliant and includes all features from the original Verilog design.

## Các file chính (Main Files)

### Thư viện chính (Core Library)
- **`sha256.h`** - File header với các khai báo hàm và hằng số
- **`sha256.c`** - Implementation chính của thuật toán SHA-256
- **`sha256_test.c`** - Bộ test tổng hợp tương tự testbench Verilog
- **`sha256_example.c`** - Ví dụ sử dụng đơn giản
- **`Makefile_C`** - Makefile hỗ trợ cross-compilation cho RISC-V

### Các đặc tính (Features)
- **Tuân thủ NIST FIPS 180-4**: Implementation chính thức theo chuẩn
- **Tối ưu cho RISC-V**: Code được tối ưu cho kiến trúc RISC-V
- **Cross-compilation**: Hỗ trợ biên dịch cho cả native và RISC-V
- **Incremental hashing**: Hỗ trợ hash dữ liệu theo từng phần
- **Test vectors đầy đủ**: Bao gồm tất cả test cases từ Verilog testbench

## Cài đặt và sử dụng (Installation and Usage)

### Yêu cầu hệ thống (System Requirements)
```bash
# Để biên dịch native
sudo apt-get install gcc make

# Để biên dịch cho RISC-V
sudo apt-get install gcc-riscv64-linux-gnu qemu-user-static
```

### Biên dịch (Compilation)

#### Biên dịch native:
```bash
make -f Makefile_C all
```

#### Biên dịch cho RISC-V:
```bash
make -f Makefile_C riscv
```

#### Chạy test:
```bash
# Native
make -f Makefile_C test

# RISC-V (với QEMU)
make -f Makefile_C test-riscv
```

### Sử dụng cơ bản (Basic Usage)

```c
#include "sha256.h"
#include <stdio.h>

int main() {
    uint8_t digest[SHA256_DIGEST_SIZE];
    const char *message = "Hello, RISC-V!";
    
    // Tính SHA-256 hash
    sha256_hash((const uint8_t*)message, strlen(message), digest);
    
    // In kết quả
    printf("SHA-256: ");
    sha256_print_hash(digest);
    printf("\\n");
    
    return 0;
}
```

### Sử dụng incremental hashing:

```c
#include "sha256.h"

int main() {
    sha256_ctx_t ctx;
    uint8_t digest[SHA256_DIGEST_SIZE];
    
    // Khởi tạo context
    sha256_init(&ctx);
    
    // Thêm dữ liệu từng phần
    sha256_update(&ctx, (const uint8_t*)"Hello, ", 7);
    sha256_update(&ctx, (const uint8_t*)"RISC-V!", 7);
    
    // Hoàn thành và lấy kết quả
    sha256_final(&ctx, digest);
    
    sha256_print_hash(digest);
    return 0;
}
```

## API Reference

### Các hàm chính (Main Functions)

#### `void sha256_init(sha256_ctx_t *ctx)`
Khởi tạo SHA-256 context với các giá trị hash ban đầu.

#### `void sha256_update(sha256_ctx_t *ctx, const uint8_t *data, uint32_t len)`
Thêm dữ liệu vào hash context. Có thể gọi nhiều lần.

#### `void sha256_final(sha256_ctx_t *ctx, uint8_t *digest)`
Hoàn thành quá trình hash và trả về kết quả 256-bit.

#### `void sha256_hash(const uint8_t *data, uint32_t len, uint8_t *digest)`
Tính SHA-256 hash trong một lần gọi duy nhất.

### Các hàm tiện ích (Utility Functions)

#### `void sha256_print_hash(const uint8_t *hash)`
In hash dưới dạng hexadecimal.

#### `void sha256_bytes_to_hex(const uint8_t *bytes, uint32_t len, char *hex_str)`
Chuyển đổi bytes thành chuỗi hexadecimal.

## Test Vectors

Implementation được test với các test vectors chuẩn:

1. **"abc"** → `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad`
2. **"hello world"** → `b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9`
3. **""** (empty) → `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
4. **"a"** → `ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb`
5. **"message digest"** → `f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650`

## Tối ưu hóa cho RISC-V (RISC-V Optimizations)

- **32-bit operations**: Tối ưu cho các phép toán 32-bit của SHA-256
- **Efficient rotations**: Sử dụng bit operations hiệu quả
- **Memory alignment**: Đảm bảo alignment cho hiệu suất tốt nhất
- **Compiler optimizations**: Flags biên dịch được tối ưu cho RISC-V

## So sánh với Verilog (Comparison with Verilog)

| Aspect | Verilog | C Implementation |
|--------|---------|------------------|
| Clock cycles | ~69 cycles | N/A (software) |
| State machine | Hardware FSM | Function calls |
| Parallelism | Hardware parallel | Sequential |
| Memory usage | Registers/RAM | Stack/Heap |
| Portability | FPGA/ASIC only | Any processor |

## Makefile Commands

```bash
# Xem tất cả các lệnh có sẵn
make -f Makefile_C help

# Thông tin về project
make -f Makefile_C info

# Chạy performance test
make -f Makefile_C performance
make -f Makefile_C performance-riscv

# Cài đặt library
make -f Makefile_C install
make -f Makefile_C install-riscv

# Dọn dẹp build files
make -f Makefile_C clean
```

## Ví dụ chạy chương trình (Example Usage)

```bash
# Chạy test suite
./sha256_test

# Chạy example với custom message
./sha256_example "Your custom message here"

# Chạy trên RISC-V với QEMU
qemu-riscv64 -L /usr/riscv64-linux-gnu ./sha256_test.riscv
```

## Hiệu suất (Performance)

Implementation được tối ưu để:
- Tận dụng pipeline của RISC-V
- Giảm thiểu memory access
- Sử dụng hiệu quả registers
- Tối ưu cho compiler optimization

## Tích hợp vào project RISC-V (Integration into RISC-V Projects)

### Sử dụng như thư viện:
```bash
# Biên dịch thư viện
make -f Makefile_C libsha256.riscv.a

# Liên kết với project
riscv64-linux-gnu-gcc your_program.c -L. -lsha256 -o your_program.riscv
```

### Include trong embedded system:
```c
// Chỉ cần include 2 files
#include "sha256.h"
// Compile với sha256.c
```

## Troubleshooting

### Lỗi biên dịch cho RISC-V:
```bash
# Kiểm tra toolchain
riscv64-linux-gnu-gcc --version

# Cài đặt toolchain nếu cần
sudo apt-get install gcc-riscv64-linux-gnu
```

### Lỗi khi chạy với QEMU:
```bash
# Cài đặt QEMU
sudo apt-get install qemu-user-static

# Kiểm tra QEMU
qemu-riscv64 --version
```