library ieee;
use ieee.std_logic_1164.all,ieee.numeric_std.all;

entity pal_sh is
port (
	clk  : in  std_logic;
	addr : in  std_logic_vector(8 downto 0);
	data : out std_logic_vector(7 downto 0)
);
end entity;

architecture prom of pal_sh is
	type rom is array(0 to  511) of std_logic_vector(7 downto 0);
	signal rom_data: rom := (
		X"0F",X"01",X"01",X"01",X"01",X"00",X"00",X"02",X"0F",X"00",X"00",X"02",X"02",X"00",X"00",X"00",
		X"0F",X"00",X"00",X"02",X"02",X"00",X"00",X"00",X"0F",X"01",X"01",X"01",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"01",X"01",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"00",X"02",X"02",X"01",X"00",X"00",
		X"0F",X"00",X"02",X"07",X"0F",X"0F",X"0F",X"0F",X"0F",X"02",X"07",X"00",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"00",X"00",X"02",X"02",X"01",X"01",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"06",X"05",X"05",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"00",X"01",X"01",X"00",X"00",X"00",
		X"0F",X"06",X"05",X"05",X"0F",X"0F",X"0F",X"0F",X"0F",X"06",X"05",X"05",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"02",X"02",X"01",X"01",X"00",X"00",X"00",X"0F",X"00",X"00",X"01",X"01",X"02",X"02",X"00",
		X"0F",X"00",X"06",X"06",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"06",X"06",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"00",X"00",X"01",X"01",X"02",X"02",X"02",X"0F",X"03",X"04",X"06",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"01",X"01",X"06",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"00",X"01",X"01",X"02",X"02",X"00",
		X"0F",X"01",X"01",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"01",X"01",X"02",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"00",X"00",X"01",X"01",X"02",X"02",X"00",X"0F",X"01",X"01",X"01",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"00",X"0F",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"01",X"01",X"01",X"02",X"00",X"00",X"00",
		X"0F",X"00",X"00",X"01",X"01",X"01",X"00",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"00",X"00",X"01",X"01",X"01",X"00",
		X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"00",X"01",X"01",X"01",X"01",X"00",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"00",X"00",X"01",X"01",X"00",X"00",
		X"0F",X"05",X"00",X"00",X"05",X"01",X"01",X"05",X"0F",X"05",X"00",X"00",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"00",X"0F",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"00",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"04",X"04",X"04",X"04",X"04",X"04",X"04",X"0F",X"04",X"04",X"04",X"04",X"04",X"04",X"04",
		X"0F",X"04",X"04",X"04",X"04",X"04",X"04",X"04",X"0F",X"04",X"04",X"04",X"04",X"04",X"04",X"04",
		X"0F",X"04",X"04",X"04",X"04",X"04",X"04",X"04",X"0F",X"04",X"04",X"04",X"04",X"04",X"04",X"04",
		X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"0F",X"02",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"06",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"02",X"0F",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"00",X"06",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"00",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"01",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"0F",X"06",X"06",X"0F",X"0F",X"0F",X"0F",X"0F",
		X"0F",X"01",X"00",X"02",X"0F",X"0F",X"0F",X"0F",X"0F",X"01",X"00",X"00",X"00",X"06",X"06",X"06",
		X"0F",X"01",X"01",X"07",X"06",X"00",X"00",X"00",X"0F",X"07",X"06",X"00",X"02",X"01",X"01",X"00",
		X"0F",X"01",X"01",X"02",X"0F",X"0F",X"0F",X"0F",X"0F",X"07",X"07",X"07",X"07",X"07",X"07",X"07");
begin
process(clk)
begin
	if rising_edge(clk) then
		data <= rom_data(to_integer(unsigned(addr)));
	end if;
end process;
end architecture;