module plot_circle
(
    input clk,
    input reset,

    // custom instruction (ended up not being used!)
    input start,
    input[31:0] A,
    input[31:0] B,

    output[31:0] result,
    output done,

    // mem mapped slave
        // read
        input read,
        input [17:0]address ,
        output[31:0] readdata,
        output waitrequest,
        output readdatavalid,
        // write
        input write,
        input[31:0] writedata
);
reg[511:0] pixmem [511:0];
reg[511:0] _pixmem [511:0];
//wire[511:0] _pixword;

wire[8:0] addrx = address[8:0];
wire[8:0] addry = address[17:9];

wire[9:0] y = A[9:0];
wire[9:0] x = A[19:10];
wire[9:0] cy = A[29:20];
wire[9:0] cx = {B[7:0],A[31:30]};

reg[8:0] sum_cx_x;
reg[8:0] sum_cy_y;
reg[8:0] diff_cy_y;
reg[8:0] diff_cx_x;

reg[8:0] sum_cx_y;
reg[8:0] sum_cy_x;
reg[8:0] diff_cy_x;
reg[8:0] diff_cx_y;

reg writebit;

// mem mapped read
assign waitrequest = 1'b0;
assign readdata = (read) ? ({31'h0, pixmem[addrx][addry]}) : (32'h0);



assign readdatavalid = read ? 1'b1 : 1'b0;
integer i = 0;
assign done = 1'b1;

// internal memory
always@(posedge clk, posedge reset)
begin
    if (reset)
    begin
        for(i=0; i<512; i=i+1)
        begin
            pixmem[i] <= 512'h0;
        end
    end
    else
    begin
        for(i=0; i<512; i=i+1)
        begin
            pixmem[i] <=  _pixmem[i];
        end

    end
end

// custom instruction
always@*
begin
    done = 1'b0;
    for(i=0; i<512; i=i+1)
    begin
        _pixmem[i] = pixmem[i];
    end




    // todo complete
    if (write) 
    begin
        sum_cx_x = addrx;
        sum_cx_y = addrx;
        diff_cx_x = addrx;
        diff_cx_y = addrx;

        sum_cy_y = addry;
        sum_cy_x = addry;
        diff_cy_y = addry;
        diff_cy_x = addry;

        writebit = writedata[0];
    end
    else
    begin
        sum_cx_x = cx[8:0] + x[8:0];
        sum_cy_y = cy[8:0] + y[8:0];
        diff_cy_y = cy[8:0] - y[8:0];
        diff_cx_x = cx[8:0] - x[8:0];

        sum_cx_y = cx[8:0] + y[8:0];
        sum_cy_x = cy[8:0] + x[8:0];
        diff_cy_x = cy[8:0] - x[8:0];
        diff_cx_y = cx[8:0] - y[8:0];
        writebit = 1'b1;
    end

    // Note this is incorrect because it's describing an 8 port memory.
    // This is tough to synthesis.  I changed this later on to a 2 port memory
    // which is an Altera built in memory and will synthesis easily.
    if (start)
    begin
        _pixmem[sum_cx_x][sum_cy_y] = writebit;
        _pixmem[sum_cx_x][diff_cy_y] = writebit;
        _pixmem[diff_cx_x][sum_cy_y] = writebit;
        _pixmem[diff_cx_x][diff_cy_y] = writebit;
        _pixmem[sum_cx_y][sum_cy_x] = writebit;
        _pixmem[sum_cx_y][diff_cy_x] = writebit;
        _pixmem[diff_cx_y][sum_cy_x] = writebit;
        _pixmem[diff_cx_y][diff_cy_x] = writebit;
    end
    else
    begin

    end
    done = 1'b1;

end



endmodule
