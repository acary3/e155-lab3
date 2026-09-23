`timescale 1 ns/10 ps

// Keypad_SampleTb.sv

module Keypad_SampleTb();

    logic clk, reset;
    logic none_in, one_in, multi_in;
    logic [3:0] code_in;
    logic none_out, one_out, multi_out;
    logic [3:0] code_out;

    Keypad_Sample dut (
        .clk(clk), .reset(reset),
        .none_pressed_in(none_in), .one_pressed_in(one_in), .multi_pressed_in(multi_in),
        .key_code_in(code_in),
        .none_pressed(none_out), .one_pressed(one_out), .multi_pressed(multi_out),
        .key_code(code_out)
    );

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    initial begin
        reset = 1; none_in = 0; one_in = 0; multi_in = 0; code_in = 4'h0;
        @(posedge clk); #1;
        assert(none_out == 1 && one_out == 0 && multi_out == 0 && code_out == 4'h0)
            else $error("reset value wrong");
        reset = 0;

        none_in = 0; one_in = 1; multi_in = 0; code_in = 4'hB;
        @(posedge clk); #1;
        assert(one_out == 1 && code_out == 4'hB) else $error("did not register new sample");

        none_in = 1; one_in = 0; multi_in = 0; code_in = 4'h0;
        @(posedge clk); #1;
        assert(none_out == 1 && one_out == 0) else $error("did not update to none_pressed");

        $display("Keypad_SampleTb: all checks passed");
        $finish;
    end

    initial begin
        #500;
        $error("Keypad_SampleTb: timeout");
        $finish;
    end

endmodule
