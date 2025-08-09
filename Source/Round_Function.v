// Round_Function.v - SHA-256 compression function for one round
// Implements the core SHA-256 round transformation
// NIST FIPS 180-4 compliant implementation
module Round_Function (
    input  wire [31:0] a, b, c, d, e, f, g, h,  // Working variables
    input  wire [31:0] W_t,                      // Message word W[t]
    input  wire [31:0] K_t,                      // Round constant K[t]
    output wire [31:0] a_next, b_next, c_next, d_next,  // Next working variables
    output wire [31:0] e_next, f_next, g_next, h_next
);

    // Internal wires
    wire [31:0] ch_out;      // Ch(e,f,g)
    wire [31:0] maj_out;     // Maj(a,b,c)  
    wire [31:0] sigma0_out;  // Σ₀(a)
    wire [31:0] sigma1_out;  // Σ₁(e)
    wire [31:0] T1, T2;      // Temporary values
    
    // Ch(e,f,g) = (e & f) ^ (~e & g)
    Choice ch_inst (
        .e(e), .f(f), .g(g),
        .out(ch_out)
    );
    
    // Maj(a,b,c) = (a & b) ^ (a & c) ^ (b & c) 
    Majority maj_inst (
        .A(a), .B(b), .C(c),
        .M(maj_out)
    );
    
    // Σ₀(a) = ROTR²(a) ⊕ ROTR¹³(a) ⊕ ROTR²²(a)
    Sigma0 sigma0_inst (
        .a(a),
        .out(sigma0_out)
    );
    
    // Σ₁(e) = ROTR⁶(e) ⊕ ROTR¹¹(e) ⊕ ROTR²⁵(e)
    Sigma1 sigma1_inst (
        .e(e), 
        .out(sigma1_out)
    );
    
    // T1 = h + Σ₁(e) + Ch(e,f,g) + K[t] + W[t]
    assign T1 = h + sigma1_out + ch_out + K_t + W_t;
    
    // T2 = Σ₀(a) + Maj(a,b,c)
    assign T2 = sigma0_out + maj_out;
    
    // Update working variables
    assign a_next = T1 + T2;    // a = T1 + T2
    assign b_next = a;          // b = a  
    assign c_next = b;          // c = b
    assign d_next = c;          // d = c
    assign e_next = d + T1;     // e = d + T1
    assign f_next = e;          // f = e
    assign g_next = f;          // g = f
    assign h_next = g;          // h = g

endmodule