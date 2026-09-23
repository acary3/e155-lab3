`timescale 1 ns/10 ps

// blinker.sv
// Arthur Cary, acary@hmc.edu
// September 8, 2026
// Counter with reset, enable, and a settable max count. Toggles blink each
// time the count reaches MAX_COUNT

module blinker #(
    parameter WIDTH     = 24,
    parameter MAX_COUNT = 5000000
) (
    input  logic clk,
    input  logic reset,   // active high
    input  logic en,
    output logic blink
);

    logic [WIDTH-1:0] count;

    always_ff @(posedge clk) begin
        if (reset) begin
            count <= {WIDTH{1'b0}};
            blink <= 1'b0;
        end
        else if (en) begin
            if (count == MAX_COUNT) begin
                count <= {WIDTH{1'b0}};
                blink <= ~blink;
            end
            else count <= count + 1'b1;
        end
    end

endmodule
