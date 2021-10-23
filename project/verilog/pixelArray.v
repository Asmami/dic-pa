//Author: Asbjørn Magnus Midtbø
//Created: 21/10-21
//Pixel array containing four pixel sensors

module PIXEL_ARRAY
    (
    input logic                             VBN1,
    input logic                             RAMP,
    input logic                             RESET,
    input logic                             ERASE,
    input logic                             EXPOSE,
    input [log2(row_num*column_num)-1:0]    READ,  
    inout [7:0]                             DATA
    );

    parameter row_num = 2;
    parameter column_num = 2;

    function integer log2; 
        input integer value; 
    begin 
        value = value-1; 
        for (log2=0; value>0; log2=log2+1) 
            value = value>>1; 
        end 
    endfunction 

    genvar i;
    genvar j;

    generate
        for (i = 0; i < column_num; i = i + 1) begin
            for (j = 0; j < row_num; j = j + 1) begin
                PIXEL_SENSOR ps_ij(VBN1,RAMP, RESET, ERASE, EXPOSE, READ[i*row_num+j], DATA);
            end 
        end
    endgenerate

endmodule