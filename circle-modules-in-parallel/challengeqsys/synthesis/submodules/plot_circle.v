
module plot_circle
#(
parameter DATAW=18,
parameter CIRCLES=3
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

reg rdfinal;
reg rdvfinal;

reg reset_sync;

always@(posedge clk, posedge reset)
begin

    if (reset)
    begin
        reset_sync <= 0;
    end
    else
    begin
        reset_sync <= (6'h0 == writedata[31:26]) & write;
    end

end

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



plot_pixel p1(.clk(clk),.reset((reset) | ( reset_sync & ((6'h0 == writedata[31:26]) & write) )),.read(read),.address(address),
    .readdata(rd[0]),.waitrequest(),
    .readdatavalid(rdv[0]),
    .write((write & ( 6'h1 == writedata[31:26] )) ),.writedata(writedata));

plot_pixel p2(.clk(clk),.reset((reset) | ( reset_sync & ((6'h0 == writedata[31:26]) & write) )),.read(read),.address(address),
    .readdata(rd[1]),.waitrequest(),
    .readdatavalid(rdv[1]),
    .write((write & ( 6'h2 == writedata[31:26] )) ),.writedata(writedata));

plot_pixel p3(.clk(clk),.reset((reset) | ( reset_sync & ((6'h0 == writedata[31:26]) & write) )),.read(read),.address(address),
    .readdata(rd[2]),.waitrequest(),
    .readdatavalid(rdv[2]),
    .write((write & ( 6'h3 == writedata[31:26] )) ),.writedata(writedata));


endmodule


module plot_pixel
#(
parameter DATAW=18,
)
(
    input clk,
    input reset,
    input[7:0] mindex,
    // mem mapped slave
        // read
        input read,
        input [DATAW-1:0]address ,
        output readdata,
        output waitrequest,
        output readdatavalid,
        // write
        input write,
        input[31:0] writedata
);

localparam WAIT=4'h0,COMPUTE=2'h1,
           WRITE0=4'h3,
           WRITE1=4'h4,
           WRITE2=4'h5,
           WRITE3=4'h6,
           WRITE4=4'h7,
           WRITE5=4'h8,
           WRITE6=4'h9,
           WRITE7=4'h10;

true_dual_port_ram_single_clock#( .DATA_WIDTH(1), .ADDR_WIDTH(DATAW))
(.data_a(isset), .data_b(1'b0), .addr_a(addr_a), .addr_b(addr_b),
.we_a(we_a), .we_b(1'b0), .clk(clk),
.q_a(q_a), .q_b());

reg[8:0] rx,ry;
reg signed[9:0] x,y, _x,_y;
reg signed[10:0] xp,_xp;
reg[7:0] index,_index;

reg[7:0] radius;
reg isset,_isset;
reg[3:0] state,_state;
reg we_a, we_b
wire q_a, q_b;
reg[DATAW-1:0] addr_a, addr_b;



assign waitrequest = 1'b0;
assign readdatavalid = (read);
assign readdata = (read) ? (q_a) : 1'h0;

integer i = 0;

always@(posedge clk, posedge reset)
begin
    if (reset)
    begin
        rx <= 0;
        ry <= 0;
        y <= 0;
        x <= 0;
        state <= WAIT;
        index <= 0;
        isset <= 0;
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
            isset <= 0;
        end
        else
        begin
            index <= _index;
            state <= _state;
            x <= _x;
            y <= _y;
            xp <= _xp;
            isset <= _isset;
        end

    end
end

always@*{ (ry + pixmem[i][DATAW-1:DATAW/2] ), (rx + pixmem[i][DATAW/2-1:0]) }
begin

    
    _x = x;
    _y = y;
    _xp = xp;
    _state = state;
    _index = index;
    _isset = 1'b1;
    we_a = 1'b0;
    we_b = 1'b0;
    addr_a = address;
    addr_b = address;

    case (state)
        WAIT:
        begin
            _isset = 1'b0;
        end
        COMPUTE:
        begin
            if (index != mindex)
            begin
                _index = index+1'b1;
                if (x >= y)
                begin
                    // pixels get set

                    _y = y + 1'b1;
                    if(xp < 0)
                    begin
                        _xp = xp + {_y,1'b0} + 1'b1;
                    end
                    else
                    begin
                        _x = x - 1'b1;
                        _xp = xp  + {(_y-_x),1'b0} + 1'b1;
                    end
                    _state = WRITE1;
                end
                else
                begin
                    _state = WAIT;
                end
            end
        end
        WRITE0:
        begin
            we_a = 1'b1;
            addr_a = { (ry + y ), (rx + x) };
            _state = WRITE1;
        end
        WRITE1:
        begin
            we_a = 1'b1;
            addr_a = { (ry - y), (rx + x)};
            _state = WRITE2;
        end
        WRITE2:
        begin
            we_a = 1'b1;
            addr_a = { (ry + y), (rx - x)};
            _state = WRITE3;
        end
        WRITE3:
        begin
            we_a = 1'b1;
            addr_a = { (ry - y), (rx - x)};
            _state = WRITE4;
        end
        WRITE4:
        begin
            we_a = 1'b1;
            addr_a = { (ry + x), (rx + y)};
            _state = WRITE5;
        end
        WRITE5:
        begin
            we_a = 1'b1;
            addr_a = { (ry - x), (rx + y)};
            _state = WRITE6;
        end
        WRITE6:
        begin
            we_a = 1'b1;
            addr_a = { (ry + x), (rx -y) };
            _state = WRITE7;
        end
        WRITE7:
        begin
            we_a = 1'b1;
            addr_a = { (ry - x), (rx - y)};
            _state = COMPUTE;
        end


    endcase

end

//reg[201:0] sets;

always@*
begin

end
//assign isset = (sets == 202'h0) ? 1'b0 : 1'b1;


endmodule

// Quartus II Verilog Template
// True Dual Port RAM with single clock

module true_dual_port_ram_single_clock
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data_a, data_b,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b,
	input we_a, we_b, clk,
	output reg [(DATA_WIDTH-1):0] q_a, q_b
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end 
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) 
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end 
	end

endmodule
