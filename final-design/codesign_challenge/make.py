


for i in range(0,12):
    s = """
plot_pixel #(.ID(%d),.WAITV(WAIT)) p%d(.clk(clksel),.reset(reset),.read(readcircle),.address(address),
    .readdata(rd[%d]),.waitrequest(),.ready(ready[%d]),
    .readdatavalid(rdv[%d]), .broadcast(broadcast & write),
    .write(writec[%d]),.writedata(writedatac[%d]));""" % (i+1,i,i,i,i,i,i)
    print (s)

for i in range(0,50):
    print ('SET_RADIUS(dx[%d],dy[%d],dr[%d]); \t// %d' % (i,i,i,i ))
