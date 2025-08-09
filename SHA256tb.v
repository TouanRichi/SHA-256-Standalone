`timescale 1ns / 1ps

// SHA256tb.v - Consolidated testbench for SHA-256 implementation
// Tests multiple SHA-256 test vectors to ensure correctness
// Consolidated from multiple testbench files for easier control

module SHA256tb();

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
    
    // Test result tracking
    integer passed_tests = 0;
    integer total_tests = 0;
    
    // Instantiate the consolidated SHA-256 module
    SHA256top uut (
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
    
    // Task to run a single test case
    task run_test;
        input [8*50:1] test_name;
        input [255:0] expected;
        begin
            total_tests = total_tests + 1;
            cycle_count = 0;
            expected_result = expected;
            
            $display("\n=== %s ===", test_name);
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
                $display("✓ %s PASSED!", test_name);
                passed_tests = passed_tests + 1;
            end else begin
                $display("✗ %s FAILED!", test_name);
                $display("  Difference found in hash computation");
            end
            
            // Stop start signal and wait
            start_in = 0;
            #20;
        end
    endtask
    
    // Task to clear message words
    task clear_message;
        begin
            w0_sha256 = 32'h00000000; w1_sha256 = 32'h00000000; w2_sha256 = 32'h00000000; w3_sha256 = 32'h00000000;
            w4_sha256 = 32'h00000000; w5_sha256 = 32'h00000000; w6_sha256 = 32'h00000000; w7_sha256 = 32'h00000000;
            w8_sha256 = 32'h00000000; w9_sha256 = 32'h00000000; w10_sha256 = 32'h00000000; w11_sha256 = 32'h00000000;
            w12_sha256 = 32'h00000000; w13_sha256 = 32'h00000000; w14_sha256 = 32'h00000000; w15_sha256 = 32'h00000000;
        end
    endtask
    
    initial begin
        // Initialize VCD dump
        $dumpfile("sha256_test.vcd");
        $dumpvars(0, SHA256tb);
        
        // Initialize all inputs
        reset = 0;
        start_in = 0;
        clear_message();
        
        // Initialize with SHA-256 initial hash values (use 0 to trigger defaults)
        A_i = 32'h0; B_i = 32'h0; C_i = 32'h0; D_i = 32'h0;
        E_i = 32'h0; F_i = 32'h0; G_i = 32'h0; H_i = 32'h0;
        
        // Apply reset
        $display("=== Consolidated SHA-256 Test Bench Started ===");
        $display("Time: %0t | Applying reset...", $time);
        #10;
        reset = 1;
        #20;
        
        //========================================================================
        // Test Case 1: "abc" message
        // Expected: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
        //========================================================================
        clear_message();
        w0_sha256 = 32'h61626380;  // "abc" + padding bit
        w15_sha256 = 32'h00000018;  // Length: 24 bits (3 bytes)
        
        run_test("Test Case 1: Message 'abc'", 
                 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad);
        
        //========================================================================
        // Test Case 2: "hello world" message  
        // Expected: b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9
        //========================================================================
        clear_message();
        w0_sha256 = 32'h68656C6C;  // "hell"
        w1_sha256 = 32'h6F20776F;  // "o wo"  
        w2_sha256 = 32'h726C6480;  // "rld" + padding bit
        w15_sha256 = 32'h00000058;  // Length: 88 bits (11 bytes)
        
        run_test("Test Case 2: Message 'hello world'", 
                 256'hb94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9);
        
        //========================================================================
        // Test Case 3: Empty string "" 
        // Expected: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
        //========================================================================
        clear_message();
        w0_sha256 = 32'h80000000;  // Just padding bit at the beginning
        w15_sha256 = 32'h00000000;  // Length: 0 bits (0 bytes)
        
        run_test("Test Case 3: Empty string", 
                 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855);
        
        //========================================================================
        // Test Case 4: "a" message
        // Expected: ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb
        //========================================================================
        clear_message();
        w0_sha256 = 32'h61800000;  // "a" + padding bit
        w15_sha256 = 32'h00000008;  // Length: 8 bits (1 byte)
        
        run_test("Test Case 4: Message 'a'", 
                 256'hca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb);
        
        //========================================================================
        // Test Case 5: "message digest" 
        // Expected: f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650
        //========================================================================
        clear_message();
        w0_sha256 = 32'h6D657373;  // "mess"
        w1_sha256 = 32'h61676520;  // "age "
        w2_sha256 = 32'h64696765;  // "dige"
        w3_sha256 = 32'h73748000;  // "st" + padding bit
        w15_sha256 = 32'h00000070;  // Length: 112 bits (14 bytes)
        
        run_test("Test Case 5: Message 'message digest'", 
                 256'hf7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650);
        
        //========================================================================
        // Test Case 6: "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
        // Expected: 248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1
        //========================================================================
        clear_message();
        w0_sha256 = 32'h61626364;  // "abcd"
        w1_sha256 = 32'h62636465;  // "bcde"
        w2_sha256 = 32'h63646566;  // "cdef"
        w3_sha256 = 32'h64656667;  // "defg"
        w4_sha256 = 32'h65666768;  // "efgh"
        w5_sha256 = 32'h66676869;  // "fghi"
        w6_sha256 = 32'h6768696A;  // "ghij"
        w7_sha256 = 32'h68696A6B;  // "hijk"
        w8_sha256 = 32'h696A6B6C;  // "ijkl"
        w9_sha256 = 32'h6A6B6C6D;  // "jklm"
        w10_sha256 = 32'h6B6C6D6E; // "klmn"
        w11_sha256 = 32'h6C6D6E6F; // "lmno"
        w12_sha256 = 32'h6D6E6F70; // "mnop"
        w13_sha256 = 32'h6E6F7071; // "nopq"
        w14_sha256 = 32'h80000000; // padding bit
        w15_sha256 = 32'h000001C0; // Length: 448 bits (56 bytes)
        
        run_test("Test Case 6: Long message", 
                 256'h248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1);
        
        //========================================================================
        // Display final results
        //========================================================================
        $display("\n=== Test Summary ===");
        $display("Total tests: %0d", total_tests);
        $display("Passed: %0d", passed_tests);
        $display("Failed: %0d", total_tests - passed_tests);
        
        if (passed_tests == total_tests) begin
            $display("✓ ALL TESTS PASSED!");
        end else begin
            $display("✗ Some tests failed!");
        end
        
        $display("Simulation finished at time: %0t", $time);
        
        // End simulation
        #100;
        $finish;
    end
    
    // Timeout watchdog (in case the design hangs)
    initial begin
        #50000; // 50,000 time units timeout (should be enough for all tests)
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule