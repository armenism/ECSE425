--Main control unit, responsible to intake the 32bit instruction vector and assign control signals for each stage.
--Those control signals will be propagated further down the pipeline.
--The control checks all the fields of the instruction, including op code, RS, RT, RD, immediate, func for R,L,J instruction
--types.

--Takes the instruction from the IF stage (supposed to read the instruction from the instr memory and pass it here)

--	R-type:  OP_code R: 000000 (coming from main control from ID)
--					funct for mult: 011000 -done
--					funct for mflo: 010010 -done
--					funct for mfhi: 010000 -done
--					funct for  add: 100000 -done
--					funct for  sub: 100010 -done
--					funct for  and: 100100 -done
--					funct for  div: 011010 -done
--					funct for  slt: 101010 -done
--					funct for   or: 100101 -done
--					funct for  nor: 100111 -done
--					funct for  xor: 101000 -done
--					funct for  sra: 000011 -done
--					funct for  srl: 000010 -done
--					funct for  sll: 000000 -done
--					funct for   jr: 001000 -done
--
--	I-type:  OP_code I, addi : 001000
--		   OP_code I, slti : 001010
--		   OP_code I,  lui : 001111
--		   OP_code I, andi : 001100
--		   OP_code I,  ori : 001101
--		   OP_code I, xori : 001110

--		   OP_code I,  bne : 000101
--		   OP_code I,  beq : 000100
--		   OP_code I,   sw : 101011
--		   OP_code I,   lw : 100011


LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signal_types.all;

entity CPU_control_unit is
  port(
    instruction: in std_logic_vector(31 downto 0); --the actual binary instruction that will get fetched.
    IF_SIGS: out IF_CTRL_SIGS; -- All the control signals (types) to be passed down the pipe
    ID_SIGS: out ID_CTRL_SIGS;
    EX_SIGS: out EX_CTRL_SIGS;
    MEM_SIGS:  out MEM_CTRL_SIGS;
    WB_SIGS: out WB_CTRL_SIGS
  );
end CPU_control_unit;

architecture control of CPU_control_unit is

  signal instruction_type : control_unit_instruction;
  --use alias to define the funct and opcode, since its just part of the input 32 bit instruction
  alias funct: std_logic_vector(5 downto 0) is instruction(5 downto 0); --funct code is defined in the lower 6 bits of the 32 bit instruction
  alias op_code: std_logic_vector(5 downto 0) is instruction(31 downto 26);  --OP code is defined in the upper 6 bits of the 32 bit instruction

begin

 --Process decoding the instruction type based on op code and funct (preprocessing for control assignment)
 generate_control: process(funct,op_code):

  begin

    case op_code is

      -- R TYPE case
      when "000000" =>

          --check funct field to distinguish the R-type op
          case funct =>
            --mult/div case
            when "011010" =>
                instruction_type <= r_multi_div;
            when "011000" =>
                instruction_type <= r_multi_div;
            --jr case
            when "001000" =>
                instruction_type <= r_jump_register;
            --mflo/mfhi case
            when "010000" =>
                instruction_type <= r_hilo;
            when "010010" =>
                instruction_type <= r_hilo;
            --add case
            when "100000" =>
                instruction_type <= r_arithmetic;
            --sub case
            when "100010" =>
                instruction_type <= r_arithmetic;
            --and case
            when "100100" =>
                instruction_type <= r_arithmetic;
            --slt case
            when "101010" =>
                instruction_type <= r_arithmetic;
            --or case
            when "100101" =>
                instruction_type <= r_arithmetic;
            --nor case
            when "100111" =>
                instruction_type <= r_arithmetic;
            --xor case
            when "101000" =>
                instruction_type <= r_arithmetic;
            --sra case
            when "000011" =>
                instruction_type <= r_arithmetic;
            --srl case
            when "000010" =>
                instruction_type <= r_arithmetic;
            --sll case
            when "000000" =>
                instruction_type <= r_arithmetic;
          end case;


      -- I type case arithmetic
      --addi case
      when "001000" =>
          instruction_type <= i_arithmetic;
      --slti case
      when "001010" =>
          instruction_type <= i_arithmetic;
      --andi case
      when "001100" =>
          instruction_type <= i_arithmetic;
      --ori case
      when "001101" =>
          instruction_type <= i_arithmetic;
      --xori case
      when "001110" =>
          instruction_type <= i_arithmetic;


      -- I type case lui
      --lui case
      when "001111" =>
          instruction_type <= i_lui;


      -- I type case memory operations
      --case lw
      when "100011" =>
          instruction_type <= i_memory;
      --case sw
      when "101011" =>
          instruction_type <= i_memory;


      -- I type case branch operations
      --case beq
      when "000100" =>
          instruction_type <= i_br;
      --case bne
      when "000101" =>
          instruction_type <= i_br;


      -- J type case jump operations
      --case jump
      when "000010" =>
          instruction_type <= j_jump;
      --case jump
      when "000011" =>
          instruction_type <= j_jal;

      --Undef
      when others =>
          null;
  end case;

