`timescale 1 ns/10 ps

// Keypad_SyncTb.sv
// Checks reset value and that a change takes exactly two clock edges
// to reach the output.

module Keypad_SyncTb();

    logic clk, reset;
    logic [3:0] col_raw, col_sync;

    Keypad_Sync dut (.clk(clk), .reset(reset), .col_raw(col_raw), .col_sync(col_sync));

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1; col_raw = 4'hF;
        @(posedge clk); #1;
        assert(col_sync == 4'hF) else $error("reset value wrong");
        reset = 0;

        // change col_raw at an arbitrary point, mid cycle
        #3;
        col_raw = 4'b1011;

        @(posedge clk); #1;
        assert(col_sync == 4'hF) else $error("output changed too soon");

        @(posedge clk); #1;
        assert(col_sync == 4'b1011) else $error("output did not settle after 2 edges");

        $display("Keypad_SyncTb: all checks passed");
        $finish;
    end

    initial begin
        #500;
        $error("Keypad_SyncTb: timeout");
        $finish;
    end

endmodule
