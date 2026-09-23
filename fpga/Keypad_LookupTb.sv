`timescale 1 ns/10 ps

// Keypad_LookupTb.sv
// sweeps every row/col combination and checks it against the expected legend.

module Keypad_LookupTb();

    logic [1:0] row_idx, col_idx;
    logic [3:0] hexval;

    Keypad_Lookup dut (.row_idx(row_idx), .col_idx(col_idx), .hexval(hexval));
    logic [3:0] expected [0:15];
    initial begin
        expected[0]  = 4'hA; expected[1]  = 4'h0; expected[2]  = 4'hB; expected[3]  = 4'hF;
        expected[4]  = 4'h7; expected[5]  = 4'h8; expected[6]  = 4'h9; expected[7]  = 4'hE;
        expected[8]  = 4'h4; expected[9]  = 4'h5; expected[10] = 4'h6; expected[11] = 4'hD;
        expected[12] = 4'h1; expected[13] = 4'h2; expected[14] = 4'h3; expected[15] = 4'hC;
    end

    integer i;
    initial begin
        #1;
        for (i = 0; i < 16; i = i + 1) begin
            {row_idx, col_idx} = i[3:0];
            #1;
            assert(hexval == expected[i])
                else $error("mismatch at row_idx=%d col_idx=%d, got %h", row_idx, col_idx, hexval);
        end
        $display("Keypad_LookupTb: all checks passed");
        $finish;
    end

endmodule
