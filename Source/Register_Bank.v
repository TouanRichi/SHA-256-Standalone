// Register_Bank.v - A,B,C,D,E,F,G,H registers for SHA-256
// Manages the 8 working variables used in SHA-256 computation  
// NIST FIPS 180-4 compliant implementation
module Register_Bank (
    input  wire clk,                            // Clock signal
    input  wire rst,                            // Reset signal (active low)
    input  wire ena,                            // Enable signal
    input  wire load_initial,                   // Load initial hash values
    input  wire [31:0] H0_init, H1_init, H2_init, H3_init,  // Initial hash values
    input  wire [31:0] H4_init, H5_init, H6_init, H7_init,
    input  wire [31:0] a_in, b_in, c_in, d_in,  // Input working variables
    input  wire [31:0] e_in, f_in, g_in, h_in,
    output reg [31:0] a_out, b_out, c_out, d_out,  // Output working variables  
    output reg [31:0] e_out, f_out, g_out, h_out,
    output wire [255:0] hash_out                 // Final hash output
);

    // SHA-256 initial hash values (first 32 bits of fractional parts of square roots of first 8 primes)
    parameter [31:0] SHA256_H0_INIT = 32'h6A09E667;
    parameter [31:0] SHA256_H1_INIT = 32'hBB67AE85;  
    parameter [31:0] SHA256_H2_INIT = 32'h3C6EF372;
    parameter [31:0] SHA256_H3_INIT = 32'hA54FF53A;
    parameter [31:0] SHA256_H4_INIT = 32'h510E527F;
    parameter [31:0] SHA256_H5_INIT = 32'h9B05688C;
    parameter [31:0] SHA256_H6_INIT = 32'h1F83D9AB;
    parameter [31:0] SHA256_H7_INIT = 32'h5BE0CD19;
    
    // Register update logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset to SHA-256 initial values
            a_out <= SHA256_H0_INIT;
            b_out <= SHA256_H1_INIT;
            c_out <= SHA256_H2_INIT;
            d_out <= SHA256_H3_INIT;
            e_out <= SHA256_H4_INIT;
            f_out <= SHA256_H5_INIT;  
            g_out <= SHA256_H6_INIT;
            h_out <= SHA256_H7_INIT;
        end else if (load_initial) begin
            // Load custom initial hash values
            a_out <= H0_init;
            b_out <= H1_init;
            c_out <= H2_init;
            d_out <= H3_init;
            e_out <= H4_init;
            f_out <= H5_init;
            g_out <= H6_init;  
            h_out <= H7_init;
        end else if (ena) begin
            // Update working variables
            a_out <= a_in;
            b_out <= b_in;
            c_out <= c_in;
            d_out <= d_in;
            e_out <= e_in;
            f_out <= f_in;
            g_out <= g_in;
            h_out <= h_in;
        end
        // else hold current values
    end
    
    // Output final hash (concatenation of all working variables)
    assign hash_out = {a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out};

endmodule