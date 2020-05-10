library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity tb_filtro1 is
end tb_filtro1;

architecture test of tb_filtro1 is

	component filtro port (
		clk, reset : in std_logic;
		intro : in signed(7 downto 0);
		outro : out signed(7 downto 0);
		res : out signed(15 downto 0));
	end component;
	
signal clk : STD_LOGIC := '0';
signal rst : STD_LOGIC;
signal intro, outro : signed(7 downto 0);
signal res : signed(15 downto 0);
constant NUM_CICLOS : integer := 20;
	
begin
	
	dut: filtro port map(
		clk => clk,
		reset => rst,
		intro => intro,
		outro => outro,
		res => res
	);

	
	reloj: process
		variable i : integer;
	begin
		for i in 1 to NUM_CICLOS * 2  + 6 loop
			clk <= not clk;
			wait for 0.5 ns;
		end loop;
		wait;
	end process;

	-- creando el reset
	ini: process
	begin
		rst<='1';
		wait until clk'event and clk='1';
		rst<='0' after 2 ns;
		wait;
	end process;	
	

	simulacion: process	
	variable i : integer;
	begin
	
		wait until rst'event and rst = '0';
		
		intro <= X"00";
		
		wait until clk'event and clk = '1';
		wait for 0 ns;
		
		for i in 1 to NUM_CICLOS loop
			intro <= to_signed(i, 8);
			wait until clk'event and clk = '1';
		end loop;
		
		assert false report "se ha terminado";
		wait;
	
	end process;
	
	
end test;