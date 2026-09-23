`timescale 1 ns/10 ps

// Keypad_Sample.sv
// Registers the keypad reading one cycle before Keypad_Debouncer sees it.

module Keypad_Sample (
    input  logic clk,
    input  logic reset,
    input  logic none_pressed_in,
    input  logic one_pressed_in,
    input  logic multi_pressed_in,
    input  logic [3:0] key_code_in,
    output logic none_pressed,
    output logic one_pressed,
    output logic multi_pressed,
    output logic [3:0] key_code
);

    always_ff @(posedge clk) begin
        if (reset) begin
            none_pressed  <= 1'b1;
            one_pressed   <= 1'b0;
            multi_pressed <= 1'b0;
            key_code      <= 4'h0;
        end else begin
            none_pressed  <= none_pressed_in;
            one_pressed   <= one_pressed_in;
            multi_pressed <= multi_pressed_in;
            key_code      <= key_code_in;
        end
    end

endmodule
