// SHA256_Top_Clean.v - Clean SHA-256 implementation following NIST FIPS 180-4
// This is a simplified, correct implementation for debugging and verification
// Vivado 2020.1 compatible - Verilog-2001 syntax

module SHA256_Top_Clean(
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
    
    // K constants - use a function to return the constant for each round
    function [31:0] get_K;
        input [5:0] round;
        begin
            case (round)
                6'd0:  get_K = 32'h428a2f98; 6'd1:  get_K = 32'h71374491; 6'd2:  get_K = 32'hb5c0fbcf; 6'd3:  get_K = 32'he9b5dba5;
                6'd4:  get_K = 32'h3956c25b; 6'd5:  get_K = 32'h59f111f1; 6'd6:  get_K = 32'h923f82a4; 6'd7:  get_K = 32'hab1c5ed5;
                6'd8:  get_K = 32'hd807aa98; 6'd9:  get_K = 32'h12835b01; 6'd10: get_K = 32'h243185be; 6'd11: get_K = 32'h550c7dc3;
                6'd12: get_K = 32'h72be5d74; 6'd13: get_K = 32'h80deb1fe; 6'd14: get_K = 32'h9bdc06a7; 6'd15: get_K = 32'hc19bf174;
                6'd16: get_K = 32'he49b69c1; 6'd17: get_K = 32'hefbe4786; 6'd18: get_K = 32'h0fc19dc6; 6'd19: get_K = 32'h240ca1cc;
                6'd20: get_K = 32'h2de92c6f; 6'd21: get_K = 32'h4a7484aa; 6'd22: get_K = 32'h5cb0a9dc; 6'd23: get_K = 32'h76f988da;
                6'd24: get_K = 32'h983e5152; 6'd25: get_K = 32'ha831c66d; 6'd26: get_K = 32'hb00327c8; 6'd27: get_K = 32'hbf597fc7;
                6'd28: get_K = 32'hc6e00bf3; 6'd29: get_K = 32'hd5a79147; 6'd30: get_K = 32'h06ca6351; 6'd31: get_K = 32'h14292967;
                6'd32: get_K = 32'h27b70a85; 6'd33: get_K = 32'h2e1b2138; 6'd34: get_K = 32'h4d2c6dfc; 6'd35: get_K = 32'h53380d13;
                6'd36: get_K = 32'h650a7354; 6'd37: get_K = 32'h766a0abb; 6'd38: get_K = 32'h81c2c92e; 6'd39: get_K = 32'h92722c85;
                6'd40: get_K = 32'ha2bfe8a1; 6'd41: get_K = 32'ha81a664b; 6'd42: get_K = 32'hc24b8b70; 6'd43: get_K = 32'hc76c51a3;
                6'd44: get_K = 32'hd192e819; 6'd45: get_K = 32'hd6990624; 6'd46: get_K = 32'hf40e3585; 6'd47: get_K = 32'h106aa070;
                6'd48: get_K = 32'h19a4c116; 6'd49: get_K = 32'h1e376c08; 6'd50: get_K = 32'h2748774c; 6'd51: get_K = 32'h34b0bcb5;
                6'd52: get_K = 32'h391c0cb3; 6'd53: get_K = 32'h4ed8aa4a; 6'd54: get_K = 32'h5b9cca4f; 6'd55: get_K = 32'h682e6ff3;
                6'd56: get_K = 32'h748f82ee; 6'd57: get_K = 32'h78a5636f; 6'd58: get_K = 32'h84c87814; 6'd59: get_K = 32'h8cc70208;
                6'd60: get_K = 32'h90befffa; 6'd61: get_K = 32'ha4506ceb; 6'd62: get_K = 32'hbef9a3f7; 6'd63: get_K = 32'hc67178f2;
                default: get_K = 32'h00000000;
            endcase
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
    
    // Intermediate computation values
    wire [31:0] ch_out, maj_out, sigma0_out, sigma1_out;
    wire [31:0] s0_out, s1_out;  // For message schedule
    wire [31:0] T1, T2;
    
    // SHA-256 functions using existing modules
    Choice ch_inst (.e(e), .f(f), .g(g), .out(ch_out));
    Majority maj_inst (.A(a), .B(b), .C(c), .M(maj_out));
    Sigma0 sigma0_inst (.a(a), .out(sigma0_out));
    Sigma1 sigma1_inst (.e(e), .out(sigma1_out));
    
    // Message schedule functions - need to check bounds
    wire [31:0] w_minus_15 = (round_counter >= 15) ? W[round_counter-15] : 32'h0;
    wire [31:0] w_minus_2 = (round_counter >= 2) ? W[round_counter-2] : 32'h0;
    sigma0 s0_inst (.x(w_minus_15), .out(s0_out));
    sigma1 s1_inst (.x(w_minus_2), .out(s1_out));
    
    // Compute T1 and T2
    assign T1 = h + sigma1_out + ch_out + get_K(round_counter[5:0]) + W[round_counter];
    assign T2 = sigma0_out + maj_out;
    
    // Main state machine
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            round_counter <= 0;
            sha256_done <= 0;
            sha256_result <= 256'h0;
            
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
                    
                    // Initialize remaining W values to 0
                    W[16] <= 0; W[17] <= 0; W[18] <= 0; W[19] <= 0; W[20] <= 0; W[21] <= 0; W[22] <= 0; W[23] <= 0;
                    W[24] <= 0; W[25] <= 0; W[26] <= 0; W[27] <= 0; W[28] <= 0; W[29] <= 0; W[30] <= 0; W[31] <= 0;
                    W[32] <= 0; W[33] <= 0; W[34] <= 0; W[35] <= 0; W[36] <= 0; W[37] <= 0; W[38] <= 0; W[39] <= 0;
                    W[40] <= 0; W[41] <= 0; W[42] <= 0; W[43] <= 0; W[44] <= 0; W[45] <= 0; W[46] <= 0; W[47] <= 0;
                    W[48] <= 0; W[49] <= 0; W[50] <= 0; W[51] <= 0; W[52] <= 0; W[53] <= 0; W[54] <= 0; W[55] <= 0;
                    W[56] <= 0; W[57] <= 0; W[58] <= 0; W[59] <= 0; W[60] <= 0; W[61] <= 0; W[62] <= 0; W[63] <= 0;
                    
                    state <= PROCESS;
                end
                
                PROCESS: begin
                    if (round_counter < 64) begin
                        // Extend message schedule for rounds 16-63
                        if (round_counter >= 16) begin
                            W[round_counter] <= s1_out + W[round_counter-7] + s0_out + W[round_counter-16];
                        end
                        
                        // Perform SHA-256 round
                        h <= g;
                        g <= f;
                        f <= e;
                        e <= d + T1;
                        d <= c;
                        c <= b;
                        b <= a;
                        a <= T1 + T2;
                        
                        round_counter <= round_counter + 1;
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
                    sha256_result <= {H0, H1, H2, H3, H4, H5, H6, H7};
                    sha256_done <= 1;
                    
                    if (!start_in) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule