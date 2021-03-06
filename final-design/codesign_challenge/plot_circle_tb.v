
module plot_circle
#(
parameter DATAW=18,
parameter COUNT=202,
parameter CIRCLES=1
)
(
    input clk,
    input reset,
    // mem mapped slave
        // read
        input read,
        input [DATAW-1:0]address ,
        output[31:0] readdata,
        output waitrequest,
        output readdatavalid,
        // write
        input write,
        input[31:0] writedata
);


assign waitrequest = 1'b0;

wire[CIRCLES-1:0] rd;
wire[CIRCLES-1:0] rdv;

localparam WAIT=2'b00,COMPUTE=2'b01;

reg[DATAW:0] pixmem[COUNT-1:0];

reg[8:0] rx,ry;
reg[9:0] x,y, _x,_y;
reg signed[10:0] xp,_xp;
reg[7:0] index,_index;

reg[7:0] radius;
reg isset;
reg[1:0] state,_state;
reg written;


assign waitrequest = 1'b0;
assign readdatavalid = (read);
assign readdata = (read) ? (isset) : 1'h0;

wire signed [10:0] one;
assign two = 11'h1;


reg rdfinal;
reg rdvfinal;

assign readdata = {32'h0}|(rdfinal<<(address[2:0]));
assign readdatavalid = rdvfinal;

integer i = 0;

always@* 
begin
    rdfinal = 1'b0;
    rdvfinal = 1'b0;
    for(i=0; i < CIRCLES; i=i+1)
    begin
        rdfinal = rd[i] | rdfinal;
        rdvfinal = rdv[i] | rdvfinal;
    end
end
always@(posedge clk, posedge reset)
begin
    if (reset)
    begin
        for (i=0; i<COUNT; i=i+1)
        begin
            pixmem[i] <= 19'h0;
        end
        rx <= 0;
        ry <= 0;
        state <= WAIT;
        index <= 0;
    end
    else
    begin
        if(write) 
        begin
            rx <= writedata [DATAW/2-1:0];
            ry <= writedata [DATAW-1:DATAW/2];
            radius <= writedata [DATAW-1+8:DATAW];
            x <= writedata [DATAW-1+8:DATAW];
            xp <= -{3'h0,writedata [DATAW-1+8:DATAW]} + 1'b1;
            y <= 0;
            state <= COMPUTE;
            index <= 0;
        end
        else
        begin
            index <= _index;
            state <= _state;
            x <= _x;
            y <= _y;
            xp <= _xp;
            if (state == COMPUTE)
            begin
                if( ({x,y} != 0) | (radius==0))
                    pixmem[index] <= {1'b1,y[8:0],x[8:0]};
                else
                    pixmem[index] <= 0;
            end
        end

    end
end

always@*
begin

    
    _x = x;
    _y = y;
    _xp = xp;
    _state = state;
    _index = index;

    case (state)
        WAIT:
        begin
        end
        COMPUTE:
        begin
            _index = index+8'b1;
            if (x >= y)
            begin
                // pixels get set

                _y = y + 10'b1;
                if(xp < 0)
                begin
                    _xp = xp + {y,1'b0} + 11'b1;
                end
                else
                begin
                    _x = x - 10'b1;
                    _xp = xp  + {(y-x),1'b0} + 11'b1;
                end
            end
            else
            begin
                _state = WAIT;
            end
        end
    endcase

end

always@*
begin
    isset = 0;
    for(i=0; i<COUNT; i=i+1)
    begin
        if (pixmem[i][DATAW])
        begin

            isset = ({ (ry + pixmem[i][DATAW-1:DATAW/2] ), (rx + pixmem[i][DATAW/2-1:0]) } == address) |isset;
            isset =    ({ (ry - pixmem[i][DATAW-1:DATAW/2] ), (rx + pixmem[i][DATAW/2-1:0]) } == address) |isset; 
            isset =    ({ (ry + pixmem[i][DATAW-1:DATAW/2] ), (rx - pixmem[i][DATAW/2-1:0]) } == address) |isset;
            isset =    ({ (ry - pixmem[i][DATAW-1:DATAW/2] ), (rx - pixmem[i][DATAW/2-1:0]) } == address) |isset; 
            isset =    ({ (ry + pixmem[i][DATAW/2-1:0] ), (rx + pixmem[i][DATAW-1:DATAW/2]) } == address) |isset;
            isset =    ({ (ry - pixmem[i][DATAW/2-1:0] ), (rx + pixmem[i][DATAW-1:DATAW/2]) } == address) |isset;
            isset =    ({ (ry + pixmem[i][DATAW/2-1:0] ), (rx - pixmem[i][DATAW-1:DATAW/2]) } == address) |isset;
            isset =    ({ (ry - pixmem[i][DATAW/2-1:0] ), (rx - pixmem[i][DATAW-1:DATAW/2]) } == address) |isset;

            /*
            isset = ({ (ry + pixmem[i][DATAW-1:DATAW/2] ), (rx + pixmem[i][DATAW/2-1:0]) } == address) |
                ({ (ry - pixmem[i][DATAW-1:DATAW/2] ), (rx + pixmem[i][DATAW/2-1:0]) } == address) | 
                ({ (ry + pixmem[i][DATAW-1:DATAW/2] ), (rx - pixmem[i][DATAW/2-1:0]) } == address) |
                ({ (ry - pixmem[i][DATAW-1:DATAW/2] ), (rx - pixmem[i][DATAW/2-1:0]) } == address) | 
                ({ (ry + pixmem[i][DATAW/2-1:0] ), (rx + pixmem[i][DATAW-1:DATAW/2]) } == address) |
                ({ (ry - pixmem[i][DATAW/2-1:0] ), (rx + pixmem[i][DATAW-1:DATAW/2]) } == address) |
                ({ (ry + pixmem[i][DATAW/2-1:0] ), (rx - pixmem[i][DATAW-1:DATAW/2]) } == address) |
                ({ (ry - pixmem[i][DATAW/2-1:0] ), (rx - pixmem[i][DATAW-1:DATAW/2]) } == address) |isset;
            */
        end
    end
end

endmodule
