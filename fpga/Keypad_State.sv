`timescale 1 ns/10 ps

// Keypad_State.sv
// Keeps a 16 bit picture of the whole keypad. Each cycle, whichever row
// is currently active gets its 4 (already synchronized) columns latched
// into that row's 4 bits.

module Keypad_State (
    input  logic clk,
    input  logic reset,
    input  logic [3:0] row,
    input  logic [3:0] col_n,
    output logic none_pressed,
    output logic one_pressed,
    output logic multi_pressed,
    output logic [1:0] row_idx,
    output logic [1:0] col_idx
);

    logic [15:0] map;
    logic [3:0] col_active;
    assign col_active = ~col_n;

    always_ff @(posedge clk) begin
        if (reset) map <= 16'b0;
        else begin
            case (row)
                4'b1000: map[15:12] <= col_active;
                4'b0100: map[11:8]  <= col_active;
                4'b0010: map[7:4]   <= col_active;
                4'b0001: map[3:0]   <= col_active;
                default: ;
            endcase
        end
    end


    logic [15:0] map_cleared;
    assign map_cleared = map & (map - 16'b1);

    assign none_pressed  = (map == 16'b0);
    assign one_pressed   = (map != 16'b0) && (map_cleared == 16'b0);
    assign multi_pressed = (map_cleared != 16'b0);

    always_comb begin
        case (map)
            16'b1000_0000_0000_0000: {row_idx, col_idx} = 4'b11_11;
            16'b0100_0000_0000_0000: {row_idx, col_idx} = 4'b11_10;
            16'b0010_0000_0000_0000: {row_idx, col_idx} = 4'b11_01;
            16'b0001_0000_0000_0000: {row_idx, col_idx} = 4'b11_00;
            16'b0000_1000_0000_0000: {row_idx, col_idx} = 4'b10_11;
            16'b0000_0100_0000_0000: {row_idx, col_idx} = 4'b10_10;
            16'b0000_0010_0000_0000: {row_idx, col_idx} = 4'b10_01;
            16'b0000_0001_0000_0000: {row_idx, col_idx} = 4'b10_00;
            16'b0000_0000_1000_0000: {row_idx, col_idx} = 4'b01_11;
            16'b0000_0000_0100_0000: {row_idx, col_idx} = 4'b01_10;
            16'b0000_0000_0010_0000: {row_idx, col_idx} = 4'b01_01;
            16'b0000_0000_0001_0000: {row_idx, col_idx} = 4'b01_00;
            16'b0000_0000_0000_1000: {row_idx, col_idx} = 4'b00_11;
            16'b0000_0000_0000_0100: {row_idx, col_idx} = 4'b00_10;
            16'b0000_0000_0000_0010: {row_idx, col_idx} = 4'b00_01;
            16'b0000_0000_0000_0001: {row_idx, col_idx} = 4'b00_00;
            default: {row_idx, col_idx} = 4'b00_00; // don't care: none/multi pressed
        endcase
    end

endmodule
