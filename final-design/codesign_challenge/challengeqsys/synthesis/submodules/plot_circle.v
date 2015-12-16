module plot_circle
#(
parameter DATAW=18,
parameter CIRCLES=12
)
(
    input clk,
    input clkfast,
    input reset,
    // mem mapped slave
        // read
        input read,
        input [DATAW-1+1:0]address ,
        output[31:0] readdata,
        output waitrequest,
        output readdatavalid,
        // write
        input write,
        input[31:0] writedata,

    // mem mapped master
        // read
        output mread,
        output [DATAW-1:0]maddress ,
        input[31:0] mreaddata,
        input mwaitrequest,
        input mreaddatavalid,
        // write
        output mwrite,
        output [31:0] mwritedata

);


assign waitrequest = 1'b0;
localparam WAIT = 5'h0, READX=5'h1, READY=5'h2, READR=5'h3, BLOCK=5'h4;
reg[4:0] state,_state,lstate;

wire[7:0] rd[CIRCLES-1:0];
wire[CIRCLES-1:0] rdv;
wire[CIRCLES-1:0] ready;
reg[CIRCLES-1:0] ready_sync;

reg[7:0] rdfinal;
reg[31:0] writedatac[CIRCLES-1:0];
reg[CIRCLES-1:0] writec;
reg[CIRCLES-1:0] cselect;

reg[31:0] newdx, newdy,newdr,_mwritedata;
reg[DATAW-1:0] basex, baser, basey, _maddress;
reg signed[9:0] offset,_offset;

reg rdvfinal, _mread, _mwrite;

wire readstate;
wire readcircle;

assign readstate = (address == 19'h40000) ? 1'b1 : 1'b0;
assign writestart = ((address == 19'h40004) & write) ? 1'b1 : 1'b0;

assign readcircle = read & ~readstate;


assign readdata = readstate ? (ready) : (rdfinal);
assign readdatavalid = rdvfinal | readstate;

wire broadcast;
assign broadcast = (writedata[31:26] == 0) & (address[DATAW-1+1] == 1'b0);

assign mread = _mread;
assign mwrite = _mwrite;
assign maddress = _maddress;
assign mwritedata = _mwritedata;

wire writeready;
wire[31:0] writecircle;


assign writeready = (((state == WAIT || state == READY) && offset != 10'd196) ? 1'b1 : 1'b0) | (broadcast & write);
assign writecircle = (broadcast&write) ? writedata : {6'h1,newdr[7:0],newdy[8:0],newdx[8:0]};

integer i = 0;

wire clksel;

assign clksel = (state == WAIT) ? clk : clkfast;

wire[DATAW-1:0] stackaddr = writedata[DATAW-1:0];

always@(posedge clk, posedge reset)
begin
    if(reset)
    begin
        state <= WAIT;
        newdx <= 0;
        newdr <= 0;
        newdy <= 0;
        basex <= 0;
        basey <= 0;
        baser <= 0;
        offset <= 10'd196;
        lstate <= 0;
        ready_sync <= 0;
    end
    else
    begin
        
        state <= _state;
        lstate <= state;
        offset <= _offset;

        ready_sync <= ready;

        if (writestart)
        begin
            basex <= stackaddr;
            basey <= stackaddr + 10'd200;
            baser <= stackaddr + 10'd400;
            offset <= 10'd196;
            state <= READX;
        end
        case (lstate)
            WAIT:
            begin
            end
            READX:
            begin
                newdx <= mreaddata;
            end
            READY:
            begin
                newdy <= mreaddata;
            end
            READR:
            begin
                newdr <= mreaddata;
            end
        endcase
    end
end


always@*
begin

    _mread = 0;
    _mwrite = 0;
    _mwritedata = 0;
    _maddress = 0;
    _state = state;
    _offset = offset;


    case (state)
        WAIT:
        begin
            _offset = 10'd196;
        end
        READX:
        begin
            _state = READY;
            _mread = 1'b1;
            _maddress = basex + offset;
            if (offset < 0)
            begin
                _state = WAIT;
            end

        end
        READY:
        begin
            _state = READR;
            _mread = 1'b1;
            _maddress = basey + offset;
        end
        READR:
        begin
            if (cselect != 0)
            begin
                _state = READX;
                _offset = offset - 4'd4;
            end
            else
            begin
                _state = BLOCK;
            end
            _mread = 1'b1;
            _maddress = baser + offset;
        end
        BLOCK:
        begin
            if (cselect != 0)
            begin
                _state = READX;
                _offset = offset - 4'd4;
            end
        end
    endcase
end

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

always@* 
begin
    cselect = 0;

    
    for(i=0; i < CIRCLES; i=i+1)
    begin
        if (ready_sync[i])
            cselect = 1 << i;
    end

    for(i=0; i < CIRCLES; i=i+1)
    begin
        writec[i] = 1'b0;
        writedatac[i] = 32'hx;
    end

    for(i=0; i < CIRCLES; i=i+1)
    begin

        if (cselect == (1<<i) || (broadcast && write))
        begin
            writec[i] = writeready;
            writedatac[i] = writecircle;
        end

    end
end


plot_pixel #(.ID(1),.WAITV(WAIT)) p0(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[0]),.waitrequest(),.ready(ready[0]),
    .readdatavalid(rdv[0]), .broadcast(broadcast & write),
    .write(writec[0]),.writedata(writedatac[0]));

plot_pixel #(.ID(2),.WAITV(WAIT)) p1(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[1]),.waitrequest(),.ready(ready[1]),
    .readdatavalid(rdv[1]), .broadcast(broadcast & write),
    .write(writec[1]),.writedata(writedatac[1]));

plot_pixel #(.ID(3),.WAITV(WAIT)) p2(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[2]),.waitrequest(),.ready(ready[2]),
    .readdatavalid(rdv[2]), .broadcast(broadcast & write),
    .write(writec[2]),.writedata(writedatac[2]));

plot_pixel #(.ID(4),.WAITV(WAIT)) p3(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[3]),.waitrequest(),.ready(ready[3]),
    .readdatavalid(rdv[3]), .broadcast(broadcast & write),
    .write(writec[3]),.writedata(writedatac[3]));

plot_pixel #(.ID(5),.WAITV(WAIT)) p4(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[4]),.waitrequest(),.ready(ready[4]),
    .readdatavalid(rdv[4]), .broadcast(broadcast & write),
    .write(writec[4]),.writedata(writedatac[4]));

plot_pixel #(.ID(6),.WAITV(WAIT)) p5(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[5]),.waitrequest(),.ready(ready[5]),
    .readdatavalid(rdv[5]), .broadcast(broadcast & write),
    .write(writec[5]),.writedata(writedatac[5]));

plot_pixel #(.ID(7),.WAITV(WAIT)) p6(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[6]),.waitrequest(),.ready(ready[6]),
    .readdatavalid(rdv[6]), .broadcast(broadcast & write),
    .write(writec[6]),.writedata(writedatac[6]));

