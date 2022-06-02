`include "para.v"
module write_back_extender (
    input [`instr_width] instruction,
    input [`width] unprocess_data,
    output reg [`width] res_data
);
    ///////////////////////haha///////////////////////
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];

    wire rw_type= opcode == `rw_type_opcode;
    wire iw_type= opcode == `iw_type_opcode;
    wire l_type = (~opcode[6]&~opcode[5]&~opcode[4]&~opcode[3]&~opcode[2]& opcode[1]& opcode[0]);
    wire word_op = rw_type||iw_type;

    always @(*) begin
        if(l_type)begin
            case (funct3)
                `lb: 
                    res_data = {{57{unprocess_data[7]}},unprocess_data[6:0]};
                `lh:
                    res_data = {{49{unprocess_data[15]}} ,unprocess_data[14:0]};
                `lhu:
                    res_data = {48'b0,unprocess_data[15:0]};
                `lw: 
                    res_data = {{33{unprocess_data[31]}},unprocess_data[30:0]};
                `lbu:
                    res_data = {56'b0,unprocess_data[7:0]};
                `ld:
                    res_data=unprocess_data;
                default: res_data =unprocess_data;
            endcase        
        end else if (word_op) begin
            res_data = {{33{unprocess_data[31]}},unprocess_data[30:0]};
        end else
            res_data =unprocess_data;
    end
endmodule