

    

`timescale 1ns/1ps

module uart_tb;

    reg clk, rst, tx_start;
    reg [7:0] tx_data;

    wire tx, tx_busy;
    wire [7:0] rx_data;
    wire rx_valid;

    localparam CLKS_PER_BIT = 16;

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);

        clk = 0;
        rst = 1;
        tx_start = 0;
        tx_data = 0;

        repeat (5) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Send first byte
        @(negedge clk);
        tx_data = 8'hA5;
        tx_start = 1;

        @(negedge clk);
        tx_start = 0;

        wait (rx_valid == 1'b1);
        #1;

        if (rx_data == 8'hA5)
            $display("PASS: Received data = %h", rx_data);
        else
            $display("FAIL: Expected A5, received %h", rx_data);

        // Send second byte
               // Wait until transmitter is ready
        wait (tx_busy == 1'b0);
        @(negedge clk);

        // Send second byte
        tx_data = 8'h3C;
        tx_start = 1;

        @(negedge clk);
        tx_start = 0;

        wait (rx_valid == 1'b1);
        #1;

        if (rx_data == 8'h3C)
            $display("PASS: Received data = %h", rx_data);
        else
            $display("FAIL: Expected 3C, received %h", rx_data);

        #20;
        $finish;
    end
    initial begin
       #20000;
       $display("ERROR: Simulation timeout");
       $finish;
    end


endmodule
