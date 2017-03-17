--Module containing type mapping for singals
--Intended to make signal passing easier to each module down the pipe, without defining
--many signals in each module.

--ID will be responsible to set all these control signals according to the decoding of the instruction

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package signal_types is

	--SIGNAL TYPES FOR ALU
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
                        alu_nor,
                        alu_xor,
                        alu_xori,
                        alu_mfhi,
								        alu_mflo,
                        alu_lui,
                        alu_sll,
                        alu_srl,
                        alu_sra);

	--SIGNAL TYPES for multiplication unit (EX stage)
	type multiplication_unit is (mult, div);

	--SIGNAL TYPES MAIN CONTROL UNIT
	type control_unit_instruction is(r_arithmetic,
																	 r_multi_div,
																	 r_hilo,
																	 r_jump_register,
								  							 	 i_arithmetic,
																	 i_memory,
																	 i_lui,
																	 i_br,
								  							 	 j_jump,
																	 j_jal)

  --SIGNAL TYPES FOR INSTRUCTION FETCH STAGE CONTROL SIGNALS
	type IF_CTRL_SIGS is
		record
			branch 	: STD_LOGIC;
			jump	 	: STD_LOGIC;
			bne	 	: STD_LOGIC;
		end record;

	--SIGNAL TYPES FOR INSTRUCTION DECODE STAGE CONTROL SIGNALS
	type ID_CTRL_SIGS is
		record
			branch 		: std_logic;
			jr		 		: std_logic;
			zero_extend : std_logic;
		end record;

	--SIGNAL TYPES FOR EXECUTE STAGE CONTROL SIGNALS
	type EX_CTRL_SIGS is
		record
			use_imm		: std_logic;
			jump_and_link	: std_logic;
			ALU_control_op : alu_operation;
			multdiv: multiplication_unit;
			mfhi: std_logic;
			mflo: std_logic;
			lui: std_logic;
			write_hilo_result: std_logic;  --post div/mult signal necessary to indicate which bits will be written

		end record;

  -- Type necessary to contain signals necessary for WB stage control
	type WB_CTRL_SIGS is
		record
			write_to_register: std_logic;
			temp: std_logic;
	  end record;

  -- Type necessary to contain signals necessary for MEM stage control
	type MEM_CTRL_SIGS is
		record
			read_from_memory: std_logic;
			write_to_memory: std_logic;
			memory_bus: std_logic;
		end record;

end signal_types;
