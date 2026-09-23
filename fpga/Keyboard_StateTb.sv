`timescale 1 ns/10 ps

// Keypad_StateTb.sv
// Drives row/col_n directly (bypassing Keypad_Sync, which has its own
// testbench) and checks the none/one/multi outputs and position report.

module Keypad_StateTb();

    logic clk, reset;
    logic [3:0] row, col_n;
    logic none_p, one_p, multi_p;
    logic [1:0] row_idx, col_idx;

    Keypad_State dut (
        .clk(clk), .reset(reset), .row(row), .col_n(col_n),
        .none_pressed(none_p), .one_pressed(one_p), .multi_pressed(multi_p),
        .row_idx(row_idx), .col_idx(col_idx)
    );

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1; row = 4'b1000; col_n = 4'hF;
        @(posedge clk); #1;
        assert(none_p) else $error("reset did not clear map");
        reset = 0;

        // nothing pressed on any row
        row = 4'b1000; col_n = 4'hF; @(posedge clk); #1;
        row = 4'b0100; col_n = 4'hF; @(posedge clk); #1;
        row = 4'b0010; col_n = 4'hF; @(posedge clk); #1;
        row = 4'b0001; col_n = 4'hF; @(posedge clk); #1;
        assert(none_p) else $error("should read none pressed");

        // press the key at row[3] col bit 1
        row = 4'b1000; col_n = 4'b1101; @(posedge clk); #1;
        assert(one_p && row_idx == 2'd3 && col_idx == 2'd1)
            else $error("single press not decoded, row_idx=%d col_idx=%d", row_idx, col_idx);

        // now also press a key on row[1], col bit 2
        row = 4'b0010; col_n = 4'b1011; @(posedge clk); #1;
        assert(multi_p) else $error("second press should read as multi");

        // release the row[3] key
        row = 4'b1000; col_n = 4'hF; @(posedge clk); #1;
        row = 4'b0010; col_n = 4'b1011; @(posedge clk); #1;
        assert(one_p && row_idx == 2'd1 && col_idx == 2'd2)
            else $error("remaining single press not decoded, row_idx=%d col_idx=%d", row_idx, col_idx);

        $display("Keypad_StateTb: all checks passed");
        $finish;
    end

    initial begin
        #2000;
        $error("Keypad_StateTb: timeout");
        $finish;
    end

endmodule
