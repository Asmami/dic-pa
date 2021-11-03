`timescale 1 ns / 1 ps

module pixelState_tb;

logic clk = 0;
logic rst = 0;
logic trigger = 0;
parameter integer clk_period = 500;
parameter integer sim_end = clk_period*5000;
always #clk_period clk=~clk;

logic ready = 1;
logic valid;
logic tlast;
logic [7:0] tdata;

PIXEL_STATE ps1(clk, rst, trigger, ready, valid, tlast, tdata);

always_ff @(posedge clk) begin
    if (valid)begin
        ready <= 0;
    end
    if(valid && ~ready) begin
        ready <= 1;
    end
end

initial begin
    rst = 1;

    #clk_period;
    #clk_period rst = 0;

    #clk_period;

    trigger = 1;

    #clk_period;

    #clk_period trigger = 0;
    



    $dumpfile("pixelState_tb.vcd");
    $dumpvars(0,pixelState_tb);

    #sim_end
        $stop;
end

endmodule