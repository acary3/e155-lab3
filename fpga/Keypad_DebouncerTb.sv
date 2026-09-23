`timescale 1 ns/10 ps

// Keypad_DebouncerTb.sv
// Drives none/one/multi_pressed and key_code directly (as if Keypad_State
// produced them) and checks new_key/new_key_code. 

module Keypad_DebouncerTb();

    logic clk, reset;
    logic none_p, one_p, multi_p;
    logic [3:0] key_code;
    logic new_key;
    logic [3:0] new_key_code;

    Keypad_Debouncer #(.DEBOUNCE_W(3), .DEBOUNCE_MAX(2)) dut (
        .clk(clk), .reset(reset),
        .none_pressed(none_p), .one_pressed(one_p), .multi_pressed(multi_p),
        .key_code(key_code), .new_key(new_key), .new_key_code(new_key_code)
    );

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    task drive(input logic n, o, m, input logic [3:0] c);
        begin
            none_p = n; one_p = o; multi_p = m; key_code = c;
        end
    endtask

    initial begin
        reset = 1; drive(1, 0, 0, 4'h0);
        @(posedge clk); #1;
        reset = 0;

        // single press of key 5, held 5 cycles, then released
        drive(0, 1, 0, 4'h5);
        repeat (5) begin
            @(posedge clk); #1;
        end
       
        assert(new_key == 0) else $error("new_key pulse did not clear");
        assert(new_key_code == 4'h5) else $error("key 5 was not registered, new_key_code=%h", new_key_code);

        drive(1, 0, 0, 4'h0); // release
        repeat (5) @(posedge clk);
        #1;

        // bounce while pressing key A
        drive(0, 1, 0, 4'hA); @(posedge clk); #1;
        drive(1, 0, 0, 4'h0); @(posedge clk); #1; // bounce to released
        drive(0, 1, 0, 4'hA); @(posedge clk); #1; // back to pressed
        repeat (5) @(posedge clk);
        #1;
        assert(new_key_code == 4'hA) else $error("key A not registered after bounce, new_key_code=%h", new_key_code);

        // hold A
        drive(0, 0, 1, 4'h0);
        repeat (5) @(posedge clk);
        #1;
        assert(new_key_code == 4'hA) else $error("new_key_code changed during multi-press, got %h", new_key_code);

        // release the other key
        drive(0, 1, 0, 4'h3);
        repeat (5) @(posedge clk);
        #1;
        assert(new_key_code == 4'h3) else $error("excellence case failed: last remaining key 3 not registered, got %h", new_key_code);

        // release fully
        drive(1, 0, 0, 4'h0);
        repeat (5) @(posedge clk);
        #1;

        $display("Keypad_DebouncerTb: all checks passed");
        $finish;
    end

    initial begin
        #3000;
        $error("Keypad_DebouncerTb: timeout");
        $finish;
    end

endmodule
