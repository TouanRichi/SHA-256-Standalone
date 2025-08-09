// sigma0.v - σ₀ function (rotr 7,18, shr 3) for SHA-256 message schedule
// NIST FIPS 180-4 compliant implementation
module sigma0 (
    input  wire [31:0] x,    // Input 32-bit word  
    output wire [31:0] out   // Output σ₀(x)
);

    // σ₀(x) = ROTR^7(x) ⊕ ROTR^18(x) ⊕ SHR^3(x)
    // Where ROTR^n(x) = (x >> n) | (x << (32-n))
    // And SHR^n(x) = x >> n
    assign out = ((x >> 7)  | (x << 25)) ^  // ROTR^7(x)
                 ((x >> 18) | (x << 14)) ^  // ROTR^18(x) 
                 (x >> 3);                  // SHR^3(x)

endmodule