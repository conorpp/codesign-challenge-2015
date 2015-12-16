


for i in range(0,50):
    s = """
plot_pixel #(.ID(%d)) p%d(.clk(clk),.reset(reset),.read(read),.address(address),
    .readdata(rd[%d]),.waitrequest(),
    .readdatavalid(rdv[%d]),
    .write(write),.writedata(writedata));""" % (i+1,i,i,i)
    print (s)

