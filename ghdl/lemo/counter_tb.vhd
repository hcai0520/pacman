library ieee;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- use -fsynopsys or --std=08 

--  Defines a testbench (without any ports)
entity counter_tb is
end counter_tb;
     
architecture behaviour of counter_tb is
  component counter is
    port (
      CLK          : in std_logic;
      RESET      : in std_logic;
      Counter	        : out std_logic_vector(31 downto 0)   
      );
  end component;
  signal aclk       : std_logic;
  signal reset      : std_logic;
  signal counter    : std_logic_vector(31 downto 0);
begin
  uut: counter port map (
      CLK          => clk,
      RESET       => reset,
      Counter        => counter
      );
  



  clock_process :process
  begin
     clk <= '0';
     wait for 10 ns;
     clk <= '1';
     wait for 10 ns;
  end process;
  
  output_process : process
    variable l : line;
  begin
    --wait for 1 ns;
    wait for 10 ns;
    write (l, String'("aclk: "));
    write (l, aclk);    
    write (l, String'(" Counter: "));
    hwrite (l, counter);
    if (aresetn = '0') then
      write (l, String'(" (RESET)"));
    end if;
    writeline(output, l);
  end process;
  
end behaviour;
        
