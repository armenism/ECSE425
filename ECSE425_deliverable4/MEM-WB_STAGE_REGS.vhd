-- MEM/WB stage registers

-- Takes input from the EX-MEM_STAGE_REGS, MEM OUTPUT
-- Takes also input from ALU output (for passing data further if was not a memery OP
-- as well as for forwarding purposes)
-- Outputs the data from memory, the ALU result and the control signals that were given at input
-- from previous EX-MEM stage regs

entity MEM-WB_STAGE_REGS is
  port(

    clk : in std_logic;

    --INPUTS TO STAGE REGS

    --Control signals for WB from previous stage registers
    --Signals for WB (WriteBack) stage
    write_reg: in std_logic;
    mem_to_reg: in std_logic;

    --Input from Memory
    data_from_MEM: in std_logic_vector(31 downto 0);

    --Input from ALU
    data_from_ALU: in std_logic_vector(31 downto 0);
    zero_from_ALU: in std_logic;

    destinarion_reg_RD: in std_logic_vector(4 downto 0);

    --OUTPUTS TO STAGE REGS

    write_reg_out: out std_logic;
    mem_to_reg_out: out std_logic;
    data_from_MEM_out: out std_logic_vector(31 downto 0);
    data_from_ALU_out: out std_logic_vector(31 downto 0);
    zero_from_ALU_out: out std_logic;
    destinarion_reg_RD_out: out std_logic_vector(4 downto 0)

  );

  architecture memwbstage of WB_STAGE_REGS is

    begin

    end memwbstage;

end MEM-WB_STAGE_REGS;
