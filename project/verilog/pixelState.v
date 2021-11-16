//Author: Asbjørn Magnus Midtbø
//Created: 21/10-21
//State machine for opperating the pixel array

module PIXEL_STATE
    (
    input logic     clk,
    input logic     rst,
    input logic     trigger, //Photo trigger 

    //AXIS signals to stream the pixel data
    input   logic   ready,
    output  logic   valid,
    output  logic   tlast,
    output  [7:0]   tdata 
    );

    parameter rows = 4;                     //Number of pixel rows 
    parameter columns = 4;                  //Number of pixel colums

    //Localparam so it will be constant (will give error else)
    localparam pixels = rows*columns;       //Number of pixels 
    localparam bits = log2(pixels);         //Number of bits needed to represent the number of pixels
    
    //Analog signals
    logic   anaBias;                                             
    logic   anaRamp;
    logic   anaReset;

    //Assign unused 
    assign anaReset = 1;

    //Digital signals
    logic               erase;
    logic               expose;
    logic               read;
    logic[bits-1:0]     pixeladdr;          //Used to select spesific pixels
    tri[7:0]            pixelData;
    reg [7:0]           pixel_storage [rows*columns - 1:0]; //Storing pixels in register

    //Pixel array module 
    PIXEL_ARRAY #(.row_num(rows), .column_num(columns), .bits(bits)) pa1(anaBias, anaRamp, anaReset, erase, expose, read, pixeladdr, pixelData);

    //State machine 
    parameter   IDLE=0, ERASE=1, EXPOSE=2, CONVERT=3, READ=4, SEND = 5;
    
    logic       convert;    
    logic[2:0]  state;      
    integer     cnt;        
    integer     read_cnt;       //Used to count how many pixels that have been read
    integer     out_cnt;        //Used to count how many pixels that have been sent out through the AXIS
    integer     rst_mem;        //Counter used when reseting the pixel memory array

    //State duration 
    integer erase_cnt = 5;
    integer expose_cnt = 255;
    integer convert_cnt = 255;
    integer read_dur_cnt = 5;

    function integer log2;      //Function used to determine how many bits needed to represent a number
        input integer value; 
    begin 
        value = value-1; 
        for (log2=0; value>0; log2=log2+1) 
            value = value>>1; 
        end 
    endfunction

    function [7:0] g2b;        //Function used to convert from gary code to binary code
        input [7:0] gray;
    begin
        integer i;
        g2b = gray;
        for (i = 6; i >= 0; i = i - 1) 
            g2b[i] = g2b[i + 1] ^ gray[i];
        end
    endfunction

    //Assigning AXIS tlast and tdata from registers set in the state machine 
    reg [7:0]   outData;

    assign valid = (state == SEND) ? 1'b1 : 1'b0;                           //Valid output high when the state machine is in the SEND state
    assign tlast = (out_cnt == pixels - 1 && state == SEND) ? 1'b1 : 1'b0;  //last is high when the last data packet is sendt
    assign tdata  = (state == SEND) ? outData : 8'b0;                       //Output data when in the SEND state

    //State selection
    always_ff @(posedge clk) begin
        if(rst)begin
            state = IDLE;
        end
        else begin
            case (state)
                IDLE:begin
                    if(trigger)begin
                        state <= ERASE;
                    end
                end
                ERASE:begin
                    if(cnt == erase_cnt)begin
                        state <= EXPOSE;
                        cnt = 0;
                    end
                end
                EXPOSE:begin
                    if(cnt == expose_cnt)begin
                        state <= CONVERT;
                        cnt = 0;
                    end
                end
                CONVERT:begin
                    if(cnt == convert_cnt)begin
                        state <= READ;
                        cnt = 0;
                    end
                end
                READ:begin
                    if(read_cnt == pixels)begin         //Change state if all pixels have been read
                        state <= SEND;
                        cnt = 0;
                    end
                    if(cnt == read_dur_cnt)begin        //Reading duration
                        read_cnt = read_cnt + 1;        
                        cnt = 0;
                    end
                end
                SEND:begin
                    if(tlast && ready && valid)begin    //Go to idle when tlast, ready and valid is high
                        state <= IDLE;
                    end
                    if (ready) begin                   
                        out_cnt = out_cnt + 1;
                    end
                end
            endcase
            if (state == IDLE)begin
                cnt = 0;
                read_cnt = 0;
                out_cnt = 0;
            end
            else begin
                cnt = cnt + 1;
            end 
        end
    end

    //State outputs
    always_ff @(posedge clk) begin
        case(state)
            IDLE:begin
                erase <= 0;
                read <= 0;
                expose <= 0;
                convert <= 0;
                pixeladdr <= 0;
                outData <= 0;
                for (rst_mem = 0; rst_mem < pixels ; rst_mem = rst_mem + 1) begin   //Reset array
                    pixel_storage[rst_mem] <= 8'b0;
                end
            end
            ERASE:begin
                erase <= 1;
            end
            EXPOSE:begin
                erase <= 0;
                expose <= 1;
            end
            CONVERT:begin
                expose <= 0;
                convert <= 1;
            end
            READ:begin
                read <= 1;
                convert <= 0;
                pixeladdr <= read_cnt;                      //Output read cout as the address to the array module to read spesific pixels
                pixel_storage[read_cnt] <= g2b(pixelData);  //Converts form gray code and stores it
                outData <= pixel_storage[out_cnt];          //Load first data into output register so it is ready to be sendt 
            end
            SEND:begin
                read <= 0;
                if(ready)begin
                    outData <= pixel_storage[out_cnt];      //Change the output register if the recipient is ready
                end            
            end
        endcase
    end

    //DAC AND ADC stuff

    logic[7:0] data;

    assign anaRamp = convert ? clk : 0;     //input clk when converting
    assign anaBias = expose ? clk : 0;      //input clk when exposing
    assign pixelData = read ? 8'bZ: data;   //input data when not reading

    //Drive the convertion by writing to data to the pixels
    logic[7:0]  q; //Used for gray counter;

    always_ff @(posedge clk)begin
        if(rst)begin
            q = 0;
        end
        if(convert)begin
            q = q + 1;
        end
        else begin
            q = 0;
        end
        data <= {q[7], q[7:1] ^ q[6:0]}; //Gray count into the sensors
    end

endmodule