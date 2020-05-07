`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.05.2020 11:03:18
// Design Name: 
// Module Name: fullsine_256
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fullsine_256(
    input CLK100MHZ,
    input [7:0] sample_num,
    output reg [10:0] value
    );
    
    // Memory IO
    reg ena = 1;
    reg wea = 0;
    reg [5:0] addra = 0;
    reg [10:0] dina=0; //We're not putting data in, so we can leave this unassigned
    wire [10:0] douta;
    
    //    clka : IN STD_LOGIC;
    //    ena : IN STD_LOGIC;
    //    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    //    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    //    dina : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    //    douta : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
    
    
    
    // Instantiate block memory here
    // Copy from the instantiation template and change signal names to the ones under "MemoryIO"
    //Could not find this template....
    quartsine_mem qs_mem(
        CLK100MHZ,
        ena,
        wea,
        addra,
        dina,
        douta
    );
    
    reg reverse;
    reg invert;
    
    always @(posedge CLK100MHZ) begin
    
        //Determine the states of 'reverse' and 'invert' flags
        if (&sample_num[7:6]) begin
            //Code here to deal with 192-255
            reverse = 1;
            invert = 1;
        
        end else if (&sample_num[7:7]) begin
            //Code here to deal with 128-191
            reverse = 0;
            invert = 1;
        
        end else if (&sample_num[6:6]) begin
            //Code here to deal with 64-127
            reverse = 1;
            invert = 0;
        
        end else begin
            //Code here to deal with 0-63
            reverse = 0;
            invert = 0;        
        end
        
        
        //Calculating the next value -> Perforom reverse addressing if required
        if (reverse)
            addra = 6'd63 - sample_num[5:0];
        else
            addra = sample_num[5:0];   
        
        //Calculating the next value -> Invert [around 1024] if required
        if(invert)
            value <= 11'd2048 - douta;
        else
            value <= douta;
            
    end    

endmodule
