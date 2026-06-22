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

    logic [DATA_WIDTH-1:0] expected_q[$];

    logic sb_do_read;
    logic sb_do_write;
    logic [DATA_WIDTH-1:0] sb_expected_data;
    int expected_count;

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

    always @(posedge clk) begin
        if (!rst_n) begin
            expected_q.delete();
        end else begin
            sb_do_read  = rd_en && !empty;
            sb_do_write = wr_en && (!full || sb_do_read);

            if (sb_do_read) begin
                if (expected_q.size() == 0) begin
                    fail_test("Scoreboard underflow: DUT read but expected queue is empty");
                end

                sb_expected_data = expected_q.pop_front();
            end

            if (sb_do_write) begin
                expected_q.push_back(din);
            end

            #1;

            if (sb_do_read) begin
                if (dout !== sb_expected_data) begin
                    $display("FAIL: Scoreboard mismatch. Expected=%0h Actual=%0h",
                             sb_expected_data, dout);
                    $finish;
                end
            end

            expected_count = expected_q.size();

            if (dut.count != expected_count) begin
                $display("FAIL: Count mismatch. Expected=%0d Actual=%0d",
                         expected_count, dut.count);
                $finish;
            end

            if ((expected_count == 0) && (empty !== 1'b1)) begin
                fail_test("Empty flag mismatch: expected empty=1");
            end

            if ((expected_count != 0) && (empty !== 1'b0)) begin
                fail_test("Empty flag mismatch: expected empty=0");
            end

            if ((expected_count == DEPTH) && (full !== 1'b1)) begin
                fail_test("Full flag mismatch: expected full=1");
            end

            if ((expected_count != DEPTH) && (full !== 1'b0)) begin
                fail_test("Full flag mismatch: expected full=0");
            end
        end
    end

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

    task read_fifo();
        begin
            @(negedge clk);
            rd_en = 1'b1;
            wr_en = 1'b0;

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

    task simultaneous_write_read(input logic [DATA_WIDTH-1:0] write_data);
        begin
            @(negedge clk);
            din   = write_data;
            wr_en = 1'b1;
            rd_en = 1'b1;

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

            read_fifo();
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

            read_fifo();
            read_fifo();
            read_fifo();
            read_fifo();

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

            simultaneous_write_read(8'hB1);
            check_state(1'b0, 1'b0, 2, "after simultaneous read/write");

            read_fifo();
            read_fifo();
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

            read_fifo();
            read_fifo();

            check_state(1'b0, 1'b0, 2, "after two reads");

            write_fifo(8'h05);
            write_fifo(8'h06);

            check_state(1'b0, 1'b1, DEPTH, "after pointer wrap writes");

            read_fifo();
            read_fifo();
            read_fifo();
            read_fifo();

            check_state(1'b1, 1'b0, 0, "after wraparound drain");

            $display("PASS: Pointer wraparound/order test");
        end
    endtask


    task test_randomized();
        int i;
        int drain_guard;
        begin
            reset_fifo();

            for (i = 0; i < 200; i = i + 1) begin
                @(negedge clk);
                wr_en = $urandom_range(0, 1);
                rd_en = $urandom_range(0, 1);
                din   = $urandom_range(0, 255);
            end

            @(negedge clk);
            wr_en = 1'b0;
            rd_en = 1'b0;
            din   = '0;

            drain_guard = 0;

            while (!empty && drain_guard < DEPTH + 20) begin
                read_fifo();
                drain_guard = drain_guard + 1;
            end

            if (!empty) begin
                fail_test("Randomized test failed to drain FIFO");
            end

            check_state(1'b1, 1'b0, 0, "after randomized test drain");

            $display("PASS: Randomized traffic test");
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
        test_randomized();

        $display("Milestone 4 PASSED: directed and randomized tests with scoreboard");
        $finish;
    end

endmodule
