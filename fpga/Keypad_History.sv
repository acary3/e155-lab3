`timescale 1 ns/10 ps

// Keypad_History.sv
// Shifts a newly confirmed key press into right_digit_reg, moving the
// old right digit into left_digit_reg. Right digit is always the most
// recent press.

module Keypad_History (
    input  logic clk,
    input  logic reset,
    input  logic new_key,
    input  logic [3:0] new_key_code,
    output logic [3:0] left_digit_reg,
    output logic [3:0] right_digit_reg
);

    always_ff @(posedge clk) begin
        if (reset) begin
            left_digit_reg  <= 4'h0;
            right_digit_reg <= 4'h0;
        end else if (new_key) begin
            left_digit_reg  <= right_digit_reg;
            right_digit_reg <= new_key_code;
        end
    end

endmodule
