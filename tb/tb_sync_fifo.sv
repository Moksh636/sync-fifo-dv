`timescale 1ns/1ps

module tb_sync_fifo;

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH      = 4;

    logic clk;
    logic rst_n;
    logic wr_en;
    logic rd_en;
    logic [DATA_WIDTH-1:0] din;
    logic [DATA_WIDTH-1:0] dout;
    logic full;
    logic empty;

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .din   (din),
        .dout  (dout),
        .full  (full),
        .empty (empty)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task reset_fifo();
        begin
            @(negedge clk);
            rst_n = 0;
            wr_en = 0;
            rd_en = 0;
            din   = '0;

            repeat (2) @(negedge clk);

            rst_n = 1;
            @(negedge clk);

            if (empty !== 1'b1) begin
                $display("FAIL: FIFO should be empty after reset");
                $finish;
            end

            if (full !== 1'b0) begin
                $display("FAIL: FIFO should not be full after reset");
                $finish;
            end

            $display("PASS: Reset test");
        end
    endtask

    task write_fifo(input logic [DATA_WIDTH-1:0] data);
        begin
            @(negedge clk);
            din   = data;
            wr_en = 1'b1;

            @(negedge clk);
            wr_en = 1'b0;
            din   = '0;
        end
    endtask

    task read_fifo_check(input logic [DATA_WIDTH-1:0] expected);
        begin
            @(negedge clk);
            rd_en = 1'b1;

            @(posedge clk);
            #1;

            if (dout !== expected) begin
                $display("FAIL: Expected %0h, got %0h", expected, dout);
                $finish;
            end else begin
                $display("PASS: Read expected value %0h", expected);
            end

            @(negedge clk);
            rd_en = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("sim/waves/sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);

        rst_n = 1'b1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        din   = '0;

        reset_fifo();

        write_fifo(8'hA5);
        read_fifo_check(8'hA5);

        $display("Milestone 1 PASSED: reset, single write, single read");
        $finish;
    end

endmodule
