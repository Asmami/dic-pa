//Author: Asbjørn Magnus Midtbø
//Created: 21/10-21
//Pixel array containing four pixel sensors

module PIXEL_ARRAY;
    (
    input logic     VBN1,
    input logic     RAMP,
    input logic     RESET,
    input logic     ERASE,
    input logic     EXPOSE,
    input [3:0]     READ,   
    inout [7:0]     DATA
    );

    parameter real  dv_pixel = 0.5;

    PIXEL_SENSOR #(.dv_pixel(dv_pixel)) ps1(VBN1,RAMP, RESET, ERASE, EXPOSE, READ[0], DATA);
    PIXEL_SENSOR #(.dv_pixel(dv_pixel)) ps2(VBN1,RAMP, RESET, ERASE, EXPOSE, READ[1], DATA);
    PIXEL_SENSOR #(.dv_pixel(dv_pixel)) ps3(VBN1,RAMP, RESET, ERASE, EXPOSE, READ[2], DATA);
    PIXEL_SENSOR #(.dv_pixel(dv_pixel)) ps4(VBN1,RAMP, RESET, ERASE, EXPOSE, READ[3], DATA);

endmodule