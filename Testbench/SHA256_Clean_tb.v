`timescale 1ns / 1ps

// Simple testbench to test the clean SHA-256 implementation
module SHA256_Clean_tb();

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
    
    // Instantiate the clean SHA-256 module
    SHA256_Top_Clean uut (
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
        if (start_in && !sha256_done)
            cycle_count = cycle_count + 1;
    end
    
    initial begin
        // Initialize VCD dump
        $dumpfile("sha256_clean_test.vcd");
        $dumpvars(0, SHA256_Clean_tb);
        
        // Initialize all inputs
        reset = 0;
        start_in = 0;
        
        // Initialize message words to zero
        w0_sha256 = 32'h0; w1_sha256 = 32'h0; w2_sha256 = 32'h0; w3_sha256 = 32'h0;
        w4_sha256 = 32'h0; w5_sha256 = 32'h0; w6_sha256 = 32'h0; w7_sha256 = 32'h0;
        w8_sha256 = 32'h0; w9_sha256 = 32'h0; w10_sha256 = 32'h0; w11_sha256 = 32'h0;
        w12_sha256 = 32'h0; w13_sha256 = 32'h0; w14_sha256 = 32'h0; w15_sha256 = 32'h0;
        
        // Initialize with SHA-256 initial hash values (use 0 to trigger defaults)
        A_i = 32'h0; B_i = 32'h0; C_i = 32'h0; D_i = 32'h0;
        E_i = 32'h0; F_i = 32'h0; G_i = 32'h0; H_i = 32'h0;
        
        // Apply reset
        $display("=== Clean SHA-256 Test Bench Started ===");
        $display("Time: %0t | Applying reset...", $time);
        #10;
        reset = 1;
        #20;
        
        //========================================================================
        // Test Case 1: "abc" message
        // Expected: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
        //========================================================================
        $display("\n=== Test Case 1: Message 'abc' ===");
        
        cycle_count = 0;
        
        // Setup message "abc" with padding
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
        $display("State: %b, H0=%08h, H1=%08h", uut.state, uut.H0, uut.H1);
        
        if (sha256_result == expected_result) begin
            $display("✓ Test Case 1 PASSED!");
        end else begin
            $display("✗ Test Case 1 FAILED!");
        end
        
        // Stop start signal
        start_in = 0;
        #20;
        
        $display("\n=== Test completed ===");
        $display("Simulation finished at time: %0t", $time);
        
        // End simulation
        #100;
        $finish;
    end
    
    // Timeout watchdog (in case the design hangs)
    initial begin
        #10000; // 10,000 time units timeout
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule