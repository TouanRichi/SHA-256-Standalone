// sigma1.v - σ₁ function (rotr 17,19, shr 10) for SHA-256 message schedule  
// NIST FIPS 180-4 compliant implementation
module sigma1 (
    input  wire [31:0] x,    // Input 32-bit word
    output wire [31:0] out   // Output σ₁(x)
);

    // σ₁(x) = ROTR^17(x) ⊕ ROTR^19(x) ⊕ SHR^10(x)
    // Where ROTR^n(x) = (x >> n) | (x << (32-n))
    // And SHR^n(x) = x >> n
    assign out = ((x >> 17) | (x << 15)) ^  // ROTR^17(x)
                 ((x >> 19) | (x << 13)) ^  // ROTR^19(x)
                 (x >> 10);                 // SHR^10(x)

endmodule