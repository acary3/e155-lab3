`timescale 1 ns/10 ps

// Keypad_Sync.sv
// Two flip-flop synchronizer for the keypad column inputs

module Keypad_Sync #(
    parameter WIDTH = 4
) (
    input  logic clk,
    input  logic reset,
    input  logic [WIDTH-1:0] col_raw,
    output logic [WIDTH-1:0] col_sync
);

    logic [WIDTH-1:0] meta;

    always_ff @(posedge clk) begin
        if (reset) begin
            meta     <= {WIDTH{1'b1}};
            col_sync <= {WIDTH{1'b1}};
        end else begin
            meta     <= col_raw;
            col_sync <= meta;
        end
    end

endmodule
