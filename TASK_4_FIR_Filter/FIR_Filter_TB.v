`timescale 1ns / 1ps

module FIR_Filter_TB;

    reg        clk = 0, rst_n = 0, data_valid = 0;
    reg  signed [7:0] x_in;
    wire signed [15:0] y_out;
    wire        valid_out;
    
    // DUT
    FIR_Filter dut (.clk(clk), .rst_n(rst_n), .data_valid(data_valid),
                    .x_in(x_in), .y_out(y_out), .valid_out(valid_out));
    
    // Clock generation
    always #5 clk = ~clk;  // 100MHz
    
    // Test stimulus: 1kHz sine wave sampled at 100MHz (oversampled)
    reg [15:0] sine_lut [0:999];
    integer phase = 0;
    
    initial begin
        // Initialize sine lookup table (quantized to 8-bit)
        generate_sine();
        
        // Reset sequence
        #20 rst_n = 1;
        #20 data_valid = 1;
        
        // Stream 1000 samples
        repeat(1000) begin
            @(posedge clk);
            x_in = sine_lut[phase];
            phase = (phase + 1) % 1000;
        end
        
        #100;
        $display("Test completed. Check waveforms.");
        $finish;
    end
    
    // Generate 1kHz sine @ 100MHz (LUT method)
    task generate_sine;
        integer i;
        real angle;
        begin
            for (i = 0; i < 1000; i = i + 1) begin
                angle = 2.0 * 3.14159 * i / 1000.0;
                sine_lut[i] = $rtoi(127.0 * $sin(angle));  // 8-bit signed sine
            end
        end
    endtask
    
endmodule
