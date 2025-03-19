library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  generic (
    DATA_WIDTH  : integer  := 32;
    );
      
  port (
    CLK 	          : in std_logic;
    RESET   	      : in std_logic;
    Counter	        : out std_logic_vector(DATA_WIDTH-1 downto 0)    
      );
end entity counter;

architecture rtl of counter is
  signal clk      : std_logic;
  signal rst      : std_logic;

  signal counter   : std_logic_vector(DATA_WIDTH-1 downto 0);
 
  
   
begin
  clk <= CLK;
  rst <= RESET;
  
  process(clk)
  begin
    if(rising_edge(clk))  then
      counter <= counter +  x"1" ;
      if  (rst = '1') then
        counter <= (others => '0')
      end if;
    end if;
  end process;

  Counter <=  std_logic_vector(counter)     


end architecture rtl;

  