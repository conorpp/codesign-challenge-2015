module plot_circle
#(
parameter DATAW=18,
parameter CIRCLES=13
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

assign readdata = (rdfinal<<(address[2:0]));
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


plot_pixel #(.ID(1)) p0(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[0]),.waitrequest(),
    .readdatavalid(rdv[0]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(2)) p1(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[1]),.waitrequest(),
    .readdatavalid(rdv[1]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(3)) p2(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[2]),.waitrequest(),
    .readdatavalid(rdv[2]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(4)) p3(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[3]),.waitrequest(),
    .readdatavalid(rdv[3]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(5)) p4(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[4]),.waitrequest(),
    .readdatavalid(rdv[4]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(6)) p5(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[5]),.waitrequest(),
    .readdatavalid(rdv[5]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(7)) p6(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[6]),.waitrequest(),
    .readdatavalid(rdv[6]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(8)) p7(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[7]),.waitrequest(),
    .readdatavalid(rdv[7]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(9)) p8(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[8]),.waitrequest(),
    .readdatavalid(rdv[8]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(10)) p9(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[9]),.waitrequest(),
    .readdatavalid(rdv[9]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(11)) p10(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[10]),.waitrequest(),
    .readdatavalid(rdv[10]),
    .write(write),.writedata(writedata));

endmodule


module plot_pixel
#(
parameter DATAW=18,
parameter ID=1
)
(
    input clk,
    input reset,
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

localparam WAIT=5'h0,COMPUTE=5'h1,
           WRITE0=5'h3,
           WRITE1=5'h4,
           WRITE2=5'h5,
           WRITE3=5'h6,
           WRITE4=5'h7,
           WRITE5=5'h8,
           WRITE6=5'h9,
           WRITE7=5'h10;

reg[8:0] rx,ry;
reg signed[9:0] x,y, _x,_y;
reg signed[10:0] xp,_xp;

reg[7:0] radius;
reg isset,lread;
reg[4:0] state,_state;
reg we_a, we_b;
wire q_a, q_b;
reg[DATAW-1:0] addr_a, addr_b; 

true_dual_port_ram_single_clock #( .DATA_WIDTH(1), .ADDR_WIDTH(DATAW))
ram0 (.data_a(isset), .data_b(isset), .addr_a(addr_a), .addr_b(addr_b),
.we_a(we_a), .we_b(we_b), .clk(clk),
.q_a(q_a), .q_b(q_b));


assign waitrequest = 1'b0;
assign readdatavalid = (lread);
assign readdata = q_a;
wire tome, toall;
assign tome = (writedata[31:26] == ID);
assign toall = (writedata[31:26] == 0);

always@(posedge clk, posedge reset)
begin
    if (reset)
    begin
        rx <= 0;
        ry <= 0;
        y <= 0;
        x <= 0;
        state <= WAIT;
        lread <= 0;
    end
    else
    begin
        lread <= read;
        if(write & tome) 
        begin
            rx <= writedata [DATAW/2-1:0];
            ry <= writedata [DATAW-1:DATAW/2];
            radius <= writedata [DATAW-1+8:DATAW];
            x <= writedata [DATAW-1+8:DATAW];
            xp <= -{3'h0,writedata [DATAW-1+8:DATAW]} + 1'b1;
            y <= 0;
            state <= WRITE0;
        end
        else
        begin
            state <= _state;
            x <= _x;
            y <= _y;
            xp <= _xp;
        end

    end
end

always@*
begin
    
    _x = x;
    _y = y;
    _xp = xp;
    _state = state;
    isset = ~(write&(toall));
    we_a = write&toall;
    we_b = write&toall;

    addr_a = address;
    addr_b = address;

    case (state)
        WAIT:
        begin
        end
        COMPUTE:
        begin
            if (x >= y)
            begin

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
                if (radius != 0)
                begin
                    we_a = 1'b1;
                    we_b = 1'b1;
                    addr_a = { (ry + _y[8:0] ), (rx + _x[8:0]) };
                    addr_b = { (ry + _x[8:0]), (rx + _y[8:0])};
                    _state = WRITE1;
                end
                else
                begin
                    _state = WAIT;
                end            
            end
            else
            begin
                _state = WAIT;
            end
        end
        WRITE0:
        begin
            we_a = 1'b1;
            we_b = 1'b1;
            addr_a = { (ry + y[8:0] ), (rx + x[8:0]) };
            addr_b = { (ry + x[8:0]), (rx + y[8:0])};
            _state = WRITE1;
        end
        WRITE1:
        begin
            we_a = 1'b1;
            we_b = 1'b1;
            addr_a = { (ry - y[8:0]), (rx + x[8:0])};
            addr_b = { (ry - x[8:0]), (rx + y[8:0])};
            _state = WRITE2;
        end
        WRITE2:
        begin
            we_a = 1'b1;
            we_b = 1'b1;
            addr_a = { (ry + y[8:0]), (rx - x[8:0])};
            addr_b = { (ry + x[8:0]), (rx -y[8:0]) };
            _state = WRITE3;
        end
        WRITE3:
        begin
            we_a = 1'b1;
            we_b = 1'b1;
            addr_a = { (ry - y[8:0]), (rx - x[8:0])};
            addr_b = { (ry - x[8:0]), (rx - y[8:0])};
            _state = COMPUTE;
        end

    endcase

end


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
