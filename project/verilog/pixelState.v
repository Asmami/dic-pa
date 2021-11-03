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
    output  [7:0]   tdata
    );

    parameter rows = 4;
    parameter columns = 4;

    localparam bits = log2(rows*columns);
    
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
    logic[bits-1:0]     pixeladdr;
    tri[7:0]            pixelData;
    reg [7:0]           pixel_storage [rows*columns - 1:0]; //Storing pixels in memory

    PIXEL_ARRAY #(.row_num(rows), .column_num(columns), .bits(bits)) pa1(anaBias, anaRamp, anaReset, erase, expose, read, pixeladdr, pixelData);

    //State machine 
    parameter   IDLE=0, ERASE=1, EXPOSE=2, CONVERT=3, READ=4, SEND = 5;
    
    logic       convert;
    logic[2:0]  state;  
    integer     cnt;
    integer     read_cnt;
    integer     pixels = rows*columns;
    integer     rst_mem; 

    //State duration 
    integer erase_cnt = 5;
    integer expose_cnt = 255;
    integer convert_cnt = 255;
    integer read_dur_cnt = 5;

    function integer log2; 
        input integer value; 
    begin 
        value = value-1; 
        for (log2=0; value>0; log2=log2+1) 
            value = value>>1; 
        end 
    endfunction

    function [7:0] g2b;
        input [7:0] gray;
    begin
        integer i;
        g2b = gray;
        for (i = 6; i >= 0; i = i - 1) 
            g2b[i] = g2b[i + 1] ^ gray[i];
        end
    endfunction

    //Assigning AXIS valid and setting tlast
    reg         last;
    reg [7:0]   outData;

    assign tlast = last;
    assign tdata  = outData;
    

    //State selection
    always_ff @(posedge clk) begin
        if(rst)begin
            state = IDLE;
            last <= 0;
        end
        else begin
            case (state)
                IDLE:begin
                    read_cnt = 0;
                    last <= 0;
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
                    if(read_cnt == pixels)begin
                        state <= SEND;
                        cnt = 0;
                    end
                    if(cnt == read_dur_cnt)begin
                        read_cnt = read_cnt + 1;
                        cnt = 0;
                    end
                end
                SEND:begin
                    if(cnt == pixels)begin
                        state <= IDLE;
                        last <= 1;
                    end
                    if(ready)begin
                        cnt = cnt + 1;
                    end
                end
            endcase
            if (state == IDLE)begin
                cnt = 0;
            end
            else if(state != SEND) begin
                cnt = cnt + 1;
            end 
        end
    end

    //State output
    always_ff @(posedge clk) begin
        if (rst)begin
            for (rst_mem = 0; rst_mem < pixels ; rst_mem = rst_mem + 1) begin
                pixel_storage[rst_mem] <= 8'b0;
            end
        end
        else begin
            case(state)
                IDLE:begin
                    erase <= 0;
                    read <= 0;
                    expose <= 0;
                    convert <= 0;
                    pixeladdr <= 0;
                    outData <= 0;
                    valid <= 0;
                end
                ERASE:begin
                    erase <= 1;
                    read <= 0;
                    expose <= 0;
                    convert <= 0;
                end
                EXPOSE:begin
                    erase <= 0;
                    read <= 0;
                    expose <= 1;
                    convert <= 0;
                    pixeladdr <= 0;
                end
                CONVERT:begin
                    erase <= 0;
                    read <= 0;
                    expose <= 0;
                    convert <= 1;
                    pixeladdr <= 0;
                end
                READ:begin
                    erase <= 0;
                    read <= 1;
                    expose <= 0;
                    convert <= 0;
                    pixeladdr <= read_cnt;
                    pixel_storage[read_cnt] <= g2b(pixelData); //Converts form gray code and stores it
                    outData <= pixel_storage[0];
                end
                SEND:begin
                    erase <= 0;
                    read <= 0;
                    expose <= 0;
                    convert <= 0;
                    pixeladdr <= 0;
                    valid <= 1;

                    if(ready)begin
                        outData <= pixel_storage[cnt-2];
                    end            
                end
            endcase
        end
    end

    //DAC AND ADC stuff

    logic[7:0] data;

    assign anaRamp = convert ? clk : 0;
    assign anaBias = expose ? clk : 0;
    assign pixelData = read ? 8'bZ: data;

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