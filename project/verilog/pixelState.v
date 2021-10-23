//Author: Asbjørn Magnus Midtbø
//Created: 21/10-21
//State machine for opperating the pixel array

module PIXEL_STATE
    (
    input logic     clk,
    input logic     rst,
    input logic     trigger, //Photo trigger 

    //AXIS
    input   logic   ready,
    output  logic   valid,
    output  logic   tlast,
    output  [7:0]   data
    );

    parameter rows = 2;
    parameter columns = 2;

    integer bits = log2(rows*columns);
    
    //Analog signals
    logic   anaBias;
    logic   anaRamp;
    logic   anaReset;

    //Assign unused 
    assign anaReset = 1;

    //Digital signals
    logic               erase;
    logic               expose;
    logic[bits - 1 :0]  read;
    tri[7:0]            pixelData;
    reg [7:0]           pixel_storage [bits - 1:0]; //Storing pixels in memory

    PIXEL_ARRAY #(.row_num(rows),.column_num(columns)) pa1(anaBias, anaRamp, anaReset, erase, expose, read, pixelData);

    //State machine 
    parameter   IDLE=0, ERASE=1, EXPOSE=2, CONVERT=3, READ=4, SEND = 5;
    
    logic       convert;
    logic[2:0]  state;  
    integer     cnt;
    integer     pixels = rows*columns;
    integer     read_cnt;
    integer     rst_mem; 

    //State duration for expose and convert
    integer expose_cnt = 255;
    integer convert_cnt = 255;

    function integer log2; 
        input integer value; 
    begin 
        value = value-1; 
        for (log2=0; value>0; log2=log2+1) 
            value = value>>1; 
        end 
    endfunction

    //Assigning AXIS valid and setting tlast
    reg logic   last;

    assign tlast = last;
    assign valid = send ? 1 : 0; 

    //State selection
    always_ff @(posedge clk) begin
        if(reset)begin
            state = IDLE;
            last = 0;
            cnt = 0;
            read_cnt = 0;
            convert = 0;
            for (rst_mem = 0; rst_mem < pixels ; rst_mem = rst_mem + 1) begin
                pixel_storage[rst_mem] <= 8'b0;
            end
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