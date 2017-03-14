--Module containing type mapping for singals
--Intended to make signal passing easier to each module down the pipe, without defining
--many signals in each module.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package signal_types is

	type alu_operation is(alu_add,
                        alu_addi,
                        alu_sub,
                        alu_mult,
                        alu_div,
								        alu_slt,
                        alu_slti,
                        alu_and,
                        alu_andi,
                        alu_or,
								        alu_ori,
                        alu_xor,
                        alu_xori,
                        alu_mfhi,
								        alu_mflo,
                        alu_lui,
                        alu_sll,
                        alu_srl,
                        alu_sra);

	type IF_CTRL_SIGS is
		record
		--TODO define signales needed for WB stage
		end record;

	type ID_CTRL_SIGS is
		record
			branch 		: STD_LOGIC;
			jr		 		: STD_LOGIC;
			zero_extend : STD_LOGIC;
		end record;

	type EX_CTRL_SIGS is
		record
			use_imm		: STD_LOGIC;
			jump_and_link	: STD_LOGIC;
			ALU_control_op : alu_operation;
		end record;

  -- Type necessary to contain signals necessary for WB stage control
	type WB_CTRL_SIGS is
		record
    write_to_register: STD_LOGIC;
	  end record;

  -- Type necessary to contain signals necessary for MEM stage control
	type MEM_CTRL_SIGS is
		record
    read_from_memory: std_logic;
    write_to_memory: std_logic;
		end record;

end signal_types;
