`timescale 1ns / 1ps

module ALU_TB;
    reg  [3:0] A;
    reg  [3:0] B;
    reg  [2:0] ALU_Sel;
    wire [3:0] ALU_Out;
    wire       CarryOut;

    // Instantiate DUT
    ALU dut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .CarryOut(CarryOut)
    );

    // Task for cleaner printing
    task apply_and_display;
        input [3:0] a_in;
        input [3:0] b_in;
        input [2:0] sel_in;
        begin
            A       = a_in;
            B       = b_in;
            ALU_Sel = sel_in;
            #10; // wait for combinational propagation

            $display("Time=%0t  A=%b  B=%b  Sel=%b  ->  Out=%b  Carry=%b",
                     $time, A, B, ALU_Sel, ALU_Out, CarryOut);
        end
    endtask

    initial begin
        $display("----- ALU Simulation Started -----");

        // AND
        apply_and_display(4'b0001, 4'b0011, 3'b000);
        apply_and_display(4'b1010, 4'b1100, 3'b000);

        // OR
        apply_and_display(4'b0001, 4'b0011, 3'b001);
        apply_and_display(4'b1010, 4'b0101, 3'b001);

        // NOT A
        apply_and_display(4'b0000, 4'b0000, 3'b010);
        apply_and_display(4'b1111, 4'b0000, 3'b010);
        apply_and_display(4'b1010, 4'b0000, 3'b010);

        // ADD
        apply_and_display(4'b0001, 4'b0011, 3'b011); // 1 + 3 = 4
        apply_and_display(4'b1111, 4'b0001, 3'b011); // 15 + 1 = 0, carry

        // SUB
        apply_and_display(4'b0101, 4'b0011, 3'b100); // 5 - 3 = 2
        apply_and_display(4'b0011, 4'b0101, 3'b100); // 3 - 5, borrow

        // Default / invalid opcode
        apply_and_display(4'b1010, 4'b0101, 3'b111);

        $display("----- ALU Simulation Finished -----");
        $stop;
    end
endmodule
