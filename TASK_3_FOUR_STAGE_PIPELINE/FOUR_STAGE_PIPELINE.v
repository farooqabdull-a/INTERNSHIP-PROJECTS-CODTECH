`timescale 1ns/1ps

module ALU (
    input [7:0] A,          // Operand A
    input [7:0] B,          // Operand B
    input [3:0] opcode,     // Operation selector
    output reg [7:0] result); // Result of operation

    always @(*) begin
        case (opcode)
            4'b0001: result = A + B;   // ADD
            4'b0010: result = A - B;   // SUB
            4'b0011: result = A & B;   // AND
            default: result = 8'h00;   // Default / NOP
        endcase
    end
endmodule

module FOUR_STAGE_PIPELINE(
    input clk,
    input reset);
    
    // Storage: Instruction Memory, Data Memory, and Register File
    reg [15:0] instr_mem [0:15]; 
    reg [7:0]  data_mem  [0:15]; 
    reg [7:0]  regfile   [0:7];  

    // Pipeline Registers (Latches)
    reg [15:0] IF_ID_instr;
    reg [3:0]  ID_EX_op, ID_EX_rd;
    reg [7:0]  ID_EX_A, ID_EX_B, ID_EX_imm;
    reg [7:0]  EX_WB_result;
    reg [3:0]  EX_WB_rd;
    reg [7:0]  pc;

    // ALU instantiation wires
    wire [7:0] alu_out;

    // --- STAGE 1: FETCH ---
    always @(posedge clk) begin
        if (reset) pc <= 0;
        else begin
            IF_ID_instr <= instr_mem[pc];
            pc <= pc + 1;
        end
    end

    // --- STAGE 2: DECODE ---
    always @(posedge clk) begin
        if (!reset) begin
            ID_EX_op  <= IF_ID_instr[15:12];
            ID_EX_rd  <= IF_ID_instr[11:9];
            ID_EX_A   <= regfile[IF_ID_instr[8:6]];
            ID_EX_B   <= regfile[IF_ID_instr[5:3]];
            ID_EX_imm <= {5'b0, IF_ID_instr[2:0]};
        end
    end

    // --- STAGE 3: EXECUTE (Instantiating ALU) ---
    // The ALU performs arithmetic/logic or calculates LOAD addresses
    ALU core_alu (
        .A(ID_EX_A), 
        .B(ID_EX_op == 4'b0100 ? ID_EX_imm : ID_EX_B), // Use imm for LOAD
        .opcode(ID_EX_op), 
        .result(alu_out));

    always @(posedge clk) begin
        if (!reset) begin
            EX_WB_rd <= ID_EX_rd;
            // Handle LOAD separately if data comes from memory
            if (ID_EX_op == 4'b0100) 
                EX_WB_result <= data_mem[alu_out[3:0]]; 
            else 
                EX_WB_result <= alu_out;
        end
    end

    // --- STAGE 4: WRITE-BACK ---
    always @(posedge clk) begin
        if (!reset && EX_WB_rd != 0) begin
            regfile[EX_WB_rd] <= EX_WB_result;
        end
    end
endmodule

