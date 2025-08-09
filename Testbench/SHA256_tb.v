`timescale 1ns / 1ps

module SHA256_tb();

    // Test bench signals
    reg clk;
    reg reset;
    reg start_in;
    
    // Input message words (512-bit block)
    reg [31:0] w0_sha256, w1_sha256, w2_sha256, w3_sha256;
    reg [31:0] w4_sha256, w5_sha256, w6_sha256, w7_sha256;
    reg [31:0] w8_sha256, w9_sha256, w10_sha256, w11_sha256;
    reg [31:0] w12_sha256, w13_sha256, w14_sha256, w15_sha256;
    
    // Initial hash values (SHA-256 constants)
    reg [31:0] A_i, B_i, C_i, D_i, E_i, F_i, G_i, H_i;
    
    // Outputs
    wire [255:0] sha256_result;
    wire sha256_done;
    
    // Expected result for comparison
    reg [255:0] expected_result;
    
    // Instantiate the SHA-256 module
    SHA256_Top uut (
        .clk(clk),
        .reset(reset),
        .start_in(start_in),
        
        // Input message
        .w0_sha256(w0_sha256), .w1_sha256(w1_sha256), .w2_sha256(w2_sha256), .w3_sha256(w3_sha256),
        .w4_sha256(w4_sha256), .w5_sha256(w5_sha256), .w6_sha256(w6_sha256), .w7_sha256(w7_sha256),
        .w8_sha256(w8_sha256), .w9_sha256(w9_sha256), .w10_sha256(w10_sha256), .w11_sha256(w11_sha256),
        .w12_sha256(w12_sha256), .w13_sha256(w13_sha256), .w14_sha256(w14_sha256), .w15_sha256(w15_sha256),
        
        // Initial hash values
        .A_i(A_i), .B_i(B_i), .C_i(C_i), .D_i(D_i),
        .E_i(E_i), .F_i(F_i), .G_i(G_i), .H_i(H_i),
        
        // Outputs
        .sha256_result(sha256_result),
        .sha256_done(sha256_done)
    );
    
    // Clock generation
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end
    
    // Test counter for debugging
    integer cycle_count = 0;
    always @(posedge clk) begin
        cycle_count = cycle_count + 1;
    end
    
    initial begin
        // Initialize VCD dump
        $dumpfile("sha256_test.vcd");
        $dumpvars(0, SHA256_tb);
        
        // Initialize all inputs
        reset = 0;
        start_in = 0;
        
        // Initialize message words to zero
        w0_sha256 = 32'h0; w1_sha256 = 32'h0; w2_sha256 = 32'h0; w3_sha256 = 32'h0;
        w4_sha256 = 32'h0; w5_sha256 = 32'h0; w6_sha256 = 32'h0; w7_sha256 = 32'h0;
        w8_sha256 = 32'h0; w9_sha256 = 32'h0; w10_sha256 = 32'h0; w11_sha256 = 32'h0;
        w12_sha256 = 32'h0; w13_sha256 = 32'h0; w14_sha256 = 32'h0; w15_sha256 = 32'h0;
        
        // Initialize with SHA-256 initial hash values
        A_i = 32'h6A09E667; B_i = 32'hBB67AE85; C_i = 32'h3C6EF372; D_i = 32'hA54FF53A;
        E_i = 32'h510E527F; F_i = 32'h9B05688C; G_i = 32'h1F83D9AB; H_i = 32'h5BE0CD19;
        
        // Apply reset
        $display("=== SHA-256 Test Bench Started ===");
        $display("Time: %0t | Applying reset...", $time);
        #10;
        reset = 1;
        #20;
        
        //========================================================================
        // Test Case 1: "abc" message
        // Expected: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
        //========================================================================
        $display("\n=== Test Case 1: Message 'abc' ===");
        
        // Setup message "abc" with padding
        // "abc" = 0x61626380 followed by zeros, with length 24 bits at the end
        w0_sha256 = 32'h61626380;  // "abc" + padding bit
        w1_sha256 = 32'h00000000; w2_sha256 = 32'h00000000; w3_sha256 = 32'h00000000;
        w4_sha256 = 32'h00000000; w5_sha256 = 32'h00000000; w6_sha256 = 32'h00000000; w7_sha256 = 32'h00000000;
        w8_sha256 = 32'h00000000; w9_sha256 = 32'h00000000; w10_sha256 = 32'h00000000; w11_sha256 = 32'h00000000;
        w12_sha256 = 32'h00000000; w13_sha256 = 32'h00000000; w14_sha256 = 32'h00000000; 
        w15_sha256 = 32'h00000018;  // Length: 24 bits (3 bytes)
        
        expected_result = 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad;
        
        $display("Input message: 'abc'");
        $display("W0=%08h W1=%08h W2=%08h W3=%08h", w0_sha256, w1_sha256, w2_sha256, w3_sha256);
        $display("W15=%08h (length)", w15_sha256);
        
        // Start SHA-256 computation
        start_in = 1;
        $display("Time: %0t | Starting SHA-256 computation...", $time);
        
        // Wait for computation to complete
        wait(sha256_done == 1);
        $display("Time: %0t | SHA-256 computation completed!", $time);
        $display("Cycles taken: %0d", cycle_count);
        
        // Display results
        $display("Result   : %064h", sha256_result);
        $display("Expected : %064h", expected_result);
        
        if (sha256_result == expected_result) begin
            $display("✓ Test Case 1 PASSED!");
        end else begin
            $display("✗ Test Case 1 FAILED!");
        end
        
        // Stop start signal
        start_in = 0;
        #20;
        
        //========================================================================
        // Test Case 2: "hello world" message  
        // Expected: b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9
        //========================================================================
        $display("\n=== Test Case 2: Message 'hello world' ===");
        
        // Reset cycle counter
        cycle_count = 0;
        
        // Setup message "hello world" with padding
        // "hello world" = 88 bits, needs padding
        w0_sha256 = 32'h68656C6C;  // "hell"
        w1_sha256 = 32'h6F20776F;  // "o wo"  
        w2_sha256 = 32'h726C6480;  // "rld" + padding bit
        w3_sha256 = 32'h00000000; w4_sha256 = 32'h00000000; w5_sha256 = 32'h00000000; w6_sha256 = 32'h00000000; w7_sha256 = 32'h00000000;
        w8_sha256 = 32'h00000000; w9_sha256 = 32'h00000000; w10_sha256 = 32'h00000000; w11_sha256 = 32'h00000000;
        w12_sha256 = 32'h00000000; w13_sha256 = 32'h00000000; w14_sha256 = 32'h00000000; 
        w15_sha256 = 32'h00000058;  // Length: 88 bits (11 bytes)
        
        expected_result = 256'hb94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9;
        
        $display("Input message: 'hello world'");
        $display("W0=%08h W1=%08h W2=%08h", w0_sha256, w1_sha256, w2_sha256);
        $display("W15=%08h (length)", w15_sha256);
        
        // Start SHA-256 computation
        start_in = 1;
        $display("Time: %0t | Starting SHA-256 computation...", $time);
        
        // Wait for completion
        wait(sha256_done == 1);
        $display("Time: %0t | SHA-256 computation completed!", $time);
        $display("Cycles taken: %0d", cycle_count);
        
        // Display results
        $display("Result   : %064h", sha256_result);
        $display("Expected : %064h", expected_result);
        
        if (sha256_result == expected_result) begin
            $display("✓ Test Case 2 PASSED!");
        end else begin
            $display("✗ Test Case 2 FAILED!");
        end
        
        start_in = 0;
        #20;
        
        //========================================================================
        // Test Case 3: Empty string "" 
        // Expected: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
        //========================================================================
        $display("\n=== Test Case 3: Empty string ===");
        
        // Reset cycle counter
        cycle_count = 0;
        
        // Empty string with just padding
        w0_sha256 = 32'h80000000;  // Just the padding bit
        w1_sha256 = 32'h00000000; w2_sha256 = 32'h00000000; w3_sha256 = 32'h00000000;
        w4_sha256 = 32'h00000000; w5_sha256 = 32'h00000000; w6_sha256 = 32'h00000000; w7_sha256 = 32'h00000000;
        w8_sha256 = 32'h00000000; w9_sha256 = 32'h00000000; w10_sha256 = 32'h00000000; w11_sha256 = 32'h00000000;
        w12_sha256 = 32'h00000000; w13_sha256 = 32'h00000000; w14_sha256 = 32'h00000000; 
        w15_sha256 = 32'h00000000;  // Length: 0 bits
        
        expected_result = 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;
        
        $display("Input message: '' (empty string)");
        $display("W0=%08h (padding)", w0_sha256);
        $display("W15=%08h (length)", w15_sha256);
        
        start_in = 1;
        $display("Time: %0t | Starting SHA-256 computation...", $time);
        
        wait(sha256_done == 1);
        $display("Time: %0t | SHA-256 computation completed!", $time);
        $display("Cycles taken: %0d", cycle_count);
        
        $display("Result   : %064h", sha256_result);
        $display("Expected : %064h", expected_result);
        
        if (sha256_result == expected_result) begin
            $display("✓ Test Case 3 PASSED!");
        end else begin
            $display("✗ Test Case 3 FAILED!");
        end
        
        start_in = 0;
        #20;
        
        $display("\n=== All tests completed ===");
        $display("Simulation finished at time: %0t", $time);
        
        // End simulation
        #100;
        $finish;
    end
    
    // Timeout watchdog (in case the design hangs)
    initial begin
        #50000; // 50,000 time units timeout
        $display("ERROR: Simulation timeout!");
        $finish;
    end
    
    // Monitor key signals during simulation
    always @(posedge clk) begin
        if (start_in && !sha256_done) begin
            if (cycle_count % 100 == 0) begin
                $display("Time: %0t | Cycle: %0d | Still processing...", $time, cycle_count);
            end
        end
    end

endmodule