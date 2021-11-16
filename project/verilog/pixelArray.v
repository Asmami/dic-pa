//Author: Asbjørn Magnus Midtbø
//Created: 21/10-21
//Pixel array containing a variable number of pixel sensors

module PIXEL_ARRAY
    #(
    parameter row_num = 2,              //Number of row pixels
    parameter column_num = 2,           //Number of column pixels
    parameter bits = 2                  //Used to set number of address bits
    )
    (
    input logic         VBN1,           //-- = Inputs just ported through to the pixel sensor from the state machine
    input logic         RAMP,           //--
    input logic         RESET,          //--
    input logic         ERASE,          //--
    input logic         EXPOSE,         //--
    input logic         READ,           //Used by a always_comb process to decide if to read
    input [bits-1:0]    PIXELADDR,      //Used to decide which pixel to enable
    inout [7:0]         DATA            //--
    );

    localparam pixels = row_num*column_num; 
    logic[pixels - 1:0] read_en;            //Read enable array, each sensor will use one bit each as the read input
    genvar i;
    genvar j;

    //Makes a pixel array in a matrix style for loops
    //Added a pixel address as a parameter to keep track of the different pixels
    //The dv_pixel parameter is now dicided by a divisor given when initiating the pixel (Gives a few different expected values)  
    generate
        for (i = 0; i < column_num; i = i + 1) begin : column_pixels
            for (j = 0; j < row_num; j = j + 1) begin : row_pixels
                PIXEL_SENSOR #(.dv_pixel_div(0.1*i+0.1*j+1)) ps_ij(VBN1, RAMP, RESET, ERASE, EXPOSE, read_en[i*row_num + j], DATA); 
            end
        end
    endgenerate

    //Process to shift which pixel is read from based on the address input
    always_comb begin
        if (READ)begin
            read_en[PIXELADDR-1] <= 1'b0;
            read_en[PIXELADDR] <= 1'b1;
        end
        else begin
            read_en <= 0;
        end
    end

endmodule