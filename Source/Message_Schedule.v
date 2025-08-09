// Message_Schedule.v - W expansion logic for SHA-256
// Implements W[t] = σ₁(W[t-2]) + W[t-7] + σ₀(W[t-15]) + W[t-16] for t = 16 to 63
// NIST FIPS 180-4 compliant implementation  
module Message_Schedule (
    input  wire clk,                    // Clock signal
    input  wire rst,                    // Reset signal (active low)
    input  wire ena,                    // Enable signal
    input  wire [31:0] W_t_minus_2,     // W[t-2]
    input  wire [31:0] W_t_minus_7,     // W[t-7]  
    input  wire [31:0] W_t_minus_15,    // W[t-15]
    input  wire [31:0] W_t_minus_16,    // W[t-16]
    output wire [31:0] W_t              // Output W[t]
);

    // Internal wires for sigma functions
    wire [31:0] sigma0_out;
    wire [31:0] sigma1_out;
    
    // σ₀(W[t-15])
    sigma0 sigma0_inst (
        .x(W_t_minus_15),
        .out(sigma0_out)
    );
    
    // σ₁(W[t-2])  
    sigma1 sigma1_inst (
        .x(W_t_minus_2),
        .out(sigma1_out)
    );
    
    // W[t] = σ₁(W[t-2]) + W[t-7] + σ₀(W[t-15]) + W[t-16]
    // Using 32-bit addition with overflow (modulo 2^32)
    assign W_t = sigma1_out + W_t_minus_7 + sigma0_out + W_t_minus_16;

endmodule