LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

--Entity declaration
ENTITY ID_EX IS
	PORT (
		clock					: in std_logic;
		clr : in std_logic;

		--Data inputs
		InstrD_in			: in std_logic_vector(31 downto 0);
		RD0_in				: in std_logic_vector(31 downto 0); -- Register Data 0
		RD1_in				: in std_logic_vector(31 downto 0); -- Register Data 1
		SignExtended_in	: in std_logic_vector(31 downto 0); -- This is only 16 bits, but the output will be 32

		--Register inputs
		Rs_in				: in std_logic_vector(4 downto 0);
		Rt_in				: in std_logic_vector(4 downto 0);
		Rd_in				: in std_logic_vector(4 downto 0);

		--Control inputs
		RegWriteD_in			: in std_logic;
		MemToRegD_in			: in std_logic;
		MemWriteD_in			: in std_logic;
		ALUControlD_in			: in std_logic_vector(3 downto 0);
		ALUSRCD_in				: in std_logic;
		RegDstD_in				: in std_logic; --Register destination
		BranchD_in				: in std_logic;
		
		--Other control inputs (probably not needed)
--		LUI_in					: in std_logic;
--		BNE_in         	   : in std_logic;
--		Asrt_in           	: in std_logic;
--    Jal_in            	: in std_logic;
--		MemReadD_in			: in std_logic;

		--Data Outputs
		InstrD_out			: out std_logic_vector(31 downto 0);
		RD0_out				: out std_logic_vector(31 downto 0); -- Register Data 0
		RD1_out				: out std_logic_vector(31 downto 0); -- Register Data 1
		SignExtended_out	: out std_logic_vector(31 downto 0);

		--Register outputs
		Rs_out				: out std_logic_vector(4 downto 0);
		Rt_out				: out std_logic_vector(4 downto 0);
		Rd_out				: out std_logic_vector(4 downto 0);

		--Control outputs
		RegWriteD_out		: out std_logic;
		MemToRegD_out		: out std_logic;
		MemWriteD_out		: out std_logic;
		BranchD_out			: out std_logic;
		ALUControlD_out	: out std_logic_vector(3 downto 0);
		ALUSRCD_out			: out std_logic;
		RegDstD_out			: out std_logic
		
		--Other control outputs (probably not needed)
--		LUI_out				: out std_logic;
--		MemRead_out			: out std_logic;
--		BNE_out           : out std_logic;
--		Asrt_out          : out std_logic;
--    Jal_out           : out std_logic
	);
END ID_EX;

--Architecture Declaration
ARCHITECTURE arch OF ID_EX IS

--Temporary signal assignments 
--data
signal temp_InstrD			: std_logic_vector(31 downto 0);
signal temp_RD0				: std_logic_vector(31 downto 0);
signal temp_RD1				: std_logic_vector(31 downto 0);
signal temp_SignExtended	: std_logic_vector(31 downto 0);

--registers		
signal temp_Rs				: std_logic_vector(4 downto 0);
signal temp_Rt				: std_logic_vector(4 downto 0);
signal temp_Rd				: std_logic_vector(4 downto 0);

--control
signal temp_RegWriteD		: std_logic;
signal temp_MemToRegD		: std_logic;
signal temp_MemWriteD		: std_logic;
signal temp_BranchD			: std_logic;
signal temp_ALUControlD		: std_logic_vector(3 downto 0);
signal temp_ALUSRCD			: std_logic;
signal temp_RegDstD			: std_logic;

--Probably not needed
--signal temp_LUI				: std_logic;
--signal temp_MemReadD		: std_logic;
--signal temp_bne				: std_logic;
--signal temp_Jal				: std_logic;
--signal temp_Asrt			: std_logic;


BEGIN

--forward inputs to temp signals
	temp_InstrD				<= InstrD_in;
	temp_RD0					<= RD0_in;
	temp_RD1					<= RD1_in;
	temp_SignExtended		<= SignExtended_in;
	temp_Rs					<= Rs_in;
	temp_Rt					<= Rt_in;
	temp_Rd					<= Rd_in;
	temp_RegWriteD			<= RegWriteD_in;
	temp_MemToRegD			<= MemToRegD_in;
	temp_MemWriteD			<= MemWriteD_in;
	temp_BranchD			<= BranchD_in;
	temp_ALUControlD		<= ALUControlD_in;
	temp_ALUSRCD			<= ALUSRCD_in;
	temp_RegDstD			<= RegDstD_in;
	
	--Probably not needed
--	temp_LUI					<= LUI_in;
--	temp_MemRead			<= MemRead_in;
--	temp_bne 				<= BNE_in;
--	temp_Asrt				<= Asrt_in;
--	temp_Jal 				<= Jal_in;

--Process Block
process (clock)
	begin
	--forward signals to output on rising edge
	if rising_edge(clock) then
		--data		
		InstrD_out			<= temp_InstrD;
		RD0_out				<= temp_RD0;
		RD1_out				<= temp_RD1;
		SignExtended_out	<= temp_SignExtended;

		--registers
		Rs_out				<= temp_Rs;
		Rt_out				<= temp_Rt;
		Rd_out				<= temp_Rd;

		--control
		RegWriteD_out		<= temp_RegWriteD;
		MemToRegD_out		<= temp_MemToRegD;
		MemWriteD_out		<= temp_MemWriteD;
		BranchD_out			<= temp_BranchD;
		ALUControlD_out	<= temp_ALUControlD;
		ALUSRCD_out			<= temp_ALUSRCD;
		RegDstD_out			<= temp_RegDstD;
		
--		MemRead_out			<= temp_MemRead;
--		LUI_out				<= temp_LUI;
--		BNE_out 			<= temp_bne;
--		Asrt_out			<= temp_Asrt;
--		Jal_out 			<= temp_Jal;

	end if;

end process;

END arch;