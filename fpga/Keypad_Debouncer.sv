`timescale 1 ns/10 ps

// Keypad_Debouncer.sv
// Canonical FSM. Debounces the keypad reading and pulses new_key exactly
// once whenever the reading settles on a new single key. 

module Keypad_Debouncer #(
    parameter DEBOUNCE_W   = 20,
    parameter DEBOUNCE_MAX = 959999
) (
    input  logic clk,
    input  logic reset,
    input  logic none_pressed,
    input  logic one_pressed,
    input  logic multi_pressed,
    input  logic [3:0] key_code,
    output logic new_key,
    output logic [3:0] new_key_code
);

    typedef enum logic [1:0] {IDLE, CONFIRM, HELD, RELEASE} state_t;
    state_t state, next_state;

    logic [3:0] candidate, next_candidate;
    logic debounce_en, debounce_rst, debounce_done;

    blinker #(.WIDTH(DEBOUNCE_W), .MAX_COUNT(DEBOUNCE_MAX)) debounce_cnt (
        .clk(clk), .reset(reset | debounce_rst), .en(debounce_en), .blink(debounce_done)
    );

    always_comb begin
        next_state     = state;
        next_candidate = candidate;
        debounce_en  = 1'b0;
        debounce_rst = 1'b0;
        new_key      = 1'b0;

        case (state)
            IDLE: begin
                if (one_pressed) begin
                    next_candidate = key_code;
                    next_state     = CONFIRM;
                    debounce_rst   = 1'b1;
                end
            end

            CONFIRM: begin
                if (one_pressed && key_code == candidate) begin
                    debounce_en = 1'b1;
                    if (debounce_done) begin
                        new_key    = 1'b1;
                        next_state = HELD;
                    end
                end else if (one_pressed && key_code != candidate) begin
                    next_candidate = key_code;
                    debounce_rst   = 1'b1;
                end else begin
                    next_state   = IDLE;
                    debounce_rst = 1'b1;
                end
            end

            HELD: begin
                if (one_pressed && key_code != candidate) begin
                    next_candidate = key_code;
                    next_state     = CONFIRM;
                    debounce_rst   = 1'b1;
                end else if (none_pressed) begin
                    next_state   = RELEASE;
                    debounce_rst = 1'b1;
                end
            end

            RELEASE: begin
                if (none_pressed) begin
                    debounce_en = 1'b1;
                    if (debounce_done) next_state = IDLE;
                end else if (one_pressed && key_code == candidate) begin
                    next_state   = HELD;
                    debounce_rst = 1'b1;
                end else if (one_pressed && key_code != candidate) begin
                    next_candidate = key_code;
                    next_state     = CONFIRM;
                    debounce_rst   = 1'b1;
                end else begin
                    next_state   = HELD;
                    debounce_rst = 1'b1;
                end
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            state        <= IDLE;
            candidate    <= 4'h0;
            new_key_code <= 4'h0;
        end else begin
            state     <= next_state;
            candidate <= next_candidate;
            if (new_key) new_key_code <= candidate;
        end
    end

endmodule