end process;

--Process responsible for control signal assignemnt for every stage
control_signal_assignemnt: process(instruction_type, funct, op_code)
  begin

    --Based on previously assigned instruction type, assign control.
    case instruction_type

    -------------------------------------------------------------- R TYPE ARITHMETIC
    when r_arithmetic =>

    -- Applicable for normal r type arithmetic:add, sub, sub, slt, and, or, nor, xor
    -- Applicable for r type shifts: sll, srl, sra

      --First set all IF signals to 0 (propagation purposesm not a jump or branch)
      IF_SIGS.jump <= '0';
      IF_SIGS.bne <= '0';
      IF_SIGS.branch <= '0';

      --Then set all ID signals to 0 (propagation purposes, not a jump or branch)
      ID_SIGS.branch <= '0';
      ID_SIGS.jr <= '0';
      ID_SIGS.zero_extend <= '0';

      --Then set all EX signals to 0 (propagation purposes, imm and jl not cases since arithm r type)
      EX_SIGS.imm_sel <= '0';
      EX_SIGS.jump_link <= '0';

      --Now depending on funct code, set control accordingly
      --In this case, we set ALU operation belonging to EX stage (as signal).
      case funct is

        --add
        when "100000" => EX_SIGS.ALU_control_op <= alu_add;
        --sub
        when "100010" => EX_SIGS.ALU_control_op <= alu_sub;
        --and
        when "100100" => EX_SIGS.ALU_control_op <= alu_and;
        --nor
        when "100111" => EX_SIGS.ALU_control_op <= alu_nor;
        --or
        when "100101" => EX_SIGS.ALU_control_op <= alu_or;
        --xor
        when "100110" => EX_SIGS.ALU_control_op <= alu_xor;
        --slt
        when "101010" => EX_SIGS.ALU_control_op <= alu_slt;
        --sll
        when "000000" => EX_SIGS.ALU_control_op <= alu_sll;
        --srl
        when "000010" => EX_SIGS.ALU_control_op <= alu_srl;
        --sra
        when "000011" => EX_SIGS.ALU_control_op <= alu_sra;
        --null
        when others => EX_SIGS.ALU_control_op <= add_op;

      end case;

      --Since not a lui operation, set to
      EX_SIGS.lui <= '0';

      --Since not a multiplication or division (only simple arithmetic operation) operation, set to 0 other
      --signals for execute stage
      EX_SIGS.mfhi <= '0';
      EX_SIGS.mflo <= '0';
      EX_SIGS.multdiv <= mult;
      EX_SIGS.write_hilo_result <= '0';

      --Also assign signals to MEM stage, all 0s in case or R arithmetic
      MEM_SIGS.read_from_memory <= '0';
      MEM_SIGS.write_to_memory <= '0';
      MEM_SIGS.memory_bus <= '0'; --> will need eventually

      --Finally because its an R type, write back is needed.
      WB_SIGS.write_to_register <= '1';
      -------------------------------------------------------------- R TYPE ARITHMETIC (done)

    -------------------------------------------------------------- R TYPE mult/div
    when r_multi_div =>

      --Applicable for mult and div

      --Same as before, not a jump or branch, so all 0s
      IF_SIGS.jump <= '0';
      IF_SIGS.bne <= '0';
      IF_SIGS.branch <= '0';

      --Then set all ID signals to 0 (propagation purposes, not a jump or branch)
      ID_SIGS.branch <= '0';
      ID_SIGS.jr <= '0';
      ID_SIGS.zero_extend <= '0';

      --Actual operation
      case funct is
         --div
        when "011010" => EX_SIGS.multdiv <= div_op;
         --mult
        when "011000" => EX_SIGS.multdiv <= mult_op;
         --others
        when others => EX_SIGS.multdiv <= div_op;

      end case;

      --No immediates, no jals
      EX_SIGS.use_imm <= '0';
      EX_SIGS.jump_and_link <= '0';

      --No loads
      EX_SIGS.lui <= '0';
      EX_SIGS.ALU_control_op <= alu_add;

      EX_SIGS.write_hilo_result <= '1';  --Set high or lwo bits write to 1 since we will be writing out higher or lower bits of the 64 but result
      EX_SIGS.mfhi <= '0';
      EX_SIGS.mflo <= '0';

      --MEM ops are all 0's
      MEM_SIGS.read_from_memory <= '0';
      MEM_SIGS.write_to_memory <= '0';
      MEM_SIGS.memory_bus <= '0'; --> will need eventually

      --No writeback in this case, only hi-lo write
      WB_SIGS.write_to_register <= '0';

    -------------------------------------------------------------- R TYPE mult/div (done)

    -------------------------------------------------------------- R TYPE jump register
      when r_jump_register =>

        --Same as before, but only now jump is set
        IF_SIGS.jump <= '1';
        IF_SIGS.bne <= '0';
        IF_SIGS.branch <= '0';

        --Same as before, but only now jump is set
        ID_SIGS.branch <= '0';
        ID_SIGS.jr <= '0';
        ID_SIGS.zero_extend <= '0';

        --Execute stage, all 0's
        EX_SIGS.multdiv <= mult;
        EX_SIGS.write_hilo_result <= '0';
        EX_SIGS.mfhi <= '0';
        EX_SIGS.mflo <= '0';
        EX_SIGS.use_imm <= '0';
        EX_SIGS.jump_and_link <= '0';

        --No lui
        EX_SIGS.lui <= '0';
        EX_SIGS.ALU_control_op <= alu_add;

        --MEM ops are all 0's
        MEM_SIGS.read_from_memory <= '0';
        MEM_SIGS.write_to_memory <= '0';
        MEM_SIGS.memory_bus <= '0'; --> will need eventually

        --No writeback in this case, only hi-lo write
        WB_SIGS.write_to_register <= '0';
    -------------------------------------------------------------- R TYPE jump register(done)

    -------------------------------------------------------------- R TYPE mflo/mfhi
    when r_hilo =>

      --Same as before, not a jump or branch, so all 0s
      IF_SIGS.jump <= '0';
      IF_SIGS.bne <= '0';
      IF_SIGS.branch <= '0';

      --Then set all ID signals to 0 (propagation purposes, not a jump or branch)
      ID_SIGS.branch <= '0';
      ID_SIGS.jr <= '0';
      ID_SIGS.zero_extend <= '0';

      --Execute stage, all 0's
      EX_SIGS.multdiv <= mult;
      EX_SIGS.write_hilo_result <= '0';
      EX_SIGS.use_imm <= '0';
      EX_SIGS.jump_and_link <= '0';

      --No lui
      EX_SIGS.lui <= '0';
      EX_SIGS.ALU_control_op <= alu_add;

      --Actual operation
      case funct is
         --mfhi
        when "010000" =>
          EX_SIGS.mfhi <= '1'';
          EX_SIGS.mflo <= '0'';
         --mflo
        when "010010" =>
          EX_SIGS.mfhi <= '0';
          EX_SIGS.mflo <= '1'';
         --others
        when others =>
          EX_SIGS.mfhi <= '0';
          EX_SIGS.mflo <= '0'';

      end case;

      --MEM ops are all 0's
      MEM_SIGS.read_from_memory <= '0';
      MEM_SIGS.write_to_memory <= '0';
      MEM_SIGS.memory_bus <= '0'; --> will need eventually

      --Necessary to wb result
      WB_SIGS.write_to_register <= '1';

    -------------------------------------------------------------- R TYPE mflo/mfhi(done)

    -------------------------------------------------------------- I TYPE arithmetic
    when i_arithmetic =>
				-- Arithmetic I-Type instructions addi, addiu, andi, slti, sltiu, ori, xori

        --Same as before, not a jump or branch, so all 0s
        IF_SIGS.jump <= '0';
        IF_SIGS.bne <= '0';
        IF_SIGS.branch <= '0';

        --Then set all ID signals to 0 (propagation purposes, not a jump or branch), extention must be there though
        ID_SIGS.branch <= '0';
        ID_SIGS.jr <= '0';

        --****DISTINGUISH ZERO and SIGN extention
        case funct is
           --case zero ext
          when "001100" =>
            ID_SIGS.zero_extend <= '1';
           --case zero ext
          when "001101" =>
            ID_SIGS.zero_extend <= '1';
           --others
          when others => ID_SIGS.zero_extend <= '0';

        end case;

        --Execute stage, all 0's, except IMM signal
        EX_SIGS.multdiv <= mult;
        EX_SIGS.write_hilo_result <= '0';
        EX_SIGS.use_imm <= '1';
        EX_SIGS.jump_and_link <= '0';
        EX_SIGS.mfhi <= '0';
        EX_SIGS.mflo <= '0';

				--ALU ope in case of immediate arithmetic
				case opcode IS
          --addi
					when "001000" => EX_SIGS.ALU_control_op <= alu_add;
          --andi
					when "001100" => EX_SIGS.ALU_control_op <= alu_and;
          --ori
					when "001101" => EX_SIGS.ALU_control_op <= alu_or;
           --xori
					when "001110" => EX_SIGS.ALU_control_op <= alu_xor;
          --slti
          when "001010" => EX_SIGS.ALU_control_op <= alu_slt;
          --others
					when others => EX_SIGS.ALU_control_op <= alu_add;

				end case;

        --MEM ops are all 0's
        MEM_SIGS.read_from_memory <= '0';
        MEM_SIGS.write_to_memory <= '0';
        MEM_SIGS.memory_bus <= '0'; --> will need eventually

        --Necessary to wb result
        WB_SIGS.write_to_register <= '1';

      -------------------------------------------------------------- I TYPE arithmetic(done)

      -------------------------------------------------------------- I TYPE LUI
      when i_lui =>

        --Same as before, not a jump or branch, so all 0s
        IF_SIGS.jump <= '0';
        IF_SIGS.bne <= '0';
        IF_SIGS.branch <= '0';

        --Then set all ID signals to 0 (propagation purposes, not a jump or branch)
        ID_SIGS.branch <= '0';
        ID_SIGS.jr <= '0';
        ID_SIGS.zero_extend <= '0';

        --EX all to 0's except lui and imm
        EX_SIGS.use_imm <= '1';
        EX_SIGS.jump_and_link <= '0';

        EX_SIGS.lui <= '1';
        EX_SIGS.ALU_control_op <= alu_add;
        EX_SIGS.multdiv <= mult;

        EX_SIGS.write_hilo_result <= '0';
        EX_SIGS.mfhi <= '0';
        EX_SIGS.mflo <= '0';

        --MEM ops are all 0's
        MEM_SIGS.read_from_memory <= '0';
        MEM_SIGS.write_to_memory <= '0';
        MEM_SIGS.memory_bus <= '0'; --> will need eventually


        --Necessary to wb result
        WB_SIGS.write_to_register <= '1';
      -------------------------------------------------------------- I TYPE LUI(done)

      -------------------------------------------------------------- I TYPE memory sw/lw
      when i_memory =>

        --Same as before, not a jump or branch, so all 0s
        IF_SIGS.jump <= '0';
        IF_SIGS.bne <= '0';
        IF_SIGS.branch <= '0';

        --Then set all ID signals to 0 (propagation purposes, not a jump or branch)
        ID_SIGS.branch <= '0';
        ID_SIGS.jr <= '0';
        ID_SIGS.zero_extend <= '0';

        --EX all to 0's except imm
        EX_SIGS.use_imm <= '1';
        EX_SIGS.jump_and_link <= '0';

        EX_SIGS.lui <= '0';
        EX_SIGS.ALU_control_op <= alu_add;
        EX_SIGS.multdiv <= mult;

        EX_SIGS.write_hilo_result <= '0';
        EX_SIGS.mfhi <= '0';
        EX_SIGS.mflo <= '0';

        --Depending on op code now need to properly set signals for read, write
        --as well as the right back stage control.
        case opcode is
          --lw
          when "100011" =>
            MEM_SIGS.read_from_memory <= '1';
            MEM_SIGS.write_to_memory <= '0';
            MEM_SIGS.memory_bus <= '1';
            WB_SIGS.write_to_register <= '1';
          --sw
          when "101011" =>
            MEM_SIGS.read_from_memory <= '0';
            MEM_SIGS.write_to_memory <= '1';
            MEM_SIGS.memory_bus <= '1';
            WB_SIGS.write_to_register <= '0';
          --others
          when others =>
            MEM_SIGS.read_from_memory <= '0';
            MEM_SIGS.write_to_memory <= '0';
            MEM_SIGS.memory_bus <= '0';
            WB_SIGS.write_to_register <= '0';
        end case;
        -------------------------------------------------------------- I TYPE memory sw/lw (done)

        -------------------------------------------------------------- I TYPE branch
        when i_br =>

          --Branch signal valid
  				IF_SIGS.branch <= '1';
  				IF_SIGS.jump <= '0';

          case opcode is

            --bne case
            when "000101" =>
              IF_SIGS.bne <= '1';
            --otherwise
            when others =>
              IF_SIGS.bne <= '0';

          end case;


          --Then set all ID signals to 0 (except branch)
          ID_SIGS.branch <= '1'';
          ID_SIGS.jr <= '0';
          ID_SIGS.zero_extend <= '0';

          --EX all to 0's except imm
          EX_SIGS.use_imm <= '1';
          EX_SIGS.jump_and_link <= '0';

          EX_SIGS.lui <= '0';
          EX_SIGS.ALU_control_op <= alu_add;
          EX_SIGS.multdiv <= mult;

          EX_SIGS.write_hilo_result <= '0';
          EX_SIGS.mfhi <= '0';
          EX_SIGS.mflo <= '0';

          --MEM ops are all 0's
          MEM_SIGS.read_from_memory <= '0';
          MEM_SIGS.write_to_memory <= '0';
          MEM_SIGS.memory_bus <= '0'; --> will need eventually

          --No wb
  				WB_SIGS.write_to_register <= '0';
      -------------------------------------------------------------- I TYPE branch (done)

      -------------------------------------------------------------- J TYPE jump
      when j_jump =>
        --Jump case
        IF_SIGS.jump <= '1';
        IF_SIGS.bne <= '0;
        IF_SIGS.branch <= '0';

        --Then set all ID signals to 0 (except branch)
        ID_SIGS.branch <= '0'';
        ID_SIGS.jr <= '0';
        ID_SIGS.zero_extend <= '0';

        --EX all to 0's
        EX_SIGS.use_imm <= '0';
        EX_SIGS.jump_and_link <= '0';

        EX_SIGS.lui <= '0';
        EX_SIGS.ALU_control_op <= alu_add;
        EX_SIGS.multdiv <= mult;

        EX_SIGS.write_hilo_result <= '0';
        EX_SIGS.mfhi <= '0';
        EX_SIGS.mflo <= '0';


        --MEM ops are all 0's
        MEM_SIGS.read_from_memory <= '0';
        MEM_SIGS.write_to_memory <= '0';
        MEM_SIGS.memory_bus <= '0'; --> will need eventually

        --No wb
				WB_SIGS.write_to_register <= '0';
      -------------------------------------------------------------- J TYPE jump(done)

      -------------------------------------------------------------- J TYPE jump and link
			when j_jal =>
        --Jump case
        IF_SIGS.jump <= '1';
        IF_SIGS.bne <= '0;
        IF_SIGS.branch <= '0';

        --Then set all ID signals to 0 (except branch)
        ID_SIGS.branch <= '0'';
        ID_SIGS.jr <= '0';
        ID_SIGS.zero_extend <= '0';

        --EX all to 0's except jump and link
        EX_SIGS.use_imm <= '0';
        EX_SIGS.jump_and_link <= '1';

        EX_SIGS.lui <= '0';
        EX_SIGS.ALU_control_op <= alu_add;
        EX_SIGS.multdiv <= mult;

        EX_SIGS.write_hilo_result <= '0';
        EX_SIGS.mfhi <= '0';
        EX_SIGS.mflo <= '0';

        --MEM ops are all 0's
        MEM_SIGS.read_from_memory <= '0';
        MEM_SIGS.write_to_memory <= '0';
        MEM_SIGS.memory_bus <= '0'; --> will need eventually

        --Have to wb
				WB_SIGS.write_to_register <= '1';

    end case;

  end process;


end control;
