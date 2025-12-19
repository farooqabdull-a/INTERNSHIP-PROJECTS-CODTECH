`timescale 1ns / 1ps
module ALU(
    input   [3:0] A,
    input   [3:0] B,
    input   [2:0] ALU_Sel,
    output reg  [3:0] ALU_Out,
    output reg        CarryOut
);
    wire [4:0] sum;    // For ADD
    wire [4:0] diff;   // For SUB

    assign sum  = {1'b0, A} + {1'b0, B};      // 5-bit to capture carry
    assign diff = {1'b0, A} - {1'b0, B};      // 5-bit to capture borrow/carry

    always @(*) begin
        CarryOut = 1'b0;
        case (ALU_Sel)
            3'b000: begin                 // AND
                ALU_Out  = A & B;
            end
            3'b001: begin                 // OR
                ALU_Out  = A | B;
            end
            3'b010: begin                 // NOT A
                ALU_Out  = ~A;
            end
            3'b011: begin                 // ADD
                ALU_Out  = sum[3:0];
                CarryOut = sum[4];
            end
            3'b100: begin                 // SUB (A - B)
                ALU_Out  = diff[3:0];
                CarryOut = diff[4];       // Treat MSB as borrow/carry info
            end
            default: begin
                ALU_Out  = 4'b0000;
                CarryOut = 1'b0;
            end
        endcase
    end
endmodule
