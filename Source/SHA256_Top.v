// SHA-256 Standalone Complete Implementation
// Extracted and adapted from RISC_SHA system with full functionality
// NIST FIPS 180-4 Compliant

module SHA256_Top(
    input clk,
    input reset,
    input start_in,
    
    // Input message words W[0] to W[15] (512-bit message block)
    input [31:0] w0_sha256,
    input [31:0] w1_sha256,
    input [31:0] w2_sha256,
    input [31:0] w3_sha256,
    input [31:0] w4_sha256,
    input [31:0] w5_sha256,
    input [31:0] w6_sha256,
    input [31:0] w7_sha256,
    input [31:0] w8_sha256,
    input [31:0] w9_sha256,
    input [31:0] w10_sha256,
    input [31:0] w11_sha256,
    input [31:0] w12_sha256,
    input [31:0] w13_sha256,
    input [31:0] w14_sha256,
    input [31:0] w15_sha256,
    
    // Initial hash values (optional, uses SHA-256 constants if not provided)
    input [31:0] A_i,
    input [31:0] B_i,
    input [31:0] C_i,
    input [31:0] D_i,
    input [31:0] E_i,
    input [31:0] F_i,
    input [31:0] G_i,
    input [31:0] H_i,
    
    // Outputs
    output [255:0] sha256_result,
    output sha256_done
);

// FSM Control Signals
wire start_sha_o_w;
wire sel_mux_w;
wire ena_K_reg_w;
wire sel_parise_mux_w;
wire [31:0] reg16_out_w;
wire [31:0] A_o_w, B_o_w, C_o_w, D_o_w;
wire [31:0] E_o_w, F_o_w, G_o_w, H_o_w;

// Main processing signals
wire [31:0] data_o_mux_w;
wire [31:0] data_o_reg0_w, data_o2_reg0_w, data_regH_o_w;
wire sel_mux_o_w;

// Shift register signals (W expansion)
wire [31:0] data_o_reg1_w, data_o_reg2_w, data_o_reg3_w, data_o_reg4_w;
wire [31:0] data_o_reg5_w, data_o_reg6_w, data_o_reg7_w, data_o_reg8_w;
wire [31:0] data_o_reg9_w, data_o_reg10_w, data_o_reg11_w, data_o_reg12_w;
wire [31:0] data_o_reg13_w, data_o_reg14_w, data_o_reg15_w;

// Hash computation signals
wire [31:0] delta0_out_w, delta1_out_w, data_o_adder_w;
wire [31:0] k_reg_o_w, data_o_adder1_w;

// Working variables
wire [31:0] reg_A_o_w, reg_B_o_w, reg_C_o_w, reg_D_o_w;
wire [31:0] reg_E_o_w, reg_F_o_w, reg_G_o_w, reg_H_o_w;

// Computation intermediate signals
wire [31:0] data_o_CH_w, data_o_sigma1_w, data_o_adder2_w;
wire [31:0] data_o_adder3_w, data_o_Maj_w, data_o_sigma0_w, data_o_adder4_w;

// Pairwise mux signals
wire [31:0] pairwise_mux_a_out_w, pairwise_mux_b_out_w, pairwise_mux_c_out_w, pairwise_mux_d_out_w;
wire [31:0] pairwise_mux_e_out_w, pairwise_mux_f_out_w, pairwise_mux_g_out_w, pairwise_mux_h_out_w;

wire data_o_reg32_w; // 1 bit
wire done_Sha_w;

//========================================================================
// FSM Controller - Controls the entire SHA-256 computation process
//========================================================================
fsm_controller fsm_controller (
    .clk(clk),
    .rst(reset),
    .start_sha(start_in),

    // Input message words
    .w0_sha256(w0_sha256), .w1_sha256(w1_sha256), .w2_sha256(w2_sha256), .w3_sha256(w3_sha256),
    .w4_sha256(w4_sha256), .w5_sha256(w5_sha256), .w6_sha256(w6_sha256), .w7_sha256(w7_sha256),
    .w8_sha256(w8_sha256), .w9_sha256(w9_sha256), .w10_sha256(w10_sha256), .w11_sha256(w11_sha256),
    .w12_sha256(w12_sha256), .w13_sha256(w13_sha256), .w14_sha256(w14_sha256), .w15_sha256(w15_sha256),

    // SHA-512 inputs (not used for SHA-256, tied to zero)
    .w0_sha512(64'h0), .w1_sha512(64'h0), .w2_sha512(64'h0), .w3_sha512(64'h0),
    .w4_sha512(64'h0), .w5_sha512(64'h0), .w6_sha512(64'h0), .w7_sha512(64'h0),
    .w8_sha512(64'h0), .w9_sha512(64'h0), .w10_sha512(64'h0), .w11_sha512(64'h0),
    .w12_sha512(64'h0), .w13_sha512(64'h0), .w14_sha512(64'h0), .w15_sha512(64'h0),

    // Initial hash values  
    .A_i(A_i), .B_i(B_i), .C_i(C_i), .D_i(D_i),
    .E_i(E_i), .F_i(F_i), .G_i(G_i), .H_i(H_i),

    // SHA-512 initial values (not used)
    .A_i2(64'h0), .B_i2(64'h0), .C_i2(64'h0), .D_i2(64'h0),
    .E_i2(64'h0), .F_i2(64'h0), .G_i2(64'h0), .H_i2(64'h0),
    
    // Control outputs
    .start_sha_o(start_sha_o_w),
    .sel_mux(sel_mux_w),
    .sel_mux2(), // Not used for SHA-256
    .sel_res256(), // Not used in this implementation
    .sel_res512(), // Not used in this implementation
    .ena_K_reg(ena_K_reg_w),
    .sel_parise_mux(sel_parise_mux_w),
    .sel_parise_mux2(), // Not used for SHA-256
    
    .reg16_out(reg16_out_w),
    .reg16_out2(), // Not used for SHA-256
    
    .A_o(A_o_w), .B_o(B_o_w), .C_o(C_o_w), .D_o(D_o_w),
    .E_o(E_o_w), .F_o(F_o_w), .G_o(G_o_w), .H_o(H_o_w),
    .A_o2(), .B_o2(), .C_o2(), .D_o2(), // Not used for SHA-256
    .E_o2(), .F_o2(), .G_o2(), .H_o2(), // Not used for SHA-256
    
    .done_Sha(done_Sha_w)
);

