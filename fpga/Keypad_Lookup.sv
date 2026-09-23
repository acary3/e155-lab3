`timescale 1 ns/10 ps

// Keypad_Lookup.sv
// row_idx follows the scanner's row one-hot bit position: 3 for row[3],
// down to 0 for row[0]. col_idx is the bit position of the active column
// in col_n. 

module Keypad_Lookup (
    input  logic [1:0] row_idx,
    input  logic [1:0] col_idx,
    output logic [3:0] hexval
);

    always_comb begin
        case ({row_idx, col_idx})
            4'b11_00: hexval = 4'h1;
            4'b11_01: hexval = 4'h2;
            4'b11_10: hexval = 4'h3;
            4'b11_11: hexval = 4'hC;
            4'b10_00: hexval = 4'h4;
            4'b10_01: hexval = 4'h5;
            4'b10_10: hexval = 4'h6;
            4'b10_11: hexval = 4'hD;
            4'b01_00: hexval = 4'h7;
            4'b01_01: hexval = 4'h8;
            4'b01_10: hexval = 4'h9;
            4'b01_11: hexval = 4'hE;
            4'b00_00: hexval = 4'hA;
            4'b00_01: hexval = 4'h0;
            4'b00_10: hexval = 4'hB;
            4'b00_11: hexval = 4'hF;
            default:  hexval = 4'h0;
        endcase
    end

endmodule
