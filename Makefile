# Makefile for Consolidated SHA-256 Implementation
# Simple build system for the consolidated design with only 2 files

# Project settings
PROJECT_NAME = SHA256_Consolidated
TOP_MODULE = SHA256top
TB_MODULE = SHA256tb

# Source files (consolidated into 2 files)
TOP_FILE = SHA256top.v
TB_FILE = SHA256tb.v

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Build directory
BUILD_DIR = build

.PHONY: all clean test build simulate view help

# Default target
all: test

help:
	@echo "Consolidated SHA-256 Build System"
	@echo "================================="
	@echo ""
	@echo "Available targets:"
	@echo "  build      - Compile the consolidated design"
	@echo "  test       - Run simulation with test vectors"
	@echo "  simulate   - Same as test"
	@echo "  view       - Open waveform viewer (GTKWave)"
	@echo "  clean      - Clean build artifacts"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Files:"
	@echo "  $(TOP_FILE)  - Consolidated top-level design"
	@echo "  $(TB_FILE)   - Consolidated testbench"

# Create build directory and build the consolidated design
build:
	mkdir -p $(BUILD_DIR)
	@echo "=== Building Consolidated SHA-256 Design ==="
	@echo "Compiling $(TOP_FILE) and $(TB_FILE)..."
	$(IVERILOG) -o $(BUILD_DIR)/$(PROJECT_NAME) $(TOP_FILE) $(TB_FILE)
	@echo "✓ Build completed successfully!"

# Run simulation
test: build simulate

simulate: build
	@echo "=== Running SHA-256 Simulation ==="
	cd $(BUILD_DIR) && $(VVP) $(PROJECT_NAME)
	@echo "✓ Simulation completed!"
	@if [ -f $(BUILD_DIR)/sha256_test.vcd ]; then \
		echo "✓ VCD file generated: $(BUILD_DIR)/sha256_test.vcd"; \
	fi

# View waveforms
view: $(BUILD_DIR)/sha256_test.vcd
	@echo "=== Opening Waveform Viewer ==="
	$(GTKWAVE) $(BUILD_DIR)/sha256_test.vcd &

$(BUILD_DIR)/sha256_test.vcd:
	@echo "VCD file not found. Running simulation first..."
	$(MAKE) simulate

# Syntax check only
check: $(BUILD_DIR)
	@echo "=== Checking Verilog Syntax ==="
	$(IVERILOG) -t null $(TOP_FILE) $(TB_FILE)
	@echo "✓ Syntax check passed!"

# Clean build artifacts
clean:
	@echo "=== Cleaning Build Artifacts ==="
	rm -rf $(BUILD_DIR)
	rm -f *.vcd *.lxt *.fst
	@echo "✓ Clean completed!"

# Show project info
info:
	@echo "=== Consolidated Project Information ==="
	@echo "Project Name: $(PROJECT_NAME)"
	@echo "Top Module:   $(TOP_MODULE)"
	@echo "Testbench:    $(TB_MODULE)"
	@echo "Build Dir:    $(BUILD_DIR)"
	@echo ""
	@echo "Source Files (consolidated from ~85 original files):"
	@echo "  $(TOP_FILE)  - Complete SHA-256 implementation"
	@echo "  $(TB_FILE)   - Comprehensive test suite"
	@echo ""
	@echo "Original files consolidated:"
	@echo "  - Multiple SHA256_Top*.v variants"
	@echo "  - All functional modules (Adder*, Ch.v, Maj.v, etc.)"
	@echo "  - All register modules (Reg*.v)"
	@echo "  - All Sigma/Delta function modules"
	@echo "  - Multiple testbench variants"