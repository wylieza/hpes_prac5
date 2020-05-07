`timescale 1ns / 1ps

module fullsine_256_tb;


//Testing registers and 'probes'
reg CLK100MHZ = 1'b0;
reg [7:0] sample_num = 8'b0;
wire [10:0] value;

//UUT - 'Fullsine from quatersine module'
fullsine_256 fs_samples(
    CLK100MHZ,
    sample_num,
    value
);

//TESTING PROBES
wire [5:0] addr;
wire reverse;
wire invert;
wire [10:0] dout;

assign addr = fs_samples.addra;
assign reverse = fs_samples.reverse;
assign invert = fs_samples.invert;
assign dout = fs_samples.douta;

//Counter for runnig the clock
reg [31:0] i;

initial
begin
    for(i = 0; i < 4096; i = i+1)
    begin
        #1 CLK100MHZ = ~CLK100MHZ;    
    end

    $finish;
end

//Read from the memory
always @(posedge CLK100MHZ) begin

    if((i+1)%5 == 0)
        sample_num = sample_num + 1;

end

endmodule
