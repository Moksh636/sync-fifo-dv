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

    task fail_test(input string msg);
        begin
            $display("FAIL: %s", msg);
            $finish;
        end
    endtask

    task check_state(
        input logic exp_empty,
        input logic exp_full,
        input int exp_count,
        input string msg
    );
        begin
            #1;

            if (empty !== exp_empty) begin
                $display("FAIL: %s empty expected=%0b actual=%0b", msg, exp_empty, empty);
                $finish;
            end

            if (full !== exp_full) begin
                $display("FAIL: %s full expected=%0b actual=%0b", msg, exp_full, full);
                $finish;
            end

            if (dut.count !== exp_count) begin
                $display("FAIL: %s count expected=%0d actual=%0d", msg, exp_count, dut.count);
                $finish;
            end
        end
    endtask

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

            check_state(1'b1, 1'b0, 0, "after reset");
            $display("PASS: Reset test");
        end
    endtask

    task write_fifo(input logic [DATA_WIDTH-1:0] data);
        begin
            @(negedge clk);
            din   = data;
            wr_en = 1'b1;
            rd_en = 1'b0;

            @(negedge clk);
            wr_en = 1'b0;
            din   = '0;
        end
    endtask

    task read_fifo_check(input logic [DATA_WIDTH-1:0] expected);
        begin
            @(negedge clk);
            rd_en = 1'b1;
            wr_en = 1'b0;

            @(posedge clk);
            #1;

            if (dout !== expected) begin
                $display("FAIL: Read expected=%0h actual=%0h", expected, dout);
                $finish;
            end

            @(negedge clk);
            rd_en = 1'b0;
        end
    endtask

    task read_empty_attempt();
        begin
            @(negedge clk);
            rd_en = 1'b1;
            wr_en = 1'b0;

            @(negedge clk);
            rd_en = 1'b0;
        end
    endtask

    task write_full_attempt(input logic [DATA_WIDTH-1:0] data);
        begin
            @(negedge clk);
            din   = data;
            wr_en = 1'b1;
            rd_en = 1'b0;

            @(negedge clk);
            wr_en = 1'b0;
            din   = '0;
        end
    endtask

    task simultaneous_write_read(
        input logic [DATA_WIDTH-1:0] write_data,
        input logic [DATA_WIDTH-1:0] expected_read
    );
        begin
            @(negedge clk);
            din   = write_data;
            wr_en = 1'b1;
            rd_en = 1'b1;

            @(posedge clk);
            #1;

            if (dout !== expected_read) begin
                $display("FAIL: Simultaneous R/W expected read=%0h actual=%0h", expected_read, dout);
                $finish;
            end

            @(negedge clk);
            wr_en = 1'b0;
            rd_en = 1'b0;
            din   = '0;
        end
    endtask

    task test_single_write_read();
        begin
            reset_fifo();

            write_fifo(8'hA5);
            check_state(1'b0, 1'b0, 1, "after single write");

            read_fifo_check(8'hA5);
            check_state(1'b1, 1'b0, 0, "after single read");

            $display("PASS: Single write/read test");
        end
    endtask

    task test_fill_overflow_drain();
        begin
            reset_fifo();

            write_fifo(8'h10);
            write_fifo(8'h20);
            write_fifo(8'h30);
            write_fifo(8'h40);

            check_state(1'b0, 1'b1, DEPTH, "after filling FIFO");
            $display("PASS: Fill test");

            write_full_attempt(8'h55);
            check_state(1'b0, 1'b1, DEPTH, "after overflow attempt");
            $display("PASS: Overflow attempt ignored");

            read_fifo_check(8'h10);
            read_fifo_check(8'h20);
            read_fifo_check(8'h30);
            read_fifo_check(8'h40);

            check_state(1'b1, 1'b0, 0, "after draining FIFO");
            $display("PASS: Drain/order test");
        end
    endtask

    task test_underflow();
        begin
            reset_fifo();

            read_empty_attempt();
            check_state(1'b1, 1'b0, 0, "after underflow attempt");

            $display("PASS: Underflow attempt ignored");
        end
    endtask

    task test_simultaneous_read_write();
        begin
            reset_fifo();

            write_fifo(8'hA1);
            write_fifo(8'hA2);
            check_state(1'b0, 1'b0, 2, "before simultaneous read/write");

            simultaneous_write_read(8'hB1, 8'hA1);
            check_state(1'b0, 1'b0, 2, "after simultaneous read/write");

            read_fifo_check(8'hA2);
            read_fifo_check(8'hB1);
            check_state(1'b1, 1'b0, 0, "after simultaneous test drain");

            $display("PASS: Simultaneous read/write test");
        end
    endtask

    task test_pointer_wraparound();
        begin
            reset_fifo();

            write_fifo(8'h01);
            write_fifo(8'h02);
            write_fifo(8'h03);
            write_fifo(8'h04);

            check_state(1'b0, 1'b1, DEPTH, "wrap test full");

            read_fifo_check(8'h01);
            read_fifo_check(8'h02);

            check_state(1'b0, 1'b0, 2, "after two reads");

            write_fifo(8'h05);
            write_fifo(8'h06);

            check_state(1'b0, 1'b1, DEPTH, "after pointer wrap writes");

            read_fifo_check(8'h03);
            read_fifo_check(8'h04);
            read_fifo_check(8'h05);
            read_fifo_check(8'h06);

            check_state(1'b1, 1'b0, 0, "after wraparound drain");

            $display("PASS: Pointer wraparound/order test");
        end
    endtask

    initial begin
        $dumpfile("sim/waves/sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);

        rst_n = 1'b1;
        wr_en = 1'b0;
        rd_en = 1'b0;
        din   = '0;

        test_single_write_read();
        test_fill_overflow_drain();
        test_underflow();
        test_simultaneous_read_write();
        test_pointer_wraparound();

        $display("Milestone 2 PASSED: all directed FIFO tests passed");
        $finish;
    end

endmodule
