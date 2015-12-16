module plot_circle
(
    input clk,
    input reset,

    // custom instruction
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

wire[9:0] y = A[9:0];
wire[9:0] x = A[19:10];
wire[9:0] cy = A[29:20];
wire[9:0] cx = {B[7:0],A[31:30]};

wire[8:0] sum_cx_x = cx[8:0] + x[8:0];
wire[8:0] sum_cy_y = cy[8:0] + y[8:0];
wire[8:0] diff_cy_y = cy[8:0] - y[8:0];
wire[8:0] diff_cx_x = cx[8:0] - x[8:0];

wire[8:0] sum_cx_y = cx[8:0] + y[8:0];
wire[8:0] sum_cy_x = cy[8:0] + x[8:0];
wire[8:0] diff_cy_x = cy[8:0] - x[8:0];
wire[8:0] diff_cx_y = cx[8:0] - y[8:0];

// mem mapped read
assign waitrequest = 1'b0;
assign readdata = (read) ? ({31'h0, pixmem[address[8:0]][address[17:9]]}) : (32'h0);
assign readdata = 32'h0;

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
            pixmem[i] <= _pixmem[i];
        end
        if (write)
            pixmem[address[8:0]][address[17:9]] <= writedata[0];

    end
end

// custom instruction
always@*
begin
//    _pixmem = pixmem;
    done = 1'b0;
    for(i=0; i<512; i=i+1)
    begin
        _pixmem[i] = pixmem[i];
    end

    if (start)
    begin
        _pixmem[sum_cx_x][sum_cy_y] = 1'b1;
        _pixmem[sum_cx_x][diff_cy_y] = 1'b1;
        _pixmem[diff_cx_x][sum_cy_y] = 1'b1;
        _pixmem[diff_cx_x][diff_cy_y] = 1'b1;
        _pixmem[sum_cx_y][sum_cy_x] = 1'b1;
        _pixmem[sum_cx_y][diff_cy_x] = 1'b1;
        _pixmem[diff_cx_y][sum_cy_x] = 1'b1;
        _pixmem[diff_cx_y][diff_cy_x] = 1'b1;
    end
    else
    begin

    end
    done = 1'b1;

end


// unnecessary
assign result = A+B;



endmodule
