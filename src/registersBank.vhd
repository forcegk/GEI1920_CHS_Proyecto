library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;


entity filtro is
	Port (
		clk, reset : in std_logic;
		intro : in signed(7 downto 0);
		outro : out signed(7 downto 0);
		res : out signed(15 downto 0)
	);
end entity filtro;

architecture rtl of filtro is

	signal a: signed (7 downto 0);
	signal b: signed (7 downto 0);
	signal c: signed (7 downto 0);
	signal d: signed (7 downto 0);

begin

  sync:process(clk, reset)
  begin

	res <= a*b + c*d;

	if rising_edge(clk) then 
		if reset = '1' then 
			a <= "00000000";
			b <= "00000000";
			c <= "00000000";
			outro <= "00000000";
		else
			a <= intro;
			b <= a;
			c <= b;
			d <= c;
			outro <= c;

		end if;
	end if; 
  
  end process;

end architecture rtl;