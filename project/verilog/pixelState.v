//Author: Asbjørn Magnus Midtbø
//Created: 21/10-21
//State machine for opperating the pixel array

module PIXEL_STATE
    (
    input logic     clk,
    input logic     rst,
    input logic     trigger, //Photo trigger
    output [31:0]   data
    );

    //Pixel sensitivity. 0 equals low sens and 1 equals high sens 
    parameter real  dv_pixel = 0.5; //Since all the pixels uses the same sensitivity, the "picture" will be uniform

    //Analog signals
    logic   anaBias;
    logic   anaRamp;
    logic   anaReset;

    //Assign unused 
    assign anaReset = 1;

    //Digital signals
    logic       erase;
    logic       expose;
    logic[3:0]  read;
    tri[7:0]    pixelData;
    logic[31:0] arrayData;

    PIXEL_ARRAY #(.dv_pixel(dv_pixel)) pa1(anaBias, anaRamp, anaReset, erase, expose, read, pixelData);

    //State machine 
    parameter   IDLE=0, ERASE=1, EXPOSE=2, CONVERT=3, READ=4;
    
    logic       convert;
    logic[2:0]  state;  
    integer     cnt;
    integer     read_cnt; 

    //State duration for expose and convert
    parameter integer expose_cnt = 255;
    parameter integer convert_cnt = 255;

    //State selection
    always_ff @(posedge clk) begin
        if(reset)begin
            state = IDLE;
            cnt = 0;
            read_cnt = 0;
            convert = 0;
        else begin
            case (state)
                IDLE:begin
                    
                end
                ERASE:begin
                    
                end
                EXPOSE:begin
                    
                end
                CONVERT:begin
                    
                end
                READ:begin
                    
                end
            endcase
        end
    end

endmodule