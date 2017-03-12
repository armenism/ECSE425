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
end MEM-WB_STAGE_REGS;

  architecture memwbstage of MEM-WB_STAGE_REGS is

    --Define registers here
    signal pipereg_write_reg : std_logic;
    signal pipereg_mem_to_reg : std_logic;
    signal pipereg_data_from_MEM: std_logic_vector(31 downto 0);
    signal pipereg_data_from_ALU: std_logic_vector(31 downto 0);
    signal pipereg_zero_from_ALU: std_logic;
    signal pipereg_destinarion_reg_RD: std_logic_vector(4 downto 0);

    begin

      --Assign inputs to registers
      pipereg_write_reg <= write_reg;
      pipereg_mem_to_reg <= mem_to_reg;
      pipereg_data_from_MEM <= data_from_MEMs;
      pipereg_data_from_ALU <= data_from_ALU;
      pipereg_zero_from_ALU <= zero_from_ALU;
      pipereg_destinarion_reg_RD <= destinarion_reg_RD;

      MEM_WB_STAGE_PROC: process(clk)
      begin
        if rising_edge(clk) then

        end if;

  end memwbstage;
