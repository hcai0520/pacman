library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.common.all;

entity lemo_demo is
  generic (
    C_SCOPE       : integer  := 16#F#;  -- GLOBAL
    C_ROLE        : integer  := 16#1#;  -- DEBUGGING
    C_REG_SCR     : integer  := 16#0#;
    C_REG_CONF    : integer  := 16#4#;
    C_REG_STAT    : integer  := 16#8#;
    C_REG_COUNT   : integer  := 16#C#;
    C_REG_BRATE   : integer  := 16#10#;
    C_REG_BHOLD   : integer  := 16#14#;
    C_REG_LCOUNT   : integer  := 16#18#
    --C_VAL_ROA     : unsigned(31 downto 0)  := x"11111111";
    -- C_VAL_ROB     : unsigned(31 downto 0)  := x"22222222"
    );      
  port (
    ACLK	              : in std_logic;
    ARESETN	            : in std_logic;    

    S_REGBUS_RB_RUPDATE : in  std_logic;
    S_REGBUS_RB_RADDR	  : in  std_logic_vector(C_RB_ADDR_WIDTH-1 downto 0);
    S_REGBUS_RB_RDATA	  : out std_logic_vector(C_RB_DATA_WIDTH-1 downto 0);      
    S_REGBUS_RB_RACK    : out  std_logic;
    
    S_REGBUS_RB_WUPDATE : in  std_logic;
    S_REGBUS_RB_WADDR	  : in  std_logic_vector(C_RB_ADDR_WIDTH-1 downto 0);
    S_REGBUS_RB_WDATA	  : in  std_logic_vector(C_RB_DATA_WIDTH-1 downto 0);
    S_REGBUS_RB_WACK    : out  std_logic;
    
    LED_Drive           : out std_logic;
    LEMO                : in std_logic;

    DEBUG               : out  std_logic_vector(C_RB_DATA_WIDTH-1 downto 0)
    );
begin
  assert C_RB_ADDR_WIDTH >= 8;
end;

architecture behavioral of lemo_demo is
  signal clk      : std_logic;
  signal rst      : std_logic;

  signal rupdate  : std_logic;
  signal raddr    : std_logic_vector(C_RB_ADDR_WIDTH-1 downto 0);
  signal rdata    : std_logic_vector(C_RB_DATA_WIDTH-1 downto 0);
  signal rack     : std_logic := '0';
  
  signal wupdate  : std_logic;
  signal waddr    : std_logic_vector(C_RB_ADDR_WIDTH-1 downto 0);
  signal wdata    : std_logic_vector(C_RB_DATA_WIDTH-1 downto 0);
  signal wack     : std_logic := '0';

  signal led_enable     : std_logic :='0';
  signal led_switch     : std_logic :='0';
  signal lemo_enable    : std_logic :='0';
  --signal lemo_switch  : std_logic :='0';


  -- registers
  signal scr             : std_logic_vector(C_RB_DATA_WIDTH-1 downto 0) := (others => '0');

  signal stat            : std_logic_vector(C_RB_DATA_WIDTH-1 downto 0) := (others => '0');

  signal counter_led     : integer :=0;
  signal config          : std_logic_vector(C_RB_DATA_WIDTH-1 downto 0) := (others => '0');
  signal brate           : integer :=0;
  signal bhold           : integer :=0;
  signal counter_lemo    : integer :=0;
  signal meta            : std_logic;
  signal stat_old        : std_logic;
