-- ALU Controller
-- Gets input from main control (from decode stage) and issues the appropriate signal to the ALU based 
-- on FUNC code from instruction and the ALU OP codes

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALUcontroller is

	port(

		ALU_op : in std_logic_vector(3 downto 0);  -- check on the vector size later.
		func_code: in std_logic_vector(5 downto 0); -- fucntion code coming from instruction funct field
		res_ALU_op: out std_logic_vector(3 downto 0); -- output to the actual ALU
	);

end ALUcontroller;


architecture alu_ctrl_arch of ALUcontroller is

	signal temp_res_ALU_op: std_logic_vector(3 downto 0);

	alu_ctl_process: process(ALU_op,func_code)

		begin

		--TODO: cases based on alu op and funct code here 

		end process;

	res_ALU_op <= temp_res_ALU_op;

end alu_ctrl_arch;