plot_pixel #(.ID(8),.WAITV(WAIT)) p7(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[7]),.waitrequest(),.ready(ready[7]),
    .readdatavalid(rdv[7]), .broadcast(broadcast & write),
    .write(writec[7]),.writedata(writedatac[7]));

plot_pixel #(.ID(9),.WAITV(WAIT)) p8(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[8]),.waitrequest(),.ready(ready[8]),
    .readdatavalid(rdv[8]), .broadcast(broadcast & write),
    .write(writec[8]),.writedata(writedatac[8]));

plot_pixel #(.ID(10),.WAITV(WAIT)) p9(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[9]),.waitrequest(),.ready(ready[9]),
    .readdatavalid(rdv[9]), .broadcast(broadcast & write),
    .write(writec[9]),.writedata(writedatac[9]));

plot_pixel #(.ID(11),.WAITV(WAIT)) p10(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[10]),.waitrequest(),.ready(ready[10]),
    .readdatavalid(rdv[10]), .broadcast(broadcast & write),
    .write(writec[10]),.writedata(writedatac[10]));

plot_pixel #(.ID(12),.WAITV(WAIT)) p11(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[11]),.waitrequest(),.ready(ready[11]),
    .readdatavalid(rdv[11]), .broadcast(broadcast & write),
    .write(writec[11]),.writedata(writedatac[11]));

/*

plot_pixel #(.ID(13),.WAITV(WAIT)) p12(.clk(clksel),.reset(reset),.read(read),.address(address),
    .readdata(rd[12]),.waitrequest(),.ready(ready[12]),
    .readdatavalid(rdv[12]), .broadcast(broadcast & write),
    .write(writec[12]),.writedata(writedatac[12]));


*/
endmodule


