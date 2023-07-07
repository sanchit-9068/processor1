`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Hoti to kya baat thi
// Engineer: Sanchit Awasthi
// 
// Create Date: 03.07.2023 03:35:28
// Design Name: 
// Module Name: processor_1_pipeline
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


module processor_1_pipeline(clk1, clk2);
    input clk1,clk2;
    reg[31:0] PC,IF_ID_NPC,ID_EX_NPC,EX_Mem_NPC,IF_ID_IR,ID_EX_IR,EX_Mem_IR,Mem_WB_IR,ID_EX_A,ID_EX_B,EX_Mem_B;
    reg[31:0] ID_EX_imm,EX_Mem_ALUout,Mem_WB_ALUout,Mem_WB_LMD;
    reg EX_Mem_cond;
    reg branch_taken, halted;
    
    reg[2:0] ID_EX_type,EX_Mem_type,Mem_WB_type;
    
    reg[31:0] Reg[0:31];
    reg[31:0] Mem[0:1023];
    
    //defining the instructions
    parameter ADD = 6'b000000, SUB = 6'b000001, AND = 6'b000010, OR = 6'b000011, SLT = 6'b000100, MUL = 6'b000101, HLT = 6'b000110;
    parameter LW = 6'b001000, SW = 6'b001001, ADDI = 6'b001010, SUBI = 6'b001011, SLTI = 6'b001100, BNEQZ = 6'b001101, BEQZ = 6'b001110;
    
    //defining the type of alu present.
    parameter RR_ALU = 3'b000, RM_ALU = 3'b001, Load = 3'b010, Store = 3'b011, Branch = 3'b100, Halt = 3'b101;
    
    
    //Stage 1--> IF
    always @(posedge clk1)
        begin
            if(halted == 0)
                begin
                    if(((EX_Mem_IR[31:26] == BEQZ)&(EX_Mem_cond == 1))|((EX_Mem_IR[31:26] == BNEQZ)&(EX_Mem_cond == 0)))
                        begin
                            branch_taken <= #2 1'b1;
                            IF_ID_NPC <= #2 1 + EX_Mem_ALUout;
                            IF_ID_IR <= #2 Mem[EX_Mem_ALUout];
                            PC <= #2 EX_Mem_ALUout+1;
                        end
                    else
                        begin
                            PC <= #2 PC+1;
                            IF_ID_NPC <= #2 PC+1;
                            IF_ID_IR <= #2 Mem[PC]; 
                        end                    
                end 
        end
        
        
    
    //Stage 2--> Instruction decoding
    always @(posedge clk2)
        begin
            if(halted == 0)
                begin
                    if(IF_ID_IR[25:21] == 5'b00000)
                        ID_EX_A <= 0;
                    else                    
                        ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];
                    if(IF_ID_IR[20:16] == 5'b00000)
                        ID_EX_B <=0;
                    else                    
                        ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];
                    ID_EX_IR <= #2 IF_ID_IR;
                    
                    ID_EX_NPC <= #2 IF_ID_NPC;
                    ID_EX_imm <= #2 {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};
                    
                    case(IF_ID_IR[31:26])
                        ADD,SUB,AND,OR,SLT,MUL: ID_EX_type <= #2 RR_ALU;
                        ADDI,SUBI,SLTI:         ID_EX_type <= #2 RM_ALU;
                        LW:                     ID_EX_type <= #2 Load;
                        SW:                     ID_EX_type <= #2 Store;
                        BEQZ,BNEQZ:             ID_EX_type <= #2 Branch;
                        HLT:                    ID_EX_type <= #2 Halt;
                        default:                ID_EX_type <= #2 Halt;
                    endcase
                end 
        end    
    
    
    //Stage 3--> Exection of instruction
    always @(posedge clk1)
        begin  
            if(halted==0)
                begin 
                    branch_taken <= #2 1'b0;
                    EX_Mem_NPC <= #2 ID_EX_NPC;
                    EX_Mem_IR <= #2 ID_EX_IR;
                    EX_Mem_type <= #2 ID_EX_type; 
                    case(ID_EX_type)
                        RR_ALU:
                            begin
                                case(ID_EX_IR[31:26])
                                    ADD:    EX_Mem_ALUout <= #2 ID_EX_A + ID_EX_B;
                                    SUB:    EX_Mem_ALUout <= #2 ID_EX_A - ID_EX_B;
                                    AND:    EX_Mem_ALUout <= #2 ID_EX_A & ID_EX_B;
                                    OR:     EX_Mem_ALUout <= #2 ID_EX_A | ID_EX_B;
                                    SLT:    EX_Mem_ALUout <= #2 ID_EX_A < ID_EX_B;
                                    MUL:    EX_Mem_ALUout <= #2 ID_EX_A * ID_EX_B;
                                    default:EX_Mem_ALUout <= #2 32'hxxxxxxxx;
                                endcase 
                            end
                        RM_ALU:
                            begin
                                case(ID_EX_IR[31:26])
                                    ADDI:   EX_Mem_ALUout <= #2 ID_EX_A + ID_EX_imm;
                                    SUBI:   EX_Mem_ALUout <= #2 ID_EX_A - ID_EX_imm;
                                    SLTI:   EX_Mem_ALUout <= #2 ID_EX_A < ID_EX_imm;
                                    default:EX_Mem_ALUout <= #2 32'hxxxxxxxx;
                                endcase                         
                            end
                        Load, Store: 
                            begin
                                EX_Mem_ALUout <= #2 ID_EX_A + ID_EX_imm;
                                EX_Mem_B <= #2 ID_EX_B; 
                            end                         
                        Branch:
                            begin
                                EX_Mem_ALUout <= #2 ID_EX_NPC + ID_EX_imm;
                                EX_Mem_cond <= #2 (ID_EX_A == 0);
                            end                       
                    endcase
                end
        end
    
    //Stage 4--> Memory Stage
    always @(posedge clk2)
        begin
            if(halted==0)
                begin
                    Mem_WB_IR <= #2 EX_Mem_IR;
                    Mem_WB_ALUout <= #2 EX_Mem_ALUout;
                    Mem_WB_type <= #2 EX_Mem_type;
                    case(EX_Mem_type)
                        Load: Mem_WB_LMD <= #2 Mem[EX_Mem_ALUout];
                        Store:
                            begin
                                if(branch_taken == 0)
                                    Mem[EX_Mem_ALUout] <= #2 EX_Mem_B;
                            end 
                        RR_ALU, RM_ALU: Mem_WB_ALUout <= #2 EX_Mem_ALUout; 
                                                    
                            
                    endcase
            end
        end
     
    //Stage 5--> Writing Back to the register 
    always @(posedge clk1)
        begin
            if(branch_taken == 0)
                begin
                    case(Mem_WB_type)
                        RR_ALU: Reg[Mem_WB_IR[15:11]] <= #2 Mem_WB_ALUout;
                        RM_ALU: Reg[Mem_WB_IR[20:16]] <= #2 Mem_WB_ALUout;
                        Load:   Reg[Mem_WB_IR[20:16]] <= #2 Mem_WB_LMD;
                        Halt:   halted <= #2 1'b1;
                    endcase
                end
        end
        
endmodule
