`timescale 1 ns/10 ps

// Keypad_HistoryTb.sv

module Keypad_HistoryTb();

    logic clk, reset, new_key;
    logic [3:0] new_key_code;
    logic [3:0] left_digit_reg, right_digit_reg;

    Keypad_History dut (
        .clk(clk), .reset(reset), .new_key(new_key), .new_key_code(new_key_code),
        .left_digit_reg(left_digit_reg), .right_digit_reg(right_digit_reg)
    );

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1; new_key = 0; new_key_code = 4'h0;
        @(posedge clk); #1;
        assert(left_digit_reg == 0 && right_digit_reg == 0) else $error("reset value wrong");
        reset = 0;

        // holding new_key low should not shift 
        repeat (3) @(posedge clk);
        #1;
        assert(left_digit_reg == 0 && right_digit_reg == 0) else $error("shifted without new_key");

        // first press: 5
        new_key = 1; new_key_code = 4'h5;
        @(posedge clk); #1;
        new_key = 0;
        assert(left_digit_reg == 0 && right_digit_reg == 4'h5)
            else $error("first digit wrong, L=%h R=%h", left_digit_reg, right_digit_reg);

        // second press: A, should push 5 to the left
        new_key = 1; new_key_code = 4'hA;
        @(posedge clk); #1;
        new_key = 0;
        assert(left_digit_reg == 4'h5 && right_digit_reg == 4'hA)
            else $error("second digit wrong, L=%h R=%h", left_digit_reg, right_digit_reg);

        $display("Keypad_HistoryTb: all checks passed");
        $finish;
    end

    initial begin
        #500;
        $error("Keypad_HistoryTb: timeout");
        $finish;
    end

endmodule
