`timescale 1ns/1ps

module FIR_Filter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        data_valid,
    input  wire signed [7:0]  x_in,      // 8-bit signed input
    output reg  signed [15:0] y_out,     // 16-bit signed output
    output reg         valid_out
);

    // Coefficients (8-tap symmetric lowpass)
    reg signed [15:0] h [0:7];
    initial begin
        h[0] = 16'h0008;  // 0.05 * 2^11
        h[1] = 16'h0019;  // 0.1  * 2^11
        h[2] = 16'h0033;  // 0.2  * 2^11
        h[3] = 16'h0041;  // 0.25 * 2^11
        h[4] = 16'h0041;  // 0.25 * 2^11
        h[5] = 16'h0033;  // 0.2  * 2^11
        h[6] = 16'h0019;  // 0.1  * 2^11
        h[7] = 16'h0008;  // 0.05 * 2^11
    end

    // Shift register for input samples (8 taps)
    reg signed [7:0] shift_reg [0:7];
    
    // Pipeline registers for partial products
    reg signed [23:0] ppipe [0:7];  // 8-bit x 16-bit = 24-bit
    reg signed [24:0] sum1 [0:3];   // 4 partial sums
    reg signed [25:0] sum2 [0:1];   // 2 partial sums  
    reg signed [26:0] final_sum;    // Final accumulator

    integer i;
    
    // Stage 1: Input shift + Multiply
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                shift_reg[i] <= 8'h00;
                ppipe[i] <= 24'h000000;
            end
        end else if (data_valid) begin
            // Shift samples (oldest sample shifts out)
            shift_reg[0] <= shift_reg[1];
            shift_reg[1] <= shift_reg[2];
            shift_reg[2] <= shift_reg[3];
            shift_reg[3] <= shift_reg[4];
            shift_reg[4] <= shift_reg[5];
            shift_reg[5] <= shift_reg[6];
            shift_reg[6] <= shift_reg[7];
            shift_reg[7] <= x_in;
            
            // Compute partial products (h*x)
            for (i = 0; i < 8; i = i + 1)
                ppipe[i] <= shift_reg[i] * h[i];
        end
    end

    // Stage 2: First sum reduction (4 partial sums)
    always @(posedge clk) begin
        sum1[0] <= ppipe[0] + ppipe[1];
        sum1[1] <= ppipe[2] + ppipe[3];
        sum1[2] <= ppipe[4] + ppipe[5];
        sum1[3] <= ppipe[6] + ppipe[7];
    end

    // Stage 3: Second sum reduction (2 partial sums)
    always @(posedge clk) begin
        sum2[0] <= sum1[0] + sum1[1];
        sum2[1] <= sum1[2] + sum1[3];
    end

    // Stage 4: Final accumulation + Scaling + Output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            final_sum  <= 27'h0000000;
            y_out      <= 16'h0000;
            valid_out  <= 1'b0;
        end else begin
            final_sum <= sum2[0] + sum2[1];  // 25+25=26 bits
            y_out     <= (sum2[0] + sum2[1]) >>> 11;  // Scale back (divide by 2^11)
            valid_out <= data_valid;
        end
    end

endmodule

