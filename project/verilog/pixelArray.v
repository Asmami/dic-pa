//Author: Asbjørn Magnus Midtbø
//Created: 21/10-21
//Pixel array containing four pixel sensors

module PIXEL_ARRAY
    #(
    parameter row_num = 2,
    parameter column_num = 2,
    parameter bits = 2
    )
    (
    input logic         VBN1,
    input logic         RAMP,
    input logic         RESET,
    input logic         ERASE,
    input logic         EXPOSE,
    input logic         READ,
    input [bits-1:0]    PIXELADDR,  
    inout [7:0]         DATA
    );

    genvar i;
    genvar j;

    generate
        for (i = 0; i < column_num; i = i + 1) begin
            for (j = 0; j < row_num; j = j + 1) begin
                PIXEL_SENSOR #(.addressBits(bits), .pixeladdress(i*row_num + j), .dv_pixel_div(0.1*i+0.1*j+1)) ps_ij(VBN1, RAMP, RESET, ERASE, EXPOSE, READ, PIXELADDR, DATA); 
            end
        end
    endgenerate

endmodule