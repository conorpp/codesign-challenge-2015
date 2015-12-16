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

/*
plot_pixel #(.ID(12)) p11(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[11]),.waitrequest(),
    .readdatavalid(rdv[11]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(13)) p12(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[12]),.waitrequest(),
    .readdatavalid(rdv[12]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(14)) p13(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[13]),.waitrequest(),
    .readdatavalid(rdv[13]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(15)) p14(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[14]),.waitrequest(),
    .readdatavalid(rdv[14]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(16)) p15(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[15]),.waitrequest(),
    .readdatavalid(rdv[15]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(17)) p16(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[16]),.waitrequest(),
    .readdatavalid(rdv[16]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(18)) p17(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[17]),.waitrequest(),
    .readdatavalid(rdv[17]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(19)) p18(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[18]),.waitrequest(),
    .readdatavalid(rdv[18]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(20)) p19(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[19]),.waitrequest(),
    .readdatavalid(rdv[19]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(21)) p20(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[20]),.waitrequest(),
    .readdatavalid(rdv[20]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(22)) p21(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[21]),.waitrequest(),
    .readdatavalid(rdv[21]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(23)) p22(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[22]),.waitrequest(),
    .readdatavalid(rdv[22]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(24)) p23(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[23]),.waitrequest(),
    .readdatavalid(rdv[23]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(25)) p24(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[24]),.waitrequest(),
    .readdatavalid(rdv[24]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(26)) p25(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[25]),.waitrequest(),
    .readdatavalid(rdv[25]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(27)) p26(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[26]),.waitrequest(),
    .readdatavalid(rdv[26]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(28)) p27(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[27]),.waitrequest(),
    .readdatavalid(rdv[27]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(29)) p28(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[28]),.waitrequest(),
    .readdatavalid(rdv[28]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(30)) p29(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[29]),.waitrequest(),
    .readdatavalid(rdv[29]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(31)) p30(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[30]),.waitrequest(),
    .readdatavalid(rdv[30]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(32)) p31(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[31]),.waitrequest(),
    .readdatavalid(rdv[31]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(33)) p32(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[32]),.waitrequest(),
    .readdatavalid(rdv[32]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(34)) p33(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[33]),.waitrequest(),
    .readdatavalid(rdv[33]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(35)) p34(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[34]),.waitrequest(),
    .readdatavalid(rdv[34]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(36)) p35(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[35]),.waitrequest(),
    .readdatavalid(rdv[35]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(37)) p36(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[36]),.waitrequest(),
    .readdatavalid(rdv[36]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(38)) p37(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[37]),.waitrequest(),
    .readdatavalid(rdv[37]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(39)) p38(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[38]),.waitrequest(),
    .readdatavalid(rdv[38]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(40)) p39(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[39]),.waitrequest(),
    .readdatavalid(rdv[39]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(41)) p40(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[40]),.waitrequest(),
    .readdatavalid(rdv[40]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(42)) p41(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[41]),.waitrequest(),
    .readdatavalid(rdv[41]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(43)) p42(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[42]),.waitrequest(),
    .readdatavalid(rdv[42]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(44)) p43(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[43]),.waitrequest(),
    .readdatavalid(rdv[43]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(45)) p44(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[44]),.waitrequest(),
    .readdatavalid(rdv[44]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(46)) p45(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[45]),.waitrequest(),
    .readdatavalid(rdv[45]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(47)) p46(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[46]),.waitrequest(),
    .readdatavalid(rdv[46]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(48)) p47(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[47]),.waitrequest(),
    .readdatavalid(rdv[47]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(49)) p48(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[48]),.waitrequest(),
    .readdatavalid(rdv[48]),
    .write(write),.writedata(writedata));

plot_pixel #(.ID(50)) p49(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[49]),.waitrequest(),
    .readdatavalid(rdv[49]),
    .write(write),.writedata(writedata));

plot_pixel p2(.clk(clk),.reset((reset) | ( reset_sync & ((6'h0 == writedata[31:26]) & write) )),.read(read),.address(address),
    .readdata(rd[1]),.waitrequest(),
    .readdatavalid(rdv[1]),
    .write((write & ( 6'h2 == writedata[31:26] )) ),.writedata(writedata));

plot_pixel p3(.clk(clk),.reset((reset) | ( reset_sync & ((6'h0 == writedata[31:26]) & write) )),.read(read),.address(address),
    .readdata(rd[2]),.waitrequest(),
    .readdatavalid(rdv[2]),
    .write((write & ( 6'h3 == writedata[31:26] )) ),.writedata(writedata));
*/

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
