`timescale 1ns / 1ps

module K_register (
    input wire clk,              // Tín hiệu đồng hồ
    input wire rst,              // Tín hiệu reset (active low)
    input wire ena_K_reg,        // Tín hiệu cho phép
    output reg [31:0] K_out      // Đầu ra 32-bit
);

    // Mảng thanh ghi K từ K[0] đến K[63] (64 thanh ghi 32-bit)
    reg [31:0] K [0:63];

    // Bộ đếm để theo dõi vị trí của K[i]
    reg [5:0] counter; // Bộ đếm 6-bit để đếm từ 0 đến 63

    // // Khối reset và logic mảng
    // always @(posedge clk or negedge rst) begin
    //     if (!rst) begin
    //         counter <= 6'd0;     // Reset bộ đếm về 0
    //         K_out <= 32'd0;      // Reset đầu ra về 0
    //     end else if (ena_K_reg) begin
    //         K_out <= K[counter]; // Gán đầu ra bằng K[counter]
    //         counter <= counter + 1'b1; // Tăng bộ đếm
    //         if (counter == 6'd63) begin
    //             counter <= 6'd0; // Nếu đạt đến K[63], quay lại K[0]
    //         end
    //     end
    // end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 6'd0;     // Reset bộ đếm về 0
            K_out <= 32'd0;      // Reset đầu ra về 0
        end else begin
            if (ena_K_reg) begin
                K_out <= K[counter]; // Gán đầu ra bằng K[counter]
                counter <= counter + 1'b1; // Tăng bộ đếm
                if (counter == 6'd63) begin
                counter <= 6'd0; // Nếu đạt đến K[63], quay lại K[0]
                end
            end else begin
                K_out <= 32'd0;
                counter <= 6'd0;
            end
        end
    end

    // Mảng hằng số K cho SHA-256

initial begin
    K[0]  = 32'h428a2f98;
    K[1]  = 32'h71374491;
    K[2]  = 32'hb5c0fbcf;
    K[3]  = 32'he9b5dba5;
    K[4]  = 32'h3956c25b;
    K[5]  = 32'h59f111f1;
    K[6]  = 32'h923f82a4;
    K[7]  = 32'hab1c5ed5;
    K[8]  = 32'hd807aa98;
    K[9]  = 32'h12835b01;
    K[10] = 32'h243185be;
    K[11] = 32'h550c7dc3;
    K[12] = 32'h72be5d74;
    K[13] = 32'h80deb1fe;
    K[14] = 32'h9bdc06a7;
    K[15] = 32'hc19bf174;
    K[16] = 32'he49b69c1;
    K[17] = 32'hefbe4786;
    K[18] = 32'h0fc19dc6;
    K[19] = 32'h240ca1cc;
    K[20] = 32'h2de92c6f;
    K[21] = 32'h4a7484aa;
    K[22] = 32'h5cb0a9dc;
    K[23] = 32'h76f988da;
    K[24] = 32'h983e5152;
    K[25] = 32'ha831c66d;
    K[26] = 32'hb00327c8;
    K[27] = 32'hbf597fc7;
    K[28] = 32'hc6e00bf3;
    K[29] = 32'hd5a79147;
    K[30] = 32'h06ca6351;
    K[31] = 32'h14292967;
    K[32] = 32'h27b70a85;
    K[33] = 32'h2e1b2138;
    K[34] = 32'h4d2c6dfc;
    K[35] = 32'h53380d13;
    K[36] = 32'h650a7354;
    K[37] = 32'h766a0abb;
    K[38] = 32'h81c2c92e;
    K[39] = 32'h92722c85;
    K[40] = 32'ha2bfe8a1;
    K[41] = 32'ha81a664b;
    K[42] = 32'hc24b8b70;
    K[43] = 32'hc76c51a3;
    K[44] = 32'hd192e819;
    K[45] = 32'hd6990624;
    K[46] = 32'hf40e3585;
    K[47] = 32'h106aa070;
    K[48] = 32'h19a4c116;
    K[49] = 32'h1e376c08;
    K[50] = 32'h2748774c;
    K[51] = 32'h34b0bcb5;
    K[52] = 32'h391c0cb3;
    K[53] = 32'h4ed8aa4a;
    K[54] = 32'h5b9cca4f;
    K[55] = 32'h682e6ff3;
    K[56] = 32'h748f82ee;
    K[57] = 32'h78a5636f;
    K[58] = 32'h84c87814;
    K[59] = 32'h8cc70208;
    K[60] = 32'h90befffa;
    K[61] = 32'ha4506ceb;
    K[62] = 32'hbef9a3f7;
    K[63] = 32'hc67178f2;
end
    

endmodule