library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use std.textio.all;

entity tb_registersBank is
end tb_registersBank;

architecture test of tb_registersBank is
	
	component bank port (
		clk, reset : in  std_logic;
		rs, rt, rd : in  std_logic_vector(4 downto 0);
		rdValue    : in  std_logic_vector(31 downto 0);
		EscrReg    : in  std_logic;
		regA, regB : out std_logic_vector(31 downto 0));
	end component;
	
signal clk : STD_LOGIC := '0';
signal rst, EscrReg : STD_LOGIC;
signal rs, rt, rd : std_logic_vector(4 downto 0);
signal rdValue, regA, regB : std_logic_vector(31 downto 0);
constant NUM_CICLOS : integer := 20;

constant NUM_COL : integer := 5;
type t_integer_array is array(integer range <>) of integer;
file file_handler : text open read_mode is "tb.dat";

begin
	
	dut: bank port map(
		clk => clk,
		reset => rst,
		EscrReg => EscrReg,
		rs => rs,
		rt => rt,
		rd => rd,
		rdValue => rdValue,
		regA => regA,
		regB => regB
	);

	
	reloj: process
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
	variable row : line;
	variable v_data_read : t_integer_array(1 to NUM_COL);
	begin
	
		wait until rst'event and rst = '0';
		
		rs <= "00000";
		rt <= "00000";
		rd <= "00000";
		rdValue <= "00000000000000000000000000000000";
		EscrReg <= '0';
		
		while (not endfile(file_handler)) loop
			wait until clk'event and clk = '1';
			wait for 0 ns;

			readline(file_handler, row);
			
			for i in 1 to NUM_COL loop
				read(row, v_data_read(i));
			end loop;
			
			rs <= std_logic_vector(to_unsigned(v_data_read(1),rs'length));
			rt <= std_logic_vector(to_unsigned(v_data_read(2),rt'length));
			rd <= std_logic_vector(to_unsigned(v_data_read(3),rd'length));
			rdValue <= std_logic_vector(to_unsigned(v_data_read(5), rdValue'length));
			
			EscrReg <= v_data_read(4)(0);	
			
		end loop;
		assert false report "se ha terminado";
		wait;
	
	end process;
	
	
end architecture test;