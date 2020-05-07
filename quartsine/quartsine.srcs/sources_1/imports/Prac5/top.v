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
    
    reg [7:0] sample_num;
    wire [10:0] sample_value;
    
    //Create module of the fullsine_256
    fullsine_256 fs_samples(
        CLK100MHZ,
        sample_num,
        sample_value
    );
    
   
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

    
    //Clock division reg's for sample playback
    reg [14:0] sample_increment_counter = 0; //15 bits give us down to 20Hz
    reg [14:0] sample_increment_cap = 390625*0.001; //390625*(1/f)
    //reg [14:0] freq_constants []
    
    //Clock division reg's for note switch period (500ms)
    reg [26:0] note_switch_counter;
    reg [26:0] note_switch_cap = 26'd50000000;
    
    // keep track of variables for implementation
    reg [26:0] note_switch = 0;
    reg [1:0] note = 0;
    reg [8:0] f_base = 0;
    
    //Count cap that determines frequency
    //reg [10:0] num_ticks = 11'd1493; //For 261Hz
    
    
    reg [10:0] num_ticks = 390625*0.001;
    
always @(posedge CLK100MHZ) begin   
    PWM <= sample_value; // tie memory output to the PWM input
    
    //Code to playback samples at specified frequency
    sample_increment_counter <= sample_increment_counter + 1; //If you think to yourself, the increment should be after the next bit of code... think again, this is not coding!
    if (sample_increment_counter >= sample_increment_cap) begin
        sample_num = sample_num + 1;
        sample_increment_counter <= 0;
    end
    
    //Code to change note
    note_switch_counter <= note_switch_counter + 1;
    if (~|(note_switch_counter - note_switch_cap)) begin
        note_switch_counter <= 19'b0;
        note <= note + 1;   
    end
    
    /*
    //Output 261.625564Hz (Middle C)
    if(&(~(clkdiv - num_ticks))) begin
        sample_num = sample_num + 1;
        clkdiv = 0;
    end
    else begin
        clkdiv = clkdiv + 1;
    
    end
    */
    
    
    f_base[8:0] <= 746 + SW[7:0]; // get the "base" frequency to work from
    //sample_increment_cap <= 390625*(1/f_base); //If only it was this simple ey :/
    case(note)
        0: sample_increment_cap <= f_base*2;
        1: sample_increment_cap <= f_base*3/2;
        2: sample_increment_cap <= f_base*5/4;
        3: sample_increment_cap <= f_base;
        default: sample_increment_cap <= 11'd1493; //For 261Hz
    endcase;
    
    
    
    
    // Loop to change the output note IF we're in the arp state  

    // FSM to switch between notes, otherwise just output the base note.
    
end


assign AUD_SD = 1'b1;  // Enable audio out
assign LED[1:0] = note[1:0]; // Tie FRM state to LEDs so we can see and hear changes
//assign LED[1:0] = sample_num[1:0]; // Tie FRM state to LEDs so we can see and hear changes


endmodule
