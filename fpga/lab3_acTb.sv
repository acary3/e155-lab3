`timescale 1 ns/10 ps

module HSOSC #(parameter CLKHF_DIV = "0b00") (
    input  logic CLKHFEN,
    input  logic CLKHFPU,
    output logic CLKHF
);
    initial begin
        CLKHF = 0;
        wait (CLKHFEN && CLKHFPU);
        #50;
        forever #10.417 CLKHF = ~CLKHF;
    end
endmodule

// lab3_acTb.sv
// Simulates holding a key by only pulling col low 

module lab3_acTb();

    logic reset_n;
    logic [3:0] col;
    logic [3:0] row;
    logic [6:0] seg;
    logic [1:0] an;

    logic [3:0] held_row;   // one-hot row of the key being held, 0 = none held
    logic [3:0] held_col_n; // active-low column pattern for that key

    lab3_ac #(
        .MUX_W(3), .MUX_MAX(3),
        .SCAN_W0(2), .SCAN_W1(3), .SCAN_M0(1),
        .DEBOUNCE_W(3), .DEBOUNCE_MAX(2)
    ) dut (
        .reset_n(reset_n), .col(col), .row(row), .seg(seg), .an(an)
    );

    assign col = (held_row != 4'b0000 && row == held_row) ? held_col_n : 4'hF;

    task hold_key(input logic [3:0] r, input logic [3:0] c_n);
        begin
            held_row = r; held_col_n = c_n;
        end
    endtask

    task release_key();
        begin
            held_row = 4'b0000; held_col_n = 4'hF;
        end
    endtask

    initial begin
        reset_n = 0; release_key(); // active low: 0 asserts reset
        #200;
        @(posedge dut.clk);
        reset_n = 1; // release the button

        // hold the key that decodes to hex 5
        hold_key(4'b0100, 4'hD);
        repeat (80) @(posedge dut.clk);
        assert(dut.hist.right_digit_reg == 4'h5) else $error("key 5 not shown, right_digit_reg=%h", dut.hist.right_digit_reg);

        release_key();
        repeat (40) @(posedge dut.clk);

        // hold the key that decodes to hex A
        hold_key(4'b0001, 4'hE);
        repeat (80) @(posedge dut.clk);
        assert(dut.hist.left_digit_reg == 4'h5 && dut.hist.right_digit_reg == 4'hA)
            else $error("second key wrong, left=%h right=%h", dut.hist.left_digit_reg, dut.hist.right_digit_reg);

        $display("lab3_acTb: all checks passed");
        $finish;
    end

    initial begin
        #200000;
        $error("lab3_acTb: timeout");
        $finish;
    end

endmodule
