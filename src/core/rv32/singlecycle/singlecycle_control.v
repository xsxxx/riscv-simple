///////////////////////////////////////////////////////////////////////////////
//                    RISC-V SiMPLE - Controle do Uniciclo                   //
//                                                                           //
//        Código fonte em https://github.com/arthurbeggs/riscv-simple        //
//                            BSD 3-Clause License                           //
///////////////////////////////////////////////////////////////////////////////

`ifndef CONFIG_AND_CONSTANTS
    `include "config.v"
`endif

module singlecycle_control (
    input  [6:0] inst_opcode,
    input  inst_bit_30,             // Identifica funções secundárias da ULA
`ifdef M_MODULE
    input  inst_bit_25,             // Identifica operações da extensão M
`endif

    output reg pc_write_enable,         // Habilita escrita de PC
    output reg regfile_write_enable,    // Habilita escrita no regfile
    output reg alu_operand_a_select,    // Seleciona a entrada A da ULA
    output reg alu_operand_b_select,    // Seleciona a entrada B da ULA
    output reg [2:0] alu_op_type,       // Seleciona a funcionalidade da ULA
    output reg jal_enable,              // JAL
    output reg jalr_enable,             // JALR
    output reg branch_enable,           // Branching
    output reg data_mem_read_enable,    // Habilita leitura da memória de dados
    output reg data_mem_write_enable,   // Habilita escrita na memória de dados
    output reg [2:0] reg_writeback_select   // Seleciona a entrada de escrita do regfile
);

// TODO: Implementar sinal de controle para nível privilegiado

// Tabela de tipo de operações da ULA (alu_op_type[2:0])
// 3'b000: Zero
// 3'b001: Add
// 3'b010: Função default
// 3'b011: Função secundária (SUB, SRA, ...)
// 3'b100: Branches (comparações)
// 3'b101: Extensão M

// Tabela de entradas do multiplexador de escrita em rd
// 3'b000: Saída da ULA
// 3'b001: Saída da memória de dados
// 3'b010: PC + 4
// 3'b011: Saída do gerador de imediatos
// Planejadas:
// 3'b100: Dado do registrador de ponto flutuante rs1
// 3'b101: Leitura dos CSR's

always @ (*) begin
    // Caso default
    pc_write_enable         = 1'b1;
    regfile_write_enable    = 1'b0;
    alu_operand_a_select    = 1'b0;
    alu_operand_b_select    = 1'b0;
    alu_op_type             = 3'b000;
    jal_enable              = 1'b0;
    jalr_enable             = 1'b0;
    branch_enable           = 1'b0;
    data_mem_read_enable    = 1'b0;
    data_mem_write_enable   = 1'b0;
    reg_writeback_select    = 3'b000;

    case (inst_opcode)
        `OPCODE_LOAD:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b1;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b1;
            alu_op_type             = 3'b001;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b001;
        end

        // // `OPCODE_LOAD_FP:
        // begin
        //     pc_write_enable         = 1'b1;
        //     regfile_write_enable    = 1'b0;
        //     alu_operand_a_select    = 1'b0;
        //     alu_operand_b_select    = 1'b0;
        //     alu_op_type             = 3'b000;
        //     jal_enable              = 1'b0;
        //     jalr_enable             = 1'b0;
        //     branch_enable           = 1'b0;
        //     data_mem_read_enable    = 1'b0;
        //     data_mem_write_enable   = 1'b0;
        //     reg_writeback_select    = 3'b000;
        // end

        `OPCODE_MISC_MEM:
        begin
            // Fence - Ignorado, mas não causa exceção
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b0;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b0;
            alu_op_type             = 3'b000;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b000;
        end

        `OPCODE_OP_IMM:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b1;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b1;
            alu_op_type             = 3'b010;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b000;
        end

        `OPCODE_AUIPC:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b1;
            alu_operand_a_select    = 1'b1;
            alu_operand_b_select    = 1'b1;
            alu_op_type             = 3'b001;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b000;
        end

        `OPCODE_STORE:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b0;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b1;
            alu_op_type             = 3'b001;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b1;
            reg_writeback_select    = 3'b000;
        end

        // // `OPCODE_STORE_FP:
        // begin
        //     pc_write_enable         = 1'b1;
        //     regfile_write_enable    = 1'b0;
        //     alu_operand_a_select    = 1'b0;
        //     alu_operand_b_select    = 1'b0;
        //     alu_op_type             = 3'b000;
        //     jal_enable              = 1'b0;
        //     jalr_enable             = 1'b0;
        //     branch_enable           = 1'b0;
        //     data_mem_read_enable    = 1'b0;
        //     data_mem_write_enable   = 1'b0;
        //     reg_writeback_select    = 3'b000;
        // end

        `OPCODE_OP:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b1;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b0;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b000;

            if (inst_bit_30 == 1'b1) begin
                alu_op_type             = 3'b011;
            end
`ifdef M_MODULE
            else if (inst_bit_25 == 1'b1) begin
                alu_op_type             = 3'b101;
            end
`endif
            else begin
                alu_op_type             = 3'b010;
            end
        end

        `OPCODE_LUI:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b1;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b0;
            alu_op_type             = 3'b000;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b011;
        end

        // // `OPCODE_OP_FP:
        // begin
        //     pc_write_enable         = 1'b1;
        //     regfile_write_enable    = 1'b0;
        //     alu_operand_a_select    = 1'b0;
        //     alu_operand_b_select    = 1'b0;
        //     alu_op_type             = 3'b000;
        //     jal_enable              = 1'b0;
        //     jalr_enable             = 1'b0;
        //     branch_enable           = 1'b0;
        //     data_mem_read_enable    = 1'b0;
        //     data_mem_write_enable   = 1'b0;
        //     reg_writeback_select    = 3'b000;
        // end

        `OPCODE_BRANCH:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b0;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b0;
            alu_op_type             = 3'b001;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b1;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b000;
        end

        `OPCODE_JALR:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b1;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b1;
            alu_op_type             = 3'b001;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b1;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b010;
        end

        `OPCODE_JAL:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b1;
            alu_operand_a_select    = 1'b1;
            alu_operand_b_select    = 1'b1;
            alu_op_type             = 3'b001;
            jal_enable              = 1'b1;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b010;
        end

        // // `OPCODE_SYSTEM:
        // begin
        //     pc_write_enable         = 1'b1;
        //     regfile_write_enable    = 1'b0;
        //     alu_operand_a_select    = 1'b0;
        //     alu_operand_b_select    = 1'b0;
        //     alu_op_type             = 3'b000;
        //     jal_enable              = 1'b0;
        //     jalr_enable             = 1'b0;
        //     branch_enable           = 1'b0;
        //     data_mem_read_enable    = 1'b0;
        //     data_mem_write_enable   = 1'b0;
        //     reg_writeback_select    = 3'b000;
        // end

        default:
        begin
            pc_write_enable         = 1'b1;
            regfile_write_enable    = 1'b0;
            alu_operand_a_select    = 1'b0;
            alu_operand_b_select    = 1'b0;
            alu_op_type             = 3'b000;
            jal_enable              = 1'b0;
            jalr_enable             = 1'b0;
            branch_enable           = 1'b0;
            data_mem_read_enable    = 1'b0;
            data_mem_write_enable   = 1'b0;
            reg_writeback_select    = 3'b000;
        end
    endcase
end

endmodule

