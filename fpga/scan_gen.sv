`timescale 1 ns/10 ps

// scan_gen.sv
// Scanning module for keypad interrogation.
// Two counter (blinker) instances form a 2-bit counter (b1,b0).
// Assign statements decode the count into a one-hot row pattern.

module scan_gen #(
    parameter W0 = 23,
    parameter W1 = 24,
    parameter M0 = 5999999
) (
    input  logic clk,
    input  logic reset,
    input  logic en,
    output logic [3:0] row
);

    localparam M1 = 2*(M0+1) - 1;

    logic b0, b1;

    blinker #(.WIDTH(W0), .MAX_COUNT(M0)) cnt0 (
        .clk(clk), .reset(reset), .en(en), .blink(b0)
    );

    blinker #(.WIDTH(W1), .MAX_COUNT(M1)) cnt1 (
        .clk(clk), .reset(reset), .en(en), .blink(b1)
    );

    assign row[3] = ~b1 & ~b0; // state 00 -> 1000
    assign row[2] = ~b1 &  b0; // state 01 -> 0100
    assign row[1] =  b1 & ~b0; // state 10 -> 0010
    assign row[0] =  b1 &  b0; // state 11 -> 0001

endmodule
