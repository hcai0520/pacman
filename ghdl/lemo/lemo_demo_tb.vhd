library ieee;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- use -fsynopsys or --std=08 
library work;
use work.common.all;

--  Defines a testbench (without any ports)
entity lemo_demo_tb is
end lemo_demo_tb;
     
architecture behaviour of lemo_demo_tb is
  component lemo_demo is
    port (
      ACLK	                 : in std_logic;
      ARESETN	               : in std_logic;


      S_REGBUS_RB_RADDR	     : in  std_logic_vector(C_RB_ADDR_WIDTH-1 downto 0);
      S_REGBUS_RB_RDATA	     : out std_logic_vector(C_RB_DATA_WIDTH-1 downto 0);
      S_REGBUS_RB_RUPDATE    : in  std_logic;
      S_REGBUS_RB_RACK       : out std_logic;
      
      S_REGBUS_RB_WUPDATE    : in  std_logic;
      S_REGBUS_RB_WADDR	     : in  std_logic_vector(C_RB_ADDR_WIDTH-1 downto 0);
      S_REGBUS_RB_WDATA	     : in  std_logic_vector(C_RB_DATA_WIDTH-1 downto 0);
      S_REGBUS_RB_WACK       : out std_logic;
      DEBUG                  : out  std_logic_vector(C_RB_DATA_WIDTH-1 downto 0);


      LED_Select             : out std_logic;
      LEMO_Drive             : out std_logic
      );
  end component;

  
  signal count    : integer := 0;
  signal aclk     : std_logic;
  signal aresetn  : std_logic;

 --drive
  signal led    : std_logic;
  signal lemo   : std_logic;
  -- read signals:
  signal raddr   : std_logic_vector(C_RB_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal rupdate : std_logic := '0';
  signal rdata   : std_logic_vector(C_RB_DATA_WIDTH-1 downto 0);
  signal rack    : std_logic := '0';
  -- write signals:
  signal waddr   : std_logic_vector(C_RB_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal wupdate : std_logic := '0';
  signal wdata   : std_logic_vector(C_RB_DATA_WIDTH-1 downto 0) := (others => '0');
  signal wack    : std_logic := '0';  
begin
  uut: lemo_demo port map (
      ACLK           => aclk,
      ARESETN        => aresetn,      
      S_REGBUS_RB_RUPDATE => rupdate,
      S_REGBUS_RB_RADDR   => raddr,
      S_REGBUS_RB_RDATA   => rdata,
      S_REGBUS_RB_RACK    => rack,
      S_REGBUS_RB_WUPDATE => wupdate,
      S_REGBUS_RB_WADDR   => waddr,
      S_REGBUS_RB_WDATA   => wdata,
      S_REGBUS_RB_WACK    => wack,

      LED_Select => led,
      LEMO_Drive => lemo
      
      );
  
  aresetn_process : process
  begin
    aresetn <= '0';
    wait for 12 ns;
    aresetn <= '1';    
    wait;
  end process;
  
  aclk_process : process

  begin 
    count <= count + 1;   
    aclk <= '1';
    wait for 5 ns;
    aclk <= '0';
    wait for 5 ns;
  end process;

  rapid_read_process : process
  begin
    raddr   <= x"0000";
    rupdate <= '0';
    wait for 8 ns;
    wait for 30 ns;
    raddr   <= x"F110";
    rupdate <= '1';
    wait for 10 ns;
    raddr   <= x"F114";
    rupdate <= '1';
    wait for 10 ns;
    raddr   <= x"F108";
    rupdate <= '1';
    wait for 10 ns;
    raddr   <= x"0000";
    rupdate <= '0';
    wait for 30 ns;
    raddr   <= x"F100";
    rupdate <= '1';    
    wait for 10 ns;    
    raddr   <= x"F104";
    rupdate <= '1';    
    wait for 10 ns; 
  --  wait for 10 ns; 
    wait for 10 ns;
    raddr   <= x"F110";
    rupdate <= '1';
    wait for 10 ns;
    raddr   <= x"F114";
    rupdate <= '1';
    wait for 10 ns; 

    raddr   <= x"F10C";
    rupdate <= '1'; 
    wait;
  end process;

  rapid_write_process : process
  begin
    wait for 1 ns;
    --wait for 20 ns;
    waddr   <= x"F100";
    wdata   <= x"FEEDDADA";
    wupdate <= '1';
    wait for 10 ns;
    waddr   <= x"F104";
    wdata   <= x"00000003";
    wupdate <= '1';
    wait for 10 ns;
    waddr   <= x"F114";
    wdata   <= x"00000003";
    wupdate <= '1';
    wait for 10 ns;
    waddr   <= x"F110";
    wdata   <= x"0000000A";
    wupdate <= '1';
    wait for 10 ns;
    --expert write:
    waddr   <= x"F1E0";
    wdata   <= x"FFFFFFFF";
    wupdate <= '1';    
    wait for 10 ns;
    waddr   <= x"0000"; 
    wdata   <= x"00000000";
    wupdate <= '0';
    wait;
  end process;

  output_process : process
    variable l : line;
  begin
    --wait for 1 ns;
    if (count < 60) then
      wait for 10 ns;
    else
      wait;
    end if;
    write (l, String'("c: "));
    write (l, count, left, 4);
    --write (l, String'("aclk: "));
    --write (l, aclk);
    write (l, String'(" || ra: 0x"));
    hwrite (l, raddr);
    write (l, String'(" ru:"));
    write (l, rupdate);
    write (l, String'(" rd: 0x"));
    hwrite (l, rdata);
    write (l, String'(" rk:"));
    write (l, rack);
    write (l, String'(" || wa: 0x"));
    hwrite (l, waddr);
    write (l, String'(" wu:"));
    write (l, wupdate);
    write (l, String'(" wd: 0x"));
    hwrite (l, wdata);
    write (l, String'(" wk:"));
    write (l, wack);
    write (l, String'(" led:"));
    write (l, led);
    write (l, String'(" lemo:"));
    write (l, lemo);
    if (aresetn = '0') then
      write (l, String'(" (RESET)"));
    end if;
    writeline(output, l);
  end process;
  
end behaviour;
        