module plot_pixel
#(
parameter DATAW=18,
parameter ID=1,
parameter WAITV=5'h0
)
(
    input clk,
    input reset,
    input broadcast,
    output ready,
    // mem mapped slave
        // read
        input read,
        input [DATAW-1:0]address ,
        output[7:0] readdata,
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
           READING=5'h7;

reg[8:0] rx,ry;
reg signed[9:0] x,y, _x,_y, tempx;
reg signed[10:0] xp,_xp;

reg[7:0] radius;
reg lread;
reg[4:0] state,_state, istate,_istate;
reg we_a, we_b;
wire[7:0] q_a, q_b;
reg[DATAW-4:0] addr_a, addr_b; 

assign waitrequest = 1'b0;
assign readdatavalid = (lread);
assign readdata = q_a;
wire tome, toall;
assign tome = ~broadcast;
assign toall = broadcast;

wire[8:0] xpx,xpy,xmx,xmy,_xpy,_xpx;

assign xpx = (rx + x[8:0]);
assign xpy = (rx + y[8:0]);
assign xmx = (rx - x[8:0]);
assign xmy = (rx - y[8:0]);

assign _xpx = (rx + _x[8:0]);
assign _xpy = (rx + _y[8:0]);

assign ready = (state == WAIT) ? 1'b1 : 1'b0;

reg[7:0] ramvala,ramvalb;

true_dual_port_ram_single_clock #( .DATA_WIDTH(8), .ADDR_WIDTH((DATAW-3)))
ram0 (.data_a(ramvala), .data_b(ramvalb), .addr_a(addr_a), .addr_b(addr_b),
.we_a(we_a), .we_b(we_b), .clk(clk),
.q_a(q_a), .q_b(q_b));

always@(posedge clk, posedge reset)
begin
    if (reset)
    begin
        rx <= 0;
        ry <= 0;
        y <= 0;
        x <= 0;
        state <= WAIT;
        istate <= WAIT;
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
            istate <= READING;
        end
        else
        begin
            istate <= _istate;
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
    ramvala = (write&(toall)) ? writedata[7:0] : 8'h0;
    ramvalb = (write&(toall)) ? writedata[7:0] : 8'h0;
    we_a = write&toall;
    we_b = write&toall;
    _istate = istate;

    addr_a = address[DATAW-4:0];
    addr_b = address[DATAW-4:0];

    case (state)
        WAIT:
        begin
        end
        COMPUTE:
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
            if(_x >= _y && radius != 0)
            begin
                addr_a = { (ry + _y[8:0] ), _xpx[8:3]};
                addr_b = { (ry + _x[8:0]), _xpy[8:3] };

                _state = WRITE0;
                _istate = WRITE0;
            end
            else 
            begin 
                _state = WAIT;
            end
        end
        WRITE0:
        begin
            addr_a = { (ry + y[8:0] ), xpx[8:3] };
            addr_b = { (ry + x[8:0] ), xpy[8:3] };

            if (istate == READING)
            begin
                _istate = state;
            end
            else
            begin
                {we_a,we_b} = 2'b11;
                ramvala = ( 1'b1 << xpx[2:0] ) | q_a;
                ramvalb = ( 1'b1 << xpy[2:0] ) | q_b;
                _state = WRITE1;
                _istate = READING;
            end
        end
        WRITE1:
        begin
            addr_a = { (ry - y[8:0] ), xpx[8:3] };
            addr_b = { (ry - x[8:0] ), xpy[8:3] };

            if (istate == READING)
            begin
                _istate = state;
            end
            else
            begin
                {we_a,we_b} = 2'b11;
                ramvala = ( 1'b1 << xpx[2:0] ) | q_a;
                ramvalb = ( 1'b1 << xpy[2:0] ) | q_b;
                _state = WRITE2;
                _istate = READING;
            end

        end
        WRITE2:
        begin

            addr_a = { (ry + y[8:0] ), xmx[8:3] };
            addr_b = { (ry + x[8:0] ), xmy[8:3] };

            if (istate == READING)
            begin
                _istate = state;
            end
            else
            begin
                {we_a,we_b} = 2'b11;
                ramvala = ( 1'b1 << xmx[2:0] ) | q_a;
                ramvalb = ( 1'b1 << xmy[2:0] ) | q_b;
                _state = WRITE3;
                _istate = READING;
            end

        end
        WRITE3:
        begin

            addr_a = { (ry - y[8:0] ), xmx[8:3] };
            addr_b = { (ry - x[8:0] ), xmy[8:3] };

            if (istate == READING)
            begin
                _istate = state;
            end
            else
            begin
                {we_a,we_b} = 2'b11;
                ramvala = ( 1'b1 << xmx[2:0] ) | q_a;
                ramvalb = ( 1'b1 << xmy[2:0] ) | q_b;
                _state = COMPUTE;
                _istate = READING;
            end

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
