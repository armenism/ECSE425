-- EXMEM stage
-- driven by clock
-- gets signals from ALU, EX stage and ID/EX stage directly (memory write/read signals)
-- ***dont forget signals encessary for writeback too

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

    --TODO: Make temp signals, assign inputs to them and then
    -- in a process, assign those temp signals back to outputs (for each input ALU, WB and MEM)

end exmemstage;
