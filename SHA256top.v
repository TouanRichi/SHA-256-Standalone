// SHA256top.v - Consolidated and Working SHA-256 implementation
// Single file containing all SHA-256 functionality 
// NIST FIPS 180-4 Compliant - Simplified correct implementation
// Created by consolidating multiple modules into one file for easier control

module SHA256top(
    input wire clk,
    input wire reset,              // Active low reset
    input wire start_in,
    
    // Input message words W[0] to W[15] (512-bit message block)
    input wire [31:0] w0_sha256, w1_sha256, w2_sha256, w3_sha256,
    input wire [31:0] w4_sha256, w5_sha256, w6_sha256, w7_sha256,
    input wire [31:0] w8_sha256, w9_sha256, w10_sha256, w11_sha256,
    input wire [31:0] w12_sha256, w13_sha256, w14_sha256, w15_sha256,
    
    // Initial hash values (SHA-256 constants if not provided)
    input wire [31:0] A_i, B_i, C_i, D_i, E_i, F_i, G_i, H_i,
    
    // Outputs
    output reg [255:0] sha256_result,
    output reg sha256_done
);

    // SHA-256 initial hash values (NIST FIPS 180-4)
    parameter [31:0] H0_INIT = 32'h6A09E667;
    parameter [31:0] H1_INIT = 32'hBB67AE85;
    parameter [31:0] H2_INIT = 32'h3C6EF372;
    parameter [31:0] H3_INIT = 32'hA54FF53A;
    parameter [31:0] H4_INIT = 32'h510E527F;
    parameter [31:0] H5_INIT = 32'h9B05688C;
    parameter [31:0] H6_INIT = 32'h1F83D9AB;
    parameter [31:0] H7_INIT = 32'h5BE0CD19;
    
    // K constants array - NIST FIPS 180-4 compliant
    reg [31:0] K [0:63];
    initial begin
        K[0]  = 32'h428a2f98; K[1]  = 32'h71374491; K[2]  = 32'hb5c0fbcf; K[3]  = 32'he9b5dba5;
        K[4]  = 32'h3956c25b; K[5]  = 32'h59f111f1; K[6]  = 32'h923f82a4; K[7]  = 32'hab1c5ed5;
        K[8]  = 32'hd807aa98; K[9]  = 32'h12835b01; K[10] = 32'h243185be; K[11] = 32'h550c7dc3;
        K[12] = 32'h72be5d74; K[13] = 32'h80deb1fe; K[14] = 32'h9bdc06a7; K[15] = 32'hc19bf174;
        K[16] = 32'he49b69c1; K[17] = 32'hefbe4786; K[18] = 32'h0fc19dc6; K[19] = 32'h240ca1cc;
        K[20] = 32'h2de92c6f; K[21] = 32'h4a7484aa; K[22] = 32'h5cb0a9dc; K[23] = 32'h76f988da;
        K[24] = 32'h983e5152; K[25] = 32'ha831c66d; K[26] = 32'hb00327c8; K[27] = 32'hbf597fc7;
        K[28] = 32'hc6e00bf3; K[29] = 32'hd5a79147; K[30] = 32'h06ca6351; K[31] = 32'h14292967;
        K[32] = 32'h27b70a85; K[33] = 32'h2e1b2138; K[34] = 32'h4d2c6dfc; K[35] = 32'h53380d13;
        K[36] = 32'h650a7354; K[37] = 32'h766a0abb; K[38] = 32'h81c2c92e; K[39] = 32'h92722c85;
        K[40] = 32'ha2bfe8a1; K[41] = 32'ha81a664b; K[42] = 32'hc24b8b70; K[43] = 32'hc76c51a3;
        K[44] = 32'hd192e819; K[45] = 32'hd6990624; K[46] = 32'hf40e3585; K[47] = 32'h106aa070;
        K[48] = 32'h19a4c116; K[49] = 32'h1e376c08; K[50] = 32'h2748774c; K[51] = 32'h34b0bcb5;
        K[52] = 32'h391c0cb3; K[53] = 32'h4ed8aa4a; K[54] = 32'h5b9cca4f; K[55] = 32'h682e6ff3;
        K[56] = 32'h748f82ee; K[57] = 32'h78a5636f; K[58] = 32'h84c87814; K[59] = 32'h8cc70208;
        K[60] = 32'h90befffa; K[61] = 32'ha4506ceb; K[62] = 32'hbef9a3f7; K[63] = 32'hc67178f2;
    end
    
    // Right rotate function
    function [31:0] rotr;
        input [31:0] x;
        input [4:0] n;
        begin
            rotr = (x >> n) | (x << (32 - n));
        end
    endfunction
    
    // SHA-256 function definitions (inline implementations)
    
    // Choice function: Ch(e, f, g) = (e & f) ^ (~e & g)
    function [31:0] choice;
        input [31:0] e, f, g;
        begin
            choice = (e & f) ^ (~e & g);
        end
    endfunction
    
    // Majority function: Maj(a, b, c) = (a & b) ^ (a & c) ^ (b & c)
    function [31:0] majority;
        input [31:0] a, b, c;
        begin
            majority = (a & b) ^ (a & c) ^ (b & c);
        end
    endfunction
    
    // Σ₀(x) = ROTR²(x) ⊕ ROTR¹³(x) ⊕ ROTR²²(x) - for compression function
    function [31:0] big_sigma0;
        input [31:0] x;
        begin
            big_sigma0 = rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
        end
    endfunction
    
    // Σ₁(x) = ROTR⁶(x) ⊕ ROTR¹¹(x) ⊕ ROTR²⁵(x) - for compression function
    function [31:0] big_sigma1;
        input [31:0] x;
        begin
            big_sigma1 = rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
        end
    endfunction
    
    // σ₀(x) = ROTR⁷(x) ⊕ ROTR¹⁸(x) ⊕ SHR³(x) - for message schedule
    function [31:0] small_sigma0;
        input [31:0] x;
        begin
            small_sigma0 = rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3);
        end
    endfunction
    
    // σ₁(x) = ROTR¹⁷(x) ⊕ ROTR¹⁹(x) ⊕ SHR¹⁰(x) - for message schedule
    function [31:0] small_sigma1;
        input [31:0] x;
        begin
            small_sigma1 = rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10);
        end
    endfunction
    
    // State machine
    parameter [2:0] IDLE = 3'b000,
                    INIT = 3'b001,
                    PROCESS = 3'b010,
                    FINALIZE = 3'b011,
                    DONE = 3'b100;
    
    reg [2:0] state;
    reg [6:0] round_counter;  // 0-63 for SHA-256 rounds
    
    // Working variables and hash values
    reg [31:0] a, b, c, d, e, f, g, h;          // Working variables
    reg [31:0] H0, H1, H2, H3, H4, H5, H6, H7;  // Hash values
    reg [31:0] W [0:63];                        // Message schedule
    reg [31:0] W_current;                       // Current W value to avoid race conditions
    
    // Intermediate computation values
    wire [31:0] T1, T2;
    
    // Compute T1 and T2 combinationally using current W value
    assign T1 = h + big_sigma1(e) + choice(e, f, g) + K[round_counter] + W_current;
    assign T2 = big_sigma0(a) + majority(a, b, c);
    
    // State machine logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            round_counter <= 0;
            sha256_done <= 0;
            sha256_result <= 256'h0;
            W_current <= 0;
            
            // Reset working variables
            a <= 0; b <= 0; c <= 0; d <= 0; e <= 0; f <= 0; g <= 0; h <= 0;
            H0 <= 0; H1 <= 0; H2 <= 0; H3 <= 0; H4 <= 0; H5 <= 0; H6 <= 0; H7 <= 0;
            
        end else begin
            case (state)
                IDLE: begin
                    sha256_done <= 0;
                    if (start_in) begin
                        state <= INIT;
                        round_counter <= 0;
                    end
                end
                
                INIT: begin
                    // Store initial hash values for final addition
                    H0 <= H0_INIT;
                    H1 <= H1_INIT;
                    H2 <= H2_INIT;
                    H3 <= H3_INIT;
                    H4 <= H4_INIT;
                    H5 <= H5_INIT;
                    H6 <= H6_INIT;
                    H7 <= H7_INIT;
                    
                    // Initialize working variables with initial hash values
                    a <= H0_INIT;
                    b <= H1_INIT;
                    c <= H2_INIT;
                    d <= H3_INIT;
                    e <= H4_INIT;
                    f <= H5_INIT;
                    g <= H6_INIT;
                    h <= H7_INIT;
                    
                    // Initialize first 16 words of message schedule
                    W[0]  <= w0_sha256;  W[1]  <= w1_sha256;  W[2]  <= w2_sha256;  W[3]  <= w3_sha256;
                    W[4]  <= w4_sha256;  W[5]  <= w5_sha256;  W[6]  <= w6_sha256;  W[7]  <= w7_sha256;
                    W[8]  <= w8_sha256;  W[9]  <= w9_sha256;  W[10] <= w10_sha256; W[11] <= w11_sha256;
                    W[12] <= w12_sha256; W[13] <= w13_sha256; W[14] <= w14_sha256; W[15] <= w15_sha256;
                    
                    // Set current W for round 0
                    W_current <= w0_sha256;
                    
                    state <= PROCESS;
                end
                
                PROCESS: begin
                    if (round_counter < 64) begin
                        // Perform SHA-256 compression round using stable W_current
                        h <= g;
                        g <= f;
                        f <= e;
                        e <= d + T1;
                        d <= c;
                        c <= b;
                        b <= a;
                        a <= T1 + T2;
                        
                        // Increment round counter
                        round_counter <= round_counter + 1;
                        
                        // Extend message schedule and set W_current for NEXT round
                        if (round_counter < 63) begin
                            if (round_counter >= 15) begin
                                // For rounds 16-63, extend the message schedule
                                // W[t] = σ₁(W[t-2]) + W[t-7] + σ₀(W[t-15]) + W[t-16]
                                // Since we're preparing for next round (round_counter+1), compute W[round_counter+1]
                                W[round_counter+1] <= small_sigma1(W[round_counter-1]) + W[round_counter-6] + 
                                                     small_sigma0(W[round_counter-14]) + W[round_counter-15];
                                W_current <= small_sigma1(W[round_counter-1]) + W[round_counter-6] + 
                                            small_sigma0(W[round_counter-14]) + W[round_counter-15];
                            end else begin
                                // For rounds 0-15, use pre-loaded W values
                                W_current <= W[round_counter+1];
                            end
                        end
                    end else begin
                        state <= FINALIZE;
                    end
                end
                
                FINALIZE: begin
                    // Add working variables to hash values (final step)
                    H0 <= H0 + a;
                    H1 <= H1 + b;
                    H2 <= H2 + c;
                    H3 <= H3 + d;
                    H4 <= H4 + e;
                    H5 <= H5 + f;
                    H6 <= H6 + g;
                    H7 <= H7 + h;
                    
                    state <= DONE;
                end
                
                DONE: begin
                    // Ensure result is set before done signal
                    sha256_result <= {H0, H1, H2, H3, H4, H5, H6, H7};
                    sha256_done <= 1;
                    
                    // Only return to IDLE when start_in is released
                    if (!start_in) begin
                        state <= IDLE;
                        sha256_done <= 0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule