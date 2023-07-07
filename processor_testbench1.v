`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2023 03:32:37
// Design Name: 
// Module Name: processor_testbench1
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


module processor_testbench1();
    
    
    reg clk1,clk2;  integer k;
    processor_1_pipeline pipe(clk1,clk2);
    
    initial 
        begin
             clk1 = 0; clk2 = 0;
             repeat(20)
                begin
                    #5 clk1 = 1; #5 clk1 = 0;
                    #5 clk2 = 1; #5 clk2 = 0;
                end
        end

    initial
        begin
            for(k = 0; k < 31;k=k+1)
                pipe.Reg[k] = k;
            pipe.Mem[0] = 32'h2801000a;
            pipe.Mem[1] = 32'h28020014;
            pipe.Mem[2] = 32'h2803001e;
            pipe.Mem[3] = 32'h0ce77800;
            pipe.Mem[4] = 32'h0ce77800;
            pipe.Mem[5] = 32'h00222000;
            pipe.Mem[6] = 32'h0ce77800;
            pipe.Mem[7] = 32'h00832800;
            pipe.Mem[8] = 32'hfc000000;
            
            pipe.branch_taken = 0;
            pipe.halted = 0;
            pipe.PC = 0;
            
            #280
            for(k=0;k<6;k=k+1)
                $display("R%1d - %2d",k,pipe.Reg[k]);
            
        end
        
    
    initial
        begin
            #300 $finish;
        end    
endmodule
