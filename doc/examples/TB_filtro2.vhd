library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_textio.all;
use std.textio.all;


entity tb_filtro2 is
end tb_filtro2;

architecture test of tb_filtro2 is

	component filtro port (
		clk, reset : in std_logic;
		intro : in signed(7 downto 0);
		outro : out signed(7 downto 0);
		res : out signed(15 downto 0)
	);
	end component;
	
signal clk : STD_LOGIC := '0';
signal rst : STD_LOGIC;
signal intro, outro : signed(7 downto 0);
signal res : signed(15 downto 0);
	
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
			clk <= not clk;
			wait for 0.5 ns;
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
	file stimuli : text is in "filtro_IN.txt";
	file stimulo : text is in "filtro_OUT.txt";
	variable aline : line;	
	variable entrada, resultado : integer; 
	variable v_res, c_res : signed (15 downto 0);
	
	begin
	
		intro <= x"00";
		
		wait until rst'event and rst = '0';

		loop
			
			if (not(endfile(stimuli))) then
				readline(stimuli, aline);
				read(aline, entrada);

				readline(stimulo, aline);
				read(aline, resultado);

			else
				wait for 2 ns; -- para ver los dos ultimos valores
				assert false
					report "Se ha llegado al final del fichero de entrada. Comprobar si hay errores anteriores a este mensaje."
					severity failure;
			end if;

			wait until clk'event and clk = '1';
			wait for 0 ns;

			intro <= to_signed(entrada, 8);
			v_res := to_signed(resultado, 16);	
			
			wait for 1 ns;
			
			c_res := res;
			
			assert (v_res = c_res)
				report "No coincide el valor de res"
				severity error;
					
			

		end loop;
	end process;
	
	
end test;