`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2023 05:14:02
// Design Name: 
// Module Name: processor_3_tb
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


module processor_3_tb();
 reg clk1,clk2;integer k;
    
    processor_1_pipeline pipe(clk1,clk2);
    
    initial
        begin
            clk1 = 0; clk2 = 0;
            repeat(50)
                begin
                    #5 clk1 = 1; #5 clk1 = 0;
                    #5 clk2 = 1; #5 clk2 = 0;
                end 
        end
    

    initial
        begin
            for(k = 0;k<31;k=k+1)
                pipe.Reg[k] = k;
            
            pipe.Mem[0] = 32'h280a00c8;
            pipe.Mem[1] = 32'h28020001;
            pipe.Mem[2] = 32'h0e94a000;
            pipe.Mem[3] = 32'h21430000;
            pipe.Mem[4] = 32'h0e94a000;
            pipe.Mem[5] = 32'h14431000;
            pipe.Mem[6] = 32'h2c630001;
            pipe.Mem[7] = 32'h0e94a000;
            pipe.Mem[8] = 32'h3460fffc;
            pipe.Mem[9] = 32'h2542fffe;
            pipe.Mem[10] = 32'hdc000000;
            
            
            
            pipe.Mem[200] = 7;
            pipe.PC = 0;
            pipe.branch_taken = 0;
            pipe.halted = 0;
            
            #2000
//            for(k = 0;k<10;k=k+1)
//                $display("R%1d = %2d",k,pipe.Reg[k]);
            $display("Mem[200]: %4d \nMem[198]: %6d",pipe.Mem[200],pipe.Mem[198]);            
                        
        end
    
    initial
    begin
        $monitor("R2: %4d",pipe.Reg[2]);
        #3000 $finish;
        end        
endmodule
