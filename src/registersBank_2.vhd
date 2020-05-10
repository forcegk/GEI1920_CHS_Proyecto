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
	variable cont : integer := 0;
	variable rs_i : integer := 0;
	variable rt_i : integer := 0;
	variable rd_i : integer := 0;
	variable tmp  : integer := 0;
	begin

		if rising_edge(clk) then 
			cont := cont + 1;
			if reset = '1' then
				for I in 0 to 31 loop
					regs(I) <= std_logic_vector(to_unsigned(I, regA'length));
				end loop;
			else
				rs_i := to_integer(unsigned(rs));
				rt_i := to_integer(unsigned(rt));
				rd_i := to_integer(unsigned(rd));
				
				if EscrReg = '1' then
					regs(rd_i) <= rdValue;
					report "clk: " & integer'image(cont) & " rdv: " &integer'image(to_integer(unsigned(rdValue)));
				end if;
								-- ponemos las salidas al valor de los registros
				regA <= regs(rs_i);
				regB <= regs(rt_i);
				
				tmp := to_integer(unsigned(regs(rs_i)));
				report "clk: " & integer'image(cont) & " ra: " & integer'image(tmp);
				tmp := to_integer(unsigned(regs(rt_i)));
				report "clk: " & integer'image(cont) & " rb: " & integer'image(tmp);
			end if;
		end if; 

	end process;

end architecture rtl;