//========================================================================
// Message Schedule - W[16] to W[63] computation
//========================================================================

// Main multiplexer for W selection
mux32_2to1 mux32_2to1 (
    .data0_i(reg16_out_w),
    .data1_i(data_o_adder_w),
    .sel_i(sel_mux_w),
    .data_o(data_o_mux_w)
);

// W register chain (shift register for message schedule)
register0_32bit Reg0(
    .CLK(clk), .RST(reset), .start(start_sha_o_w),
    .sel_mux(sel_parise_mux_w), .data_i(data_o_mux_w), .data_i2(k_reg_o_w),
    .data_regH_i(reg_H_o_w), .sel_mux_o(sel_mux_o_w),
    .data_o(data_o_reg0_w), .data_o2(data_o2_reg0_w), .data_regH_o(data_regH_o_w)  
);

register1_32bit Reg1(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg0_w), .data_o(data_o_reg1_w));
register2_32bit Reg2(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg1_w), .data_o(data_o_reg2_w));
register3_32bit Reg3(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg2_w), .data_o(data_o_reg3_w));
register4_32bit Reg4(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg3_w), .data_o(data_o_reg4_w));
register5_32bit Reg5(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg4_w), .data_o(data_o_reg5_w));
register6_32bit Reg6(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg5_w), .data_o(data_o_reg6_w));
register7_32bit Reg7(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg6_w), .data_o(data_o_reg7_w));
register8_32bit Reg8(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg7_w), .data_o(data_o_reg8_w));
register9_32bit Reg9(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg8_w), .data_o(data_o_reg9_w));
register10_32bit Reg10(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg9_w), .data_o(data_o_reg10_w));
register11_32bit Reg11(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg10_w), .data_o(data_o_reg11_w));
register12_32bit Reg12(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg11_w), .data_o(data_o_reg12_w));
register13_32bit Reg13(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg12_w), .data_o(data_o_reg13_w));
register14_32bit Reg14(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg13_w), .data_o(data_o_reg14_w));
register15_32bit Reg15(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(data_o_reg14_w), .data_o(data_o_reg15_w));

// Message schedule computation: W[t] = σ1(W[t-2]) + W[t-7] + σ0(W[t-15]) + W[t-16]
delta0 delta0 (.w1(data_o_reg14_w), .delta0(delta0_out_w));    // σ0(W[t-15]) 
delta1 delta1 (.w14(data_o_reg1_w), .delta1(delta1_out_w));   // σ1(W[t-2])

Adder_Sha Adder_Sha (
    .in1(delta1_out_w),      // σ1(W[t-2])
    .in2(data_o_reg6_w),     // W[t-7] 
    .in3(delta0_out_w),      // σ0(W[t-15])
    .in4(data_o_reg15_w),    // W[t-16]
    .sum(data_o_adder_w)     // New W[t]
);

//========================================================================
// K Constants Register
//========================================================================
K_register K_register (
    .clk(clk), .rst(reset), .ena_K_reg(ena_K_reg_w), .K_out(k_reg_o_w)
);

//========================================================================
// Hash Computation Pipeline
//========================================================================

// T1 computation: T1 = h + Σ1(e) + Ch(e,f,g) + Kt + Wt
Adder1 Adder1 (
    .in1(data_o_reg0_w),    // Wt (current message word)
    .in2(data_o2_reg0_w),   // Kt (current round constant)  
    .in3(reg_H_o_w),        // h (working variable H)
    .sum(data_o_adder1_w)
);

