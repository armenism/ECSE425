-- EXMEM stage registers
-- driven by clock
-- gets signals from ALU, EX stage and ID/EX stage directly (memory write/read signals)
-- ***dont forget signals encessary for writeback too

-- Pipelining the data path requires that values passed from one pipe stage to the next must be placed in registers.
-- Hence this module is repsonsible to hold registers to hold values from EX stage and pass thos values to next stage (MEM)

entity EX_MEM_STAGE is

  port(
    clk : in std_logic;

    --INPUTS TO STAGE
    --Signals from the ALU
    result_in_from_ALU : in std_logic_vector(31 downto 0);
    zero_in_from_ALU: in std_logic;
    data_B: in std_logic_vector(31 downto 0);  --> The data register that we will be writing to memory (at sw) and data_A in this case will contain the base register address

    --Signals for WB (WriteBack) stage
    write_reg: in std_logic;
    mem_to_reg: in std_logic;

    --Signals for MEM stage
    memory_write: in std_logic;
    memory_read: in std_logic;
    br: in std_logic;

    --OUTPUTS FROM STAGE
    --Signals from the ALU
    result_in_from_ALU_out : in std_logic_vector(31 downto 0);
    zero_in_from_ALU_out: in std_logic;
    data_B_out: in std_logic_vector(31 downto 0);

    --Signals for WB (WriteBack) stage
    write_reg_out: in std_logic;
    mem_to_reg_out: in std_logic;

    --Signals for MEM stage
    memory_write_out: in std_logic;
    memory_read_out: in std_logic;
    br_out: in std_logic
  );

end entity EX_MEM_STAGE;

architecture exmemstage of EX_MEM_STAGE is

    --Registers necessary for storing the values from previosu stage (EX) and pass them to next stage (MEM)
    --There registers contain both DATA and CONTROL values.
    signal pipereg_result_in_from_ALU : std_logic_vector(31 downto 0);
    signal pipereg_zero_in_from_ALU_out: std_logic;
    signal pipereg_data_B_out: std_logic_vector(31 downto 0);
    signal pipereg_write_reg_out: std_logic;
    signal pipereg_mem_to_reg_out: std_logic;
    signal pipereg_memory_write_out: std_logic;
    signal pipereg_memory_read_out: std_logic;
    signal pipereg_br_out: std_logic;

    begin
      --Assigning the input values from the input port to the registers
      pipereg_result_in_from_ALU <= result_in_from_ALU;
      pipereg_zero_in_from_ALU_out <= zero_in_from_ALU;
      pipereg_data_B_out <= data_B;
      pipereg_write_reg_out <= write_reg;
      pipereg_mem_to_reg_out <= mem_to_reg;
      pipereg_memory_write_out <= memory_write;
      pipereg_memory_read_out <= memory_read;
      pipereg_br_out <= br;

      EX_MEM_STAGE_PROC: process(clk)
      begin


      end process;
end exmemstage;
