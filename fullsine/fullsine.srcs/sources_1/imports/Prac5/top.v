//`timescale 1ns / 1ps

module top(
    // These signal names are for the nexys A7. 
    // Check your constraint file to get the right names
    input  CLK100MHZ,
    input [7:0] SW,
    output AUD_PWM, 
    output AUD_SD,
    output [2:0] LED
    );
    
    // Toggle arpeggiator enabled/disabled
    //wire arp_switch;
    //Debounce change_state (CLK100MHZ, BTNL, arp_switch); // ensure your button choice is correct
    
    // Memory IO
    reg ena = 1;
    reg wea = 0;
    reg [7:0] addra=0;
    reg [10:0] dina=0; //We're not putting data in, so we can leave this unassigned
    wire [10:0] douta;
    
    
    // Instantiate block memory here
    // Copy from the instantiation template and change signal names to the ones under "MemoryIO"
    //Could not find this template....
    fullsine_samples fs_mem(
        CLK100MHZ,
        ena,
        wea,
        addra,
        dina,
        douta
    );
    
    
//    clka : IN STD_LOGIC;
//    ena : IN STD_LOGIC;
//    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
//    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
//    dina : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
//    douta : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)

    
    //PWM Out - this gets tied to the BRAM
    reg [10:0] PWM;
    
    // Instantiate the PWM module
    // PWM should take in the clock, the data from memory
    // PWM should output to AUD_PWM (or whatever the constraints file uses for the audio out.
    pwm_module pwm_audio(
        CLK100MHZ,
        PWM,
        AUD_PWM
    );

    
    // Divide our clock down
    reg [12:0] clkdiv = 0;
    
    // keep track of variables for implementation
    reg [26:0] note_switch = 0;
    reg [1:0] note = 0;
    reg [8:0] f_base = 0;
    
    //Count cap that determines frequency
    //reg [10:0] num_ticks = 11'd1493; //For 261Hz
    
    reg [10:0] num_ticks = 390625*0.002;
    
always @(posedge CLK100MHZ) begin   
    PWM <= douta; // tie memory output to the PWM input
    
    //Output 261.625564Hz
    if(&(~(clkdiv - num_ticks))) begin
        addra = addra + 1;
        clkdiv = 0;
    end
    else begin
        clkdiv = clkdiv + 1;
    
    end
    
    
    f_base[8:0] = 746 + SW[7:0]; // get the "base" frequency to work from 
    
    // Loop to change the output note IF we're in the arp state
    

    // FSM to switch between notes, otherwise just output the base note.
    
end


assign AUD_SD = 1'b1;  // Enable audio out
//assign LED[1:0] = note[1:0]; // Tie FRM state to LEDs so we can see and hear changes
assign LED[1:0] = addra[1:0]; // Tie FRM state to LEDs so we can see and hear changes


endmodule
