library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;


entity registersBank is
	Port (
		clk, reset : in  std_logic;
		rs, rt, rd : in  std_logic_vector(4 downto 0);
		rdValue    : in  std_logic_vector(31 downto 0);
		EscrReg    : in  std_logic;
		regA, regB : out std_logic_vector(31 downto 0)
	);
end entity registersBank;

architecture rtl of registersBank is
	type registros_array is array (0 to 31) of std_logic_vector (31 downto 0);
	signal regs : registros_array;
begin
	-- reset síncrono
	sync:process(clk, reset)
	begin

		if rising_edge(clk) then 
			if reset = '1' then
				for I in 0 to 31 loop
					regs(I) <= std_logic_vector(to_unsigned(I, regA'length));
				end loop;
			else
				if EscrReg = '1' then
					regs(to_integer(unsigned(rd))) <= rdValue;
				end if;

				-- ponemos las salidas al valor de los registros
				regA <= regs(to_integer(unsigned(rs)));
				regB <= regs(to_integer(unsigned(rt)));

			end if;
		end if; 

	end process;

end architecture rtl;