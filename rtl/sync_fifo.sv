`timescale 1ns/1ps

module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16
)(
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic                   wr_en,
    input  logic                   rd_en,
    input  logic [DATA_WIDTH-1:0]  din,

    output logic [DATA_WIDTH-1:0]  dout,
    output logic                   full,
    output logic                   empty
);

    localparam int PTR_WIDTH   = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    localparam int COUNT_WIDTH = $clog2(DEPTH + 1);

    localparam logic [PTR_WIDTH-1:0]   LAST_PTR    = PTR_WIDTH'(DEPTH - 1);
    localparam logic [COUNT_WIDTH-1:0] DEPTH_COUNT = COUNT_WIDTH'(DEPTH);
    localparam logic [COUNT_WIDTH-1:0] COUNT_ONE   = COUNT_WIDTH'(1);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr;
    logic [COUNT_WIDTH-1:0] count;

    logic wr_accept;
    logic rd_accept;

    assign full  = (count == DEPTH_COUNT);
    assign empty = (count == '0);

    assign rd_accept = rd_en && !empty;
    assign wr_accept = wr_en && (!full || rd_accept);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            dout   <= '0;
        end else begin
            if (wr_accept) begin
                mem[wr_ptr] <= din;

                if (wr_ptr == LAST_PTR)
                    wr_ptr <= '0;
                else
                    wr_ptr <= wr_ptr + PTR_WIDTH'(1);
            end

            if (rd_accept) begin
                dout <= mem[rd_ptr];

                if (rd_ptr == LAST_PTR)
                    rd_ptr <= '0;
                else
                    rd_ptr <= rd_ptr + PTR_WIDTH'(1);
            end

            case ({wr_accept, rd_accept})
                2'b10: count <= count + COUNT_ONE;
                2'b01: count <= count - COUNT_ONE;
                default: count <= count;
            endcase
        end
    end

endmodule