begin
  DEBUG <= scr;
  clk <= ACLK;
  rst <= not ARESETN;

  --outputs:
  S_REGBUS_RB_RDATA	 <= rdata;
  S_REGBUS_RB_RACK	 <= rack;
  S_REGBUS_RB_WACK	 <= wack;
  

  --inputs: (already registered at preceding stage)
  rupdate  <= S_REGBUS_RB_RUPDATE;
  raddr    <= S_REGBUS_RB_RADDR;
  wupdate  <= S_REGBUS_RB_WUPDATE;
  waddr    <= S_REGBUS_RB_WADDR;
  wdata    <= S_REGBUS_RB_WDATA;

  

  --mode 

  process(clk,rst) 
  begin
    if (rst = '1') then
      led_enable <= '0';
      lemo_enable <= '0';
    else
      if(rising_edge(clk)) then
        if (brate > 0 and bhold >0) then
          led_enable <= config(0);
        else
          led_enable <= '0';
        end if;    
        lemo_enable <= config(1);
      end if;
    end if;   
  end process;


 --Blink LED
  process(clk,rst)
  variable count   : integer :=0;
  begin
    if (rst = '1') then
      count := 0;
      counter_led <=0;
      led_switch <= '0';
    else
      if(rising_edge(clk)) then
        if (led_enable = '1') then        
                       
            if (count mod brate < bhold) then
              led_switch <= '1';
            else
              led_switch <= '0';
            end if;

            if (count = brate -1 ) then
              count := 0;
            else 
              count := count + 1;
            end if; 

            if (count = 0) then
              if (counter_led = 10000000 -1 ) then
                counter_led <=0;
              else  
                counter_led <= counter_led + 1;
              end if;  
            end if;
  
        end if;
      end if;  
    end if;
  end process;

  --lemo
  process(clk,rst)  
  begin
    if (rst = '1') then
      counter_lemo <=0;
      stat_old <= '0';
    else
      if(rising_edge(clk)) then
        if (lemo_enable = '1') then        
            meta    <= LEMO;
            stat(0) <= meta;
            stat_old   <= stat(0);
            
            if (stat_old = '0' and stat(0) = '1') then
              if (counter_lemo = 10000000 -1 ) then
                counter_lemo <=0;
              else
                counter_lemo <= counter_lemo + 1;
              end if;
            end if;  
        end if;
      end if;  
    end if;
  end process;






  -- Handle Read Request:
  process(clk,rst)
  variable scope   : integer;
  variable role    : integer;
  variable reg     : integer;
  begin  
    if (rst = '1') then
      rdata <= x"00000000";
      rack <= '0';
    else
      if (rising_edge(clk)) then
        if (rupdate='0') then
          --rdata is registered until the next update or reset.
          rack <= '0';
        else
          scope := to_integer(unsigned(raddr(15 downto 12)));
          role  := to_integer(unsigned(raddr(11 downto 8)));
          reg   := to_integer(unsigned(raddr(7 downto 0)));          
          if ((scope=C_SCOPE) and (role=C_ROLE)) then
            if (reg=C_REG_SCR) then
              rdata <= scr;
              rack  <= '1';
            elsif (reg=C_REG_CONF) then
              rdata <= config;
              rack  <= '1'; 
            elsif (reg=C_REG_STAT) then
              rdata <= stat;
              rack  <= '1';  
            elsif (reg=C_REG_COUNT) then
                rdata <= std_logic_vector(to_signed(counter_led + 1 ,32));
              rack  <= '1'; 
            elsif (reg=C_REG_LCOUNT) then
                rdata <= std_logic_vector(to_signed(counter_lemo + 1 ,32));
              rack  <= '1';      
            elsif (reg=C_REG_BRATE) then
              rdata <= std_logic_vector(to_signed(brate,32));
      
              rack  <= '1';
            elsif (reg=C_REG_BHOLD) then
              rdata <= std_logic_vector(to_signed(bhold,32));
              rack  <= '1'; 
            else
              -- this is an error, invalid register
              rdata <= x"EEEEEEEE";
              rack  <= '0';
            end if;
          else
            -- this is not an error, just a request outside our scope/role
            rdata <= x"00000000";
            rack  <= '0';
          end if;
        end if;
      end if;
    end if; 
  end process;

  -- Handle Write Request:
  process(clk,rst)
  variable scope   : integer;
  variable role    : integer;
  variable reg     : integer;
  begin  
    if (rst = '1') then
      scr <= x"00000000";
--      config <= x"00000000";
      brate <= 0;
      bhold <= 0;
    else
      if (rising_edge(clk)) then
        if (wupdate='0') then
          wack  <= '0';          
        else
          scope := to_integer(unsigned(waddr(15 downto 12)));
          role  := to_integer(unsigned(waddr(11 downto 8)));
          reg   := to_integer(unsigned(waddr(7 downto 0)));              
          if ((scope=C_SCOPE) and (role=C_ROLE)) then
            if (reg=C_REG_SCR) then
              scr<= wdata;
              wack  <= '1';
            elsif (reg=C_REG_CONF) then
              config<= wdata;
              wack  <= '1';
            elsif (reg=C_REG_BRATE) then
              brate<= to_integer(signed(wdata));
              wack  <= '1';
            elsif (reg=C_REG_BHOLD) then
              bhold<= to_integer(signed(wdata));
              wack  <= '1';
            else
                -- this is an error, invalid register
              wack  <= '0';
            end if;  
          
          else
            -- this is not an error, just a request outside our scope/role
            wack  <= '0';
          end if ;
        end if;
      end if;
    end if;   
  end process;

  LED_Drive <=led_enable and led_switch;
end; 


