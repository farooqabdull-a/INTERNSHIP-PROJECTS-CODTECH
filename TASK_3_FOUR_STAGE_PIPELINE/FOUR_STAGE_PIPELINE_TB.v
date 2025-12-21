`timescale 1ns / 1ps

module FOUR_STAGE_PIPELINE_TB;
    reg clk;
    reg reset;

    // Instantiate the Processor
    FOUR_STAGE_PIPELINE uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    initial begin
        // --- Initialize Signals ---
        clk = 0;
        reset = 1;
        #15 reset = 0; // Release reset after 1.5 clock cycles

        // --- Load Instruction Memory (Program) ---
        // Format: Opcode(4)_Dest(3)_Src1(3)_Src2(3)_Imm(3)
        // Op codes: ADD=0001, SUB=0010, AND=0011, LOAD=0100
        
        // 1. ADD R1, R2, R3 -> R1 = R2 + R3
        uut.instr_mem[0] = 16'b0001_001_010_011_000; 
        
        // 2. SUB R4, R5, R6 -> R4 = R5 - R6
        uut.instr_mem[1] = 16'b0010_100_101_110_000; 
        
        // 3. AND R7, R1, R4 -> R7 = R1 & R4
        uut.instr_mem[2] = 16'b0011_111_001_100_000; 
        
        // 4. LOAD R2, R3, 5 -> R2 = Mem[R3 + 5]
        uut.instr_mem[3] = 16'b0100_010_011_000_101; 

        // --- Pre-set Register File Values ---
        uut.regfile[2] = 8'd10; // R2 = 10
        uut.regfile[3] = 8'd20; // R3 = 20
        uut.regfile[5] = 8'd50; // R5 = 50
        uut.regfile[6] = 8'd15; // R6 = 15

        // --- Pre-set Data Memory (for LOAD test) ---
        // LOAD instruction uses R3(20) + Imm(5) = 25
        uut.data_mem[9] = 8'hA5; // Set memory at index 25 to 0xA5

        // --- Monitor Simulation ---
        $display("Time\t PC\t Stage\t Instruction");
        $monitor("%0t\t %d\t %b\t %b", $time, uut.pc, uut.IF_ID_instr, uut.EX_WB_result);

        // Run for 100ns to see all stages complete
        #100;
        
        // Display Final Register State
        $display("\n--- Final Register States ---");
        $display("R1 (ADD Result): %d", uut.regfile[1]);
        $display("R4 (SUB Result): %d", uut.regfile[4]);
        $display("R7 (AND Result): %d", uut.regfile[7]);
        $display("R2 (LOAD Result): %h", uut.regfile[2]);
        
        $finish;
    end
endmodule

