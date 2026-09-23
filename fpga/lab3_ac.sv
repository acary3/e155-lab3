`timescale 1 ns/10 ps

// lab3_ac.sv
// Top module for lab 3. Reads a 4x4 keypad and shows the last two
// hex digits pressed on the dual seven-segment display.

module lab3_ac #(
    parameter MUX_W        = 13,
    parameter MUX_MAX      = 6000,
    parameter SCAN_W0      = 13,
    parameter SCAN_W1      = 14,
    parameter SCAN_M0      = 6000,
    parameter DEBOUNCE_W   = 18,
    parameter DEBOUNCE_MAX = 240000
) (
    input  logic reset_n,   
    input  logic [3:0] col,
    output logic [3:0] row,
    output logic [6:0] seg,
    output logic [1:0] an
);

    logic clk;
    logic reset;
    assign reset = ~reset_n; 
    HSOSC #(.CLKHF_DIV("0b10")) osc (
        .CLKHFEN(1'b1), .CLKHFPU(1'b1), .CLKHF(clk)
    );

    logic sel;
    blinker #(.WIDTH(MUX_W), .MAX_COUNT(MUX_MAX)) mux_cnt (
        .clk(clk), .reset(reset), .en(1'b1), .blink(sel)
    );

    scan_gen #(.W0(SCAN_W0), .W1(SCAN_W1), .M0(SCAN_M0)) scan (
        .clk(clk), .reset(reset), .en(1'b1), .row(row)
    );

    logic [3:0] col_n;
    Keypad_Sync sync (
        .clk(clk), .reset(reset), .col_raw(col), .col_sync(col_n)
    );

    logic none_p, one_p, multi_p;
    logic [1:0] row_idx, col_idx;
    Keypad_State kstate (
        .clk(clk), .reset(reset), .row(row), .col_n(col_n),
        .none_pressed(none_p), .one_pressed(one_p), .multi_pressed(multi_p),
        .row_idx(row_idx), .col_idx(col_idx)
    );

    logic [3:0] key_code;
    Keypad_Lookup lut (.row_idx(row_idx), .col_idx(col_idx), .hexval(key_code));

    logic none_s, one_s, multi_s;
    logic [3:0] key_code_s;
    Keypad_Sample sample (
        .clk(clk), .reset(reset),
        .none_pressed_in(none_p), .one_pressed_in(one_p), .multi_pressed_in(multi_p),
        .key_code_in(key_code),
        .none_pressed(none_s), .one_pressed(one_s), .multi_pressed(multi_s),
        .key_code(key_code_s)
    );

    logic new_key;
    logic [3:0] new_key_code;
    Keypad_Debouncer #(.DEBOUNCE_W(DEBOUNCE_W), .DEBOUNCE_MAX(DEBOUNCE_MAX)) debouncer (
        .clk(clk), .reset(reset),
        .none_pressed(none_s), .one_pressed(one_s), .multi_pressed(multi_s),
        .key_code(key_code_s),
        .new_key(new_key), .new_key_code(new_key_code)
    );

    logic [3:0] left_digit_reg, right_digit_reg;
    Keypad_History hist (
        .clk(clk), .reset(reset), .new_key(new_key), .new_key_code(new_key_code),
        .left_digit_reg(left_digit_reg), .right_digit_reg(right_digit_reg)
    );

    logic [3:0] hex;
    assign hex   = sel ? right_digit_reg : left_digit_reg;
    assign an[0] = sel;
    assign an[1] = ~sel;

    decoder dec (.s(hex), .seg(seg));

endmodule