// Pairwise multiplexer for working variables
pairwise_mux pairwise_mux (
    .sel(sel_mux_o_w || data_o_reg32_w),
    .sel_A(sel_mux_o_w || data_o_reg32_w),
    .a1(A_o_w), .a2(data_o_adder4_w),  // a = T1 + T2
    .b1(B_o_w), .b2(reg_A_o_w),        // b = a
    .c1(C_o_w), .c2(reg_B_o_w),        // c = b  
    .d1(D_o_w), .d2(reg_C_o_w),        // d = c
    .e1(E_o_w), .e2(data_o_adder3_w),  // e = d + T1
    .f1(F_o_w), .f2(reg_E_o_w),        // f = e
    .g1(G_o_w), .g2(reg_F_o_w),        // g = f
    .h1(H_o_w), .h2(reg_G_o_w),        // h = g
    .a_out(pairwise_mux_a_out_w), .b_out(pairwise_mux_b_out_w), .c_out(pairwise_mux_c_out_w), .d_out(pairwise_mux_d_out_w),
    .e_out(pairwise_mux_e_out_w), .f_out(pairwise_mux_f_out_w), .g_out(pairwise_mux_g_out_w), .h_out(pairwise_mux_h_out_w)
);

// Working variable registers
registerA_32bit RegA(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(pairwise_mux_a_out_w), .data_o(reg_A_o_w));
registerB_32bit RegB(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(pairwise_mux_b_out_w), .data_o(reg_B_o_w));
registerC_32bit RegC(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(pairwise_mux_c_out_w), .data_o(reg_C_o_w));
registerD_32bit RegD(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(pairwise_mux_d_out_w), .data_o(reg_D_o_w));
registerE_32bit RegE(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(pairwise_mux_e_out_w), .data_o(reg_E_o_w));
registerF_32bit RegF(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(pairwise_mux_f_out_w), .data_o(reg_F_o_w));
registerG_32bit RegG(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(pairwise_mux_g_out_w), .data_o(reg_G_o_w));
registerH_32bit RegH(.CLK(clk), .RST(reset), .start(start_sha_o_w), .data_i(pairwise_mux_h_out_w), .data_o(reg_H_o_w));

// SHA-256 functions
Choice CH (.e(reg_E_o_w), .f(reg_F_o_w), .g(reg_G_o_w), .out(data_o_CH_w));           // Ch(e,f,g)
Sigma1 sigma1 (.e(reg_E_o_w), .out(data_o_sigma1_w));                                  // Σ1(e)
Majority Majority (.A(reg_A_o_w), .B(reg_B_o_w), .C(reg_C_o_w), .M(data_o_Maj_w));   // Maj(a,b,c)
Sigma0 Sigma0 (.a(reg_A_o_w), .out(data_o_sigma0_w));                                  // Σ0(a)

// T1 = h + Σ1(e) + Ch(e,f,g) + Kt + Wt
Adder2 Adder2 (
    .in1(data_o_CH_w),       // Ch(e,f,g)
    .in2(data_o_adder1_w),   // h + Kt + Wt  
    .in3(data_o_sigma1_w),   // Σ1(e)
    .sum(data_o_adder2_w)    // T1
);

// e = d + T1
Adder3 Adder3 (
    .in1(data_o_adder2_w),   // T1
    .in2(reg_D_o_w),         // d
    .sum(data_o_adder3_w)    // d + T1
);

// T2 = Σ0(a) + Maj(a,b,c)  
Adder4 Adder4 (
    .in1(data_o_Maj_w),      // Maj(a,b,c)
    .in2(data_o_sigma0_w),   // Σ0(a)
    .in3(data_o_adder2_w),   // T1
    .sum(data_o_adder4_w)    // T1 + T2
);

// Control register for state management
register_32bit Reg32(
    .CLK(clk), .RST(reset), .start(start_sha_o_w), .sel_A(sel_mux_o_w), .sel_A_o(data_o_reg32_w)
);

//========================================================================
// Output Assignment - Add final hash computation step
//========================================================================

// Final hash values (add working variables to initial hash values per NIST FIPS 180-4)
wire [31:0] final_H0, final_H1, final_H2, final_H3, final_H4, final_H5, final_H6, final_H7;

assign final_H0 = A_o_w + reg_A_o_w;  // H0 = H0_initial + a
assign final_H1 = B_o_w + reg_B_o_w;  // H1 = H1_initial + b  
assign final_H2 = C_o_w + reg_C_o_w;  // H2 = H2_initial + c
assign final_H3 = D_o_w + reg_D_o_w;  // H3 = H3_initial + d
assign final_H4 = E_o_w + reg_E_o_w;  // H4 = H4_initial + e
assign final_H5 = F_o_w + reg_F_o_w;  // H5 = H5_initial + f
assign final_H6 = G_o_w + reg_G_o_w;  // H6 = H6_initial + g  
assign final_H7 = H_o_w + reg_H_o_w;  // H7 = H7_initial + h

assign sha256_result = {final_H0, final_H1, final_H2, final_H3, final_H4, final_H5, final_H6, final_H7};
assign sha256_done = done_Sha_w;

endmodule