`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2023 04:57:16
// Design Name: 
// Module Name: processor_2_tb
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


module processor_2_tb( );
    reg clk1,clk2;integer k;
    
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
            for(k = 0;k<31;k=k+1)
                pipe.Reg[k] = k;
            
            pipe.Mem[0] = 32'h28010078;
            pipe.Mem[1] = 32'h0c631800;
            pipe.Mem[2] = 32'h20220000;
            pipe.Mem[3] = 32'h0c631800;
            pipe.Mem[4] = 32'h2842002d;
            pipe.Mem[5] = 32'h0c631800;
            pipe.Mem[6] = 32'h24220001;
            pipe.Mem[7] = 32'hfc000000;
            
            
            pipe.Mem[120] = 99;
            pipe.PC = 0;
            pipe.branch_taken = 0;
            pipe.halted = 0;
            
            #500
            for(k = 0;k<3;k=k+1)
                $display("R%1d = %2d",k,pipe.Reg[k]);
            $display("Mem[120]: %4d \nMem[121]: %4d",pipe.Mem[120],pipe.Mem[121]);            
                        
        end
    
    initial
        #600 $finish;        
endmodule
