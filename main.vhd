LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY main IS
   PORT(
      clk           : IN      STD_LOGIC;
      led0          : BUFFER  STD_LOGIC;
      led1          : BUFFER  STD_LOGIC;
      led2          : BUFFER  STD_LOGIC;
      led3          : BUFFER  STD_LOGIC;
      led4          : BUFFER  STD_LOGIC;
      led5          : BUFFER  STD_LOGIC;
      led6          : BUFFER  STD_LOGIC;
      led7          : BUFFER  STD_LOGIC;
      
      CLK1M535      : IN        STD_LOGIC;
      
      CLK25M        : IN        STD_LOGIC;
      CLK50M        : IN        STD_LOGIC;
      CLK100M       : IN        STD_LOGIC;
      CLK125M       : IN        STD_LOGIC;
      CLK200M       : IN        STD_LOGIC;
      
      HDMI0_DATA    : OUT       STD_LOGIC_VECTOR(4 DOWNTO 0);
      HDMI1_DATA    : OUT       STD_LOGIC_VECTOR(4 DOWNTO 0);
      HDMI2_DATA    : OUT       STD_LOGIC_VECTOR(4 DOWNTO 0);
      HDMICLK_DATA  : OUT       STD_LOGIC_VECTOR(4 DOWNTO 0);
      
      ADDR          : IN        STD_LOGIC_VECTOR(15 DOWNTO 0);
      nCS           : IN        STD_LOGIC;
      nRE           : IN        STD_LOGIC;
      nWE           : IN        STD_LOGIC;
      nINT          : OUT       STD_LOGIC;
      nREADY        : OUT       STD_LOGIC;
     
      DATA0_IN      : IN        STD_LOGIC;
      DATA0_OUT     : OUT       STD_LOGIC;
      DATA0_OE      : OUT       STD_LOGIC;
      
      DATA1_IN      : IN        STD_LOGIC;
      DATA1_OUT     : OUT       STD_LOGIC;
      DATA1_OE      : OUT       STD_LOGIC;
      
      DATA2_IN      : IN        STD_LOGIC;
      DATA2_OUT     : OUT       STD_LOGIC;
      DATA2_OE      : OUT       STD_LOGIC;
      
      DATA3_IN      : IN        STD_LOGIC;
      DATA3_OUT     : OUT       STD_LOGIC;
      DATA3_OE      : OUT       STD_LOGIC;
      
      DATA4_IN      : IN        STD_LOGIC;
      DATA4_OUT     : OUT       STD_LOGIC;
      DATA4_OE      : OUT       STD_LOGIC;
      
      DATA5_IN      : IN        STD_LOGIC;
      DATA5_OUT     : OUT       STD_LOGIC;
      DATA5_OE      : OUT       STD_LOGIC;
      
      DATA6_IN      : IN        STD_LOGIC;
      DATA6_OUT     : OUT       STD_LOGIC;
      DATA6_OE      : OUT       STD_LOGIC;
      
      DATA7_IN      : IN        STD_LOGIC;
      DATA7_OUT     : OUT       STD_LOGIC;
      DATA7_OE      : OUT       STD_LOGIC;
      
      DEBUG_OUT     : OUT       STD_LOGIC_VECTOR(7 DOWNTO 0);
      
      LRCLK         : OUT       STD_LOGIC;
      MCLK          : OUT       STD_LOGIC;
      SCLK          : OUT       STD_LOGIC;
      SDATA         : OUT       STD_LOGIC
      );
END main;

ARCHITECTURE behavior OF main IS

COMPONENT LFSR16 IS
   PORT(
        clk                     : IN  STD_LOGIC;
        output                  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END COMPONENT LFSR16;

COMPONENT debouncer IS
   PORT(
        CLK             : IN  STD_LOGIC;
        INP             : IN  STD_LOGIC;
        OUTP            : OUT STD_LOGIC
      );
END COMPONENT debouncer;

COMPONENT tmds_encoder IS
  PORT(  
    clk      : IN  STD_LOGIC;                     --system clock
    disp_ena : IN  STD_LOGIC;                     --display enable
    control  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);  --C1, C0
    d_in     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit data input
    q_out    : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)); --10-bit encoder output
END COMPONENT tmds_encoder;

--palette memories, 256 bytes, each is separate due to having different memory initialization files.

COMPONENT ColorRAMRed IS
  PORT(  
    wdataA   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit data input
    addrA    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit address input
    addrB    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit address input
    clkA     : IN  STD_LOGIC;                     --memory clock
    weA      : IN  STD_LOGIC;                     --write enable
    clkB     : IN  STD_LOGIC;                     --memory clock
    rdataA   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit data output
    rdataB   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --8-bit data output
END COMPONENT ColorRAMRed;

COMPONENT ColorRAMGreen IS
  PORT(  
    wdataA   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit data input
    addrA    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit address input
    addrB    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit address input
    clkA     : IN  STD_LOGIC;                     --memory clock
    weA      : IN  STD_LOGIC;                     --write enable
    clkB     : IN  STD_LOGIC;                     --memory clock
    rdataA   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit data output
    rdataB   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --8-bit data output
END COMPONENT ColorRAMGreen;

COMPONENT ColorRAMBlue IS
  PORT(  
    wdataA   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit data input
    addrA    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit address input
    addrB    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit address input
    clkA     : IN  STD_LOGIC;                     --memory clock
    weA      : IN  STD_LOGIC;                     --write enable
    clkB     : IN  STD_LOGIC;                     --memory clock
    rdataA   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  --8-bit data output
    rdataB   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --8-bit data output
END COMPONENT ColorRAMBlue;

--127 x 8 memory (used for sprite collision output)
COMPONENT mem128b IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 127;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 127;
        wdataB      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weB         : IN STD_LOGIC
        );
END COMPONENT mem128b;

--2K memory, pre-loaded with font data, used for font
COMPONENT mem2Kfonts IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 2047;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 2047;
        rdataB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END COMPONENT mem2Kfonts;

--1Kx8 read/write port a, 127x64 read-only port b (used for sprite data)
COMPONENT mem1K1to8 IS
   PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 1023;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 127;
        rdataB      : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
        );
END COMPONENT mem1K1to8;

--512K dial-port memory for audio data
COMPONENT audioMem IS
    PORT (
        clk         : IN STD_LOGIC;
            
        addrA       : IN integer range 0 to 511;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
            
        addrB       : IN integer range 0 to 511;
        wdataB      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weB         : IN STD_LOGIC
    );
END COMPONENT audioMem;

--256x16 sine table ROM
COMPONENT sineTableRom is
    PORT (
        addr_a : in std_logic_vector(7 downto 0);
        rdata_a : out std_logic_vector(15 downto 0);
        rdata_b : out std_logic_vector(15 downto 0);
        addr_b : in std_logic_vector(7 downto 0);
        clk : in std_logic
        --clke : in std_logic
        );
END COMPONENT;

--512x16 inverse and square root table ROM
COMPONENT invSqrtTableRom is
    PORT (
        addr_a : in std_logic_vector(8 downto 0);
        rdata_a : out std_logic_vector(15 downto 0);
        rdata_b : out std_logic_vector(15 downto 0);
        addr_b : in std_logic_vector(8 downto 0);
        clk : in std_logic
        );
END COMPONENT;

--512x4b memory, used for the collision buffers
COMPONENT mem512x4bit IS
    PORT (
        we_a        : IN STD_LOGIC;
        we_b        : IN STD_LOGIC;
        
        addr_a      : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        rdata_a     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        wdata_a     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        addr_b      : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        rdata_b     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        wdata_b     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        clk_a       : IN STD_LOGIC;
        clk_b       : IN STD_LOGIC;
        clke_b      : IN STD_LOGIC;
        clke_a      : IN STD_LOGIC
    );
END COMPONENT mem512x4bit;

--32b memory that holds the latest set of audio raw values. TODO: make these registers instead of a block memory
COMPONENT audioRawMem IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 31;
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        addrB       : IN integer range 0 to 31;
        wdataB      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weB         : IN STD_LOGIC
        );
END COMPONENT audioRawMem;

--1K for holding sample table for audio
COMPONENT wavetableMem is
    PORT (
        we_a : in std_logic;
        addr_a : in std_logic_vector(9 downto 0);
        wdata_a : in std_logic_vector(7 downto 0);
        rdata_a : out std_logic_vector(7 downto 0);
        rdata_b : out std_logic_vector(7 downto 0);
        addr_b : in std_logic_vector(9 downto 0);
        wdata_b : in std_logic_vector(7 downto 0);
        clk : in std_logic
        --clke : in std_logic
        );
    END COMPONENT;
    
--2K memory for holding copper instruction list
COMPONENT copperMem IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 2047;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 1023;
        rdataB      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END COMPONENT copperMem;

COMPONENT mem8K1to4 IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 8191;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 2047;
        rdataB      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
END COMPONENT mem8K1to4;

COMPONENT mem8K IS
    PORT(
        clk         : IN STD_LOGIC;
        
        addrA       : IN integer range 0 to 8191;
        wdataA      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rdataA      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        weA         : IN STD_LOGIC;
        
        addrB       : IN integer range 0 to 8191;
        rdataB      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END COMPONENT mem8K;

--master screen timing block
COMPONENT timing_control IS
   PORT(
      clk               : IN  STD_LOGIC;
      xpos              : OUT integer range 0 to 1023;
      ypos              : OUT integer range 0 to 1023;
      
      screen_area       : OUT STD_LOGIC;
      hsync             : BUFFER STD_LOGIC;
      vsync             : OUT STD_LOGIC;
      
      line_reset        : OUT STD_LOGIC;
      screen_reset      : OUT STD_LOGIC;
      engine_run        : OUT STD_LOGIC;
      buffer_swap       : OUT STD_LOGIC;
      line_to_draw      : OUT integer range 0 to 239;
      
      screen_state      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
END COMPONENT timing_control;

--audio generator
COMPONENT audiogen IS
   PORT(
        CLK25                   : IN  STD_LOGIC;
        CLK100                  : IN  STD_LOGIC;
        MCLK                    : IN  STD_LOGIC;
        AUDIO_DAT_ADDRESS_OUT   : OUT integer range 0 to 511;
        AUDIO_DAT_DATA_IN       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        AUDIO_DAT_DATA_OUT      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        AUDIO_DAT_WRITE_OUT     : OUT STD_LOGIC;
        RNG16                   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        SINE_TABLE_ADDRESS_OUT  : OUT integer range 0 to 255;
        SINE_TABLE_DATA_IN      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        INV_TABLE_ADDRESS_OUT   : OUT integer range 0 to 255;
        INV_TABLE_DATA_IN       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        SAMPLE_TABLE_ADDRESS_OUT: OUT integer range 0 to 1023;
        SAMPLE_TABLE_DATA_IN    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        RAW_VALUE_ADDRESS_OUT   : OUT integer range 0 to 31;
        RAW_VALUE_DATA_IN       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        RAW_VALUE_DATA_OUT      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        RAW_VALUE_WRITE_OUT     : OUT STD_LOGIC;
        --CPU_ADDR                : IN  integer range 0 to 31;
        --CPU_RDATA               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        masterVolumeIn          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        loadOkPulse             : OUT STD_LOGIC;
        sclk                    : OUT STD_LOGIC;
        lrclk                   : OUT STD_LOGIC;
        sdata                   : OUT STD_LOGIC;
        debug                   : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
        );
END COMPONENT audiogen;

--cpu read/write timing
COMPONENT cpu_interface IS
    PORT(
      CLK               : IN  STD_LOGIC;
      CS                : IN  STD_LOGIC;
      RE                : IN  STD_LOGIC;
      WE                : IN  STD_LOGIC;
      
      WRITE_STROBE      : OUT STD_LOGIC;
      TRISTATE_OUT      : OUT STD_LOGIC;
      READY             : OUT STD_LOGIC;
      LATCH_ADDRESS     : OUT STD_LOGIC;
      LATCH_DATA_IN     : OUT STD_LOGIC
    );
END COMPONENT cpu_interface;

--main address decoder
COMPONENT address_decode IS
    PORT(
        ADDRESS_IN          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);

        SEL_SYS_REG         : OUT STD_LOGIC;
        SEL_AUDIO_RAW       : OUT STD_LOGIC;
        SEL_AFFINE          : OUT STD_LOGIC;
        SEL_PALETTE         : OUT STD_LOGIC;
        SEL_COL_FLAGS       : OUT STD_LOGIC;
        SEL_PAL_RED         : OUT STD_LOGIC;
        SEL_PAL_GREEN       : OUT STD_LOGIC;
        SEL_PAL_BLUE        : OUT STD_LOGIC;
        SEL_SPRITE_DATA     : OUT STD_LOGIC;
        SEL_AUDIO_DATA      : OUT STD_LOGIC;
        SEL_SAMPLE_TABLE    : OUT STD_LOGIC;
        SEL_COPPER_LIST     : OUT STD_LOGIC;
        SEL_FONT            : OUT STD_LOGIC;
        SEL_BANK_1          : OUT STD_LOGIC;
        SEL_BANK_2          : OUT STD_LOGIC;
        SEL_BANK_3          : OUT STD_LOGIC;
        SEL_BANK_4          : OUT STD_LOGIC;
        SEL_BANK_5          : OUT STD_LOGIC;
        SEL_BANK_6          : OUT STD_LOGIC;
        SEL_BANK_7          : OUT STD_LOGIC
    );
END COMPONENT address_decode;

--steering logic to connect engines to banks
COMPONENT bankEngineAttach IS
   PORT(
        clk                       : IN  STD_LOGIC;
        
        bank0AddressSelect        : IN  integer range 0 to 2;
        bank1AddressSelect        : IN  integer range 0 to 2;
        bank2AddressSelect        : IN  integer range 0 to 3;
        bank3AddressSelect        : IN  integer range 0 to 2;
        bank4AddressSelect        : IN  integer range 0 to 3;
        bank5AddressSelect        : IN  integer range 0 to 1;
        bank6AddressSelect        : IN  integer range 0 to 2;
        bank7AddressSelect        : IN  integer range 0 to 2;
        bank8AddressSelect        : IN  integer range 0 to 2;
        bank9AddressSelect        : IN  integer range 0 to 2;
        
        bank_0_read_address       : OUT integer range 0 to 2047;
        bank_0_read_data          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        bank_1_read_address       : OUT integer range 0 to 2047;
        bank_1_read_data          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        bank_2_read_address       : OUT integer range 0 to 2047;
        bank_2_read_data          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        bank_3_read_address       : OUT integer range 0 to 8192;
        bank_3_read_data          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        bank_4_read_address       : OUT integer range 0 to 8192;
        bank_4_read_data          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        bank_5_read_address       : OUT integer range 0 to 8192;
        bank_5_read_data          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        bank_6_read_address       : OUT integer range 0 to 2047;
        bank_6_read_data          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        bank_7_read_address       : OUT integer range 0 to 8192;
        bank_7_read_data          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        bank_8_read_address       : OUT integer range 0 to 2047;
        bank_8_read_data          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        bank_9_read_address       : OUT integer range 0 to 8192;
        bank_9_read_data          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        
        text_map_read_address     : IN  integer range 0 to 2047;
        text_map_read_data        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        tile_map_1_read_address   : IN  integer range 0 to 2047;
        tile_map_1_read_data      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        tile_gfx_1_read_address   : IN  integer range 0 to 8191;
        tile_gfx_1_read_data      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        tile_map_2_read_address   : IN  integer range 0 to 2047;
        tile_map_2_read_data      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        tile_gfx_2_read_address   : IN  integer range 0 to 8191;
        tile_gfx_2_read_data      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        sprite_gfx_read_address   : IN  integer range 0 to 65535;
        sprite_gfx_read_data      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        affine_map_read_address   : IN  integer range 0 to 16383;
        affine_map_read_data      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        affine_gfx_read_address   : IN  integer range 0 to 16383;
        affine_gfx_read_data      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        bitmap_read_address       : IN  integer range 0 to 131071;
        bitmap_read_data          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END COMPONENT bankEngineAttach;


--main data output mux
COMPONENT registeredmux20x8 IS
   PORT(
      CLK             : IN  STD_LOGIC;
      S0              : IN  STD_LOGIC;
      Q0              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S1              : IN  STD_LOGIC;
      Q1              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S2              : IN  STD_LOGIC;
      Q2              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S3              : IN  STD_LOGIC;
      Q3              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S4              : IN  STD_LOGIC;
      Q4              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S5              : IN  STD_LOGIC;
      Q5              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S6              : IN  STD_LOGIC;
      Q6              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S7              : IN  STD_LOGIC;
      Q7              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S8              : IN  STD_LOGIC;
      Q8              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S9              : IN  STD_LOGIC;
      Q9              : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S10             : IN  STD_LOGIC;
      Q10             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S11             : IN  STD_LOGIC;
      Q11             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S12             : IN  STD_LOGIC;
      Q12             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S13             : IN  STD_LOGIC;
      Q13             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S14             : IN  STD_LOGIC;
      Q14             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S15             : IN  STD_LOGIC;
      Q15             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S16             : IN  STD_LOGIC;
      Q16             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S17             : IN  STD_LOGIC;
      Q17             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S18             : IN  STD_LOGIC;
      Q18             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      S19             : IN  STD_LOGIC;
      Q19             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      D               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
END COMPONENT registeredmux20x8;

--system registers
COMPONENT system_registers IS
    PORT(
        CLK                 : IN  STD_LOGIC;
        ADDRESS_IN          : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
        DATA_IN             : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        DATA_OUT            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        WRITE_STROBE        : IN  STD_LOGIC;
        COPPER_ADDRESS_IN   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        COPPER_DATA_IN      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        COPPER_DATA_OUT     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        COPPER_WRITE_STROBE : IN  STD_LOGIC;
        COPPER_BYTE_FLAGS   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        FRAME_COUNT         : IN integer range 0 to 65535;
        INTERRUPT_OUT       : OUT STD_LOGIC;
        TEXT_WIDTH          : OUT integer range 0 to 7;
        TEXT_Y_SCROLL       : OUT integer range 0 to 255;
        TILE_Y_SCROLL_1     : OUT integer range 0 to 255;  
        TILE_X_SCROLL_1     : OUT integer range 0 to 511;
        TILE_Y_SCROLL_2     : OUT integer range 0 to 255;  
        TILE_X_SCROLL_2     : OUT integer range 0 to 511;
        SPRITE_SCROLL_Y     : OUT integer range 0 to 255;  
        SPRITE_SCROLL_X     : OUT integer range 0 to 511;
        LINE_ACTIVE         : IN  integer range 0 to 239;
        X_ACTIVE            : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        GRAPHICS_MODE       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        AUDIO_VOLUME        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLLISION_FLAGS     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        SCREEN_STATE        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        RNG                 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        AUDIOLOADPULSE      : IN  STD_LOGIC;
        AFFINE_TRANS_COLOR  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        BITMAP_TRANS_COLOR  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        AFFINE_TRANS_ENABLE : OUT STD_LOGIC;
        AFFINE_LAYER        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        AFFINE_EDGE_REPEAT  : OUT STD_LOGIC;
        BITMAP_TRANS_ENABLE : OUT STD_LOGIC;
        BITMAP_LAYER        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        MEMORY_REMAP        : OUT integer range 0 to 2;
        COPPER_ENABLE       : OUT STD_LOGIC;
        COPPER_RESET        : OUT STD_LOGIC;
        BLANK_R             : OUT integer range 0 to 255;
        BLANK_G             : OUT integer range 0 to 255;
        BLANK_B             : OUT integer range 0 to 255;
        EFFECT_R            : OUT integer range 0 to 255;
        EFFECT_G            : OUT integer range 0 to 255;
        EFFECT_B            : OUT integer range 0 to 255;
        WINDOW_START_1      : OUT integer range 0 to 511;
        WINDOW_STOP_1       : OUT integer range 0 to 511;
        WINDOW_START_2      : OUT integer range 0 to 511;
        WINDOW_STOP_2       : OUT integer range 0 to 511;
        EFFECT_CONTROL_BITS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        COPPER_INTERRUPT    : IN  STD_LOGIC;
        COPPER_ADDRESS      : IN integer range 0 to 1023
    );
END COMPONENT system_registers;

COMPONENT engineBufferAttach IS
   PORT(
        bufferSelect           : IN  integer range 0 to 1;
        
        sel_0_write_address     : IN  integer range 0 to 511;
        sel_0_write_strobe      : IN  STD_LOGIC;
        sel_0_write_data        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        sel_1_write_address     : IN  integer range 0 to 511;
        sel_1_write_strobe      : IN  STD_LOGIC;
        sel_1_write_data        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        buffer_write_address    : OUT integer range 0 to 511;
        buffer_write_strobe     : OUT STD_LOGIC;
        buffer_write_data       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
   );
END COMPONENT engineBufferAttach;

COMPONENT engineBufferAttach3 IS
   PORT(
        bufferSelect           : IN  integer range 0 to 2;
        
        sel_0_write_address     : IN  integer range 0 to 511;
        sel_0_write_strobe      : IN  STD_LOGIC;
        sel_0_write_data        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        sel_1_write_address     : IN  integer range 0 to 511;
        sel_1_write_strobe      : IN  STD_LOGIC;
        sel_1_write_data        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        sel_2_write_address     : IN  integer range 0 to 511;
        sel_2_write_strobe      : IN  STD_LOGIC;
        sel_2_write_data        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        buffer_write_address    : OUT integer range 0 to 511;
        buffer_write_strobe     : OUT STD_LOGIC;
        buffer_write_data       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
   );
END COMPONENT engineBufferAttach3;

--line buffers with a/b swap and pixel priority decider
COMPONENT line_buffers IS
    PORT(
        CLKW                : IN  STD_LOGIC;
        CLKR                : IN  STD_LOGIC;
        SWAP_BUFFERS        : IN  STD_LOGIC;
        
        LAYER_ENABLE        : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        WRITE_ADDRESS_0     : IN  integer range 0 to 511;
        WE_0                : IN  STD_LOGIC;
        DATA_IN_0           : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        WRITE_ADDRESS_1     : IN  integer range 0 to 511;
        WE_1                : IN  STD_LOGIC;
        DATA_IN_1           : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        WRITE_ADDRESS_2     : IN  integer range 0 to 511;
        WE_2                : IN  STD_LOGIC;
        DATA_IN_2           : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        WRITE_ADDRESS_3     : IN  integer range 0 to 511;
        WE_3                : IN  STD_LOGIC;
        DATA_IN_3           : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        READ_ADDRESS        : IN  integer range 0 to 511;
        READ_DATA           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END COMPONENT line_buffers;

--text engine
COMPONENT text_engine IS
    PORT(
        CLK                     : IN  STD_LOGIC;
        RESET_LINE              : IN  STD_LOGIC;
        RESET_SCREEN            : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        LINE_TO_DRAW            : IN  integer range 0 to 239;
        
        DONE                    : OUT STD_LOGIC;
        
        TEXT_WIDTH              : IN  integer range 0 to 7;
        TEXT_Y_SCROLL           : IN  integer range 0 to 255;
        ANIM_CYCLE              : IN  integer range 0 to 65535;
        
        MAP_READ_ADDRESS        : OUT integer range 0 to 2047;
        MAP_DATA_IN             : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        FONT_READ_ADDRESS       : OUT integer range 0 to 2047;
        FONT_DATA_IN            : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 511;
        BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE     : OUT STD_LOGIC
    );
END COMPONENT text_engine;

--tile engine
COMPONENT tile_engine IS
    PORT(
        CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        RESET_LINE              : IN  STD_LOGIC;
        RESET_SCREEN            : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        LINE_TO_DRAW            : IN  integer range 0 to 239;
        DONE                    : OUT STD_LOGIC;
        
        TILE_Y_SCROLL           : IN  integer range 0 to 255;
        TILE_X_SCROLL           : IN  integer range 0 to 511;
        ANIM_CYCLE              : IN  integer range 0 to 65535;
        
        MAP_READ_ADDRESS        : OUT integer range 0 to 2047;
        MAP_DATA_IN             : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        TILE_GFX_READ_ADDRESS   : OUT integer range 0 to 8191;
        TILE_GFX_DATA_IN        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 511;
        BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE     : OUT STD_LOGIC;
        
        COLLISION_WRITE_ADDRESS : OUT integer range 0 to 511;
        COLLISION_WRITE_DATA    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        COLLISION_WRITE_STROBE  : OUT STD_LOGIC
    );
END COMPONENT tile_engine;
    
--sprite engine
COMPONENT sprite_engine IS
    PORT(
        CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        RESET_LINE              : IN  STD_LOGIC;
        RESET_SCREEN            : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        LINE_TO_DRAW            : IN  integer range 0 to 239;
        DONE                    : OUT STD_LOGIC;
        
        SPRITE_SCROLL_X         : IN  integer range 0 to 511;
        SPRITE_SCROLL_Y         : IN  integer range 0 to 255;
        
        ANIM_CYCLE              : IN  integer range 0 to 65535;
        
        SPRITE_READ_ADDRESS     : OUT integer range 0 to 127;
        SPRITE_DATA_IN          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
        
        SPRITE_GFX_READ_ADDRESS : OUT integer range 0 to 65535;
        SPRITE_GFX_DATA_IN      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        COLLISION_WRITE_ADDRESS : OUT integer range 0 to 127;
        COLLISION_WRITE_STROBE  : OUT STD_LOGIC;
        COLLISION_WRITE_DATA    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLLISION_READ_DATA     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        COLLISION_INTERRUPTS    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 511;
        BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE     : OUT STD_LOGIC;
        
        DEBUG_OUT               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        COL_BUFF_ADDRESS        : OUT integer range 0 to 511;
        COL_BUFF_WRITE_DATA     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COL_BUFF_READ_DATA      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        COL_BUFF_WRITE_STROBE   : OUT STD_LOGIC;
        
        COL_BUFF_READY          : IN  STD_LOGIC
    );
END COMPONENT sprite_engine;

--affine engine

COMPONENT affine_engine IS
    PORT(
        CLK25M                      : IN  STD_LOGIC;
        CLK100M                     : IN  STD_LOGIC;
        RESET_LINE                  : IN  STD_LOGIC;
        RESET_SCREEN                : IN  STD_LOGIC;
        RUN                         : IN  STD_LOGIC;
        LINE_TO_DRAW                : IN  integer range 0 to 239;
        DONE                        : OUT STD_LOGIC;
        
        AFFINE_TRANS_FLAG           : IN  STD_LOGIC;
        AFFINE_TRANS_COLOR          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        AFFINE_LAYER                : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        AFFINE_EDGE_REPEAT          : IN  STD_LOGIC;
         
        CPU_ADDR                    : IN  integer range 0 to 15;
        CPU_WDATA                   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        CPU_RDATA                   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        CPU_WE                      : IN  STD_LOGIC;
        
        COPPER_ADDRESS_IN           : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        COPPER_DATA_IN              : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        COPPER_DATA_OUT             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        COPPER_WRITE_STROBE         : IN  STD_LOGIC;
        COPPER_BYTE_FLAGS           : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        AFFINE_MAP_READ_ADDRESS     : OUT integer range 0 to 16383;
        AFFINE_MAP_READ_DATA        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        AFFINE_GFX_READ_ADDRESS     : OUT integer range 0 to 16383;
        AFFINE_GFX_READ_DATA        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        BUFFER_WRITE_ADDRESS        : OUT integer range 0 to 319;
        BUFFER_WRITE_DATA           : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE         : OUT STD_LOGIC
    );
END COMPONENT affine_engine;


--bitmap engine

COMPONENT bitmap_engine IS
    PORT(
        CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        RESET_LINE              : IN  STD_LOGIC;
        RESET_SCREEN            : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        LINE_TO_DRAW            : IN  integer range 0 to 239;
        DONE                    : OUT STD_LOGIC;
        BITMAP_MODE             : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        BITMAP_TRANS_FLAG       : IN  STD_LOGIC;
        BITMAP_TRANS_COLOR      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        BITMAP_LAYER            : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        CPU_ADDR                : IN  integer range 0 to 15;
        CPU_WDATA               : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        CPU_RDATA               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        CPU_WE                  : IN  STD_LOGIC;
        COPPER_ADDRESS_IN       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        COPPER_DATA_IN          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        COPPER_DATA_OUT         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        COPPER_WRITE_STROBE     : IN  STD_LOGIC;
        COPPER_BYTE_FLAGS       : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        BITMAP_READ_ADDRESS     : OUT integer range 0 to 131071;
        BITMAP_READ_DATA        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 319;
        BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE     : OUT STD_LOGIC
    );
END COMPONENT bitmap_engine;

--graphics mode decode logic
COMPONENT mode_decode IS
   PORT(
        clk                     : IN  STD_LOGIC;
        enginesRun              : IN  STD_LOGIC;
        mode                    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
      
        enableTextEngine        : OUT STD_LOGIC;
        enableTileAEngine       : OUT STD_LOGIC;
        enableTileBEngine       : OUT STD_LOGIC;
        enableSpriteEngine      : OUT STD_LOGIC;
        enableAffineEngine      : OUT STD_LOGIC;
        enableBitmapEngine      : OUT STD_LOGIC;
        
        bitmapMode              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        buffer0Select           : OUT integer range 0 to 1; --Text, or Tile B
        buffer1Select           : OUT integer range 0 to 1; --Tile A, or Affine
        buffer2Select           : OUT integer range 0 to 2; --Tile B, Sprite, or Tile A
        buffer3Select           : OUT integer range 0 to 2; --Bitmap, Sprite, or Tile B
        
        --engine to bank address steering
        bank0AddressSelect      : OUT integer range 0 to 2; --address from Test, Bitmap, Sprite graphics
        bank1AddressSelect      : OUT integer range 0 to 2; --address from Tile A map, Affine Map, Bitmap
        bank2AddressSelect      : OUT integer range 0 to 3; --address from Tile B map, Affine Map, Bitmap, Sprite graphics
        bank3AddressSelect      : OUT integer range 0 to 2; --address from Tile A graphics, Affine graphics, Bitmap
        bank4AddressSelect      : OUT integer range 0 to 3; --address from Tile B graphics, Affine graphics, Bitmap, Sprite graphics
        bank5AddressSelect      : OUT integer range 0 to 1; --address from Sprite graphics, Bitmap
        bank6AddressSelect      : OUT integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile B Map
        bank7AddressSelect      : OUT integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile B Graphics
        bank8AddressSelect      : OUT integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile A Map
        bank9AddressSelect      : OUT integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile A Graphics
        
        LAYER_ENABLE            : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
END COMPONENT mode_decode;

--graphics coprocessor
COMPONENT copper IS
    PORT(
        --CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        COPPER_RESET            : IN  STD_LOGIC;
        COPPER_RUN              : IN  STD_LOGIC;
        
        CONDITIONS              : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
        ACTIVE_LINE             : IN  integer range 0 to 239;
        
        ADDRESS_OUT             : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        DATA_OUT                : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        DATA_IN                 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        WRITE_STROBE            : OUT STD_LOGIC;
        BYTE_FLAGS              : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        COPPER_ADDRESS_OUT      : OUT integer range 0 to 1023;
        COPPER_INST_IN          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        LOOKUP_ADDRESS_OUT      : OUT integer range 0 to 511;
        INVSQRT_DATA_IN         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        SINCOS_DATA_IN          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        COPPER_INTERRUPT_OUT     : OUT STD_LOGIC
    );
END COMPONENT copper;

COMPONENT windowed_effects is
    PORT(
        CLK                 : IN  STD_LOGIC;
        CONTROL_BITS        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        R_BLANK_VALUE       : IN integer range 0 to 255;
        G_BLANK_VALUE       : IN integer range 0 to 255;
        B_BLANK_VALUE       : IN integer range 0 to 255;
        R_VALUE             : IN integer range 0 to 255;
        G_VALUE             : IN integer range 0 to 255;
        B_VALUE             : IN integer range 0 to 255;
        WINDOW_START_0      : IN integer range 0 to 511;
        WINDOW_STOP_0       : IN integer range 0 to 511;
        WINDOW_START_1      : IN integer range 0 to 511;
        WINDOW_STOP_1       : IN integer range 0 to 511;
        X_ADDRESS           : IN integer range 0 to 511;
        COLOR_IN_RED_BITS   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_IN_GREEN_BITS : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_IN_BLUE_BITS  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_OUT_RED_BITS  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_OUT_GREEN_BITS: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLOR_OUT_BLUE_BITS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END COMPONENT windowed_effects;

SIGNAL LFSRrng                          : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL tempX                            : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL bufferReadAddress                : integer range 0 to 511; 
SIGNAL bufferReadAddressDelayed         : integer range 0 to 511; 

SIGNAL xaddress                         : integer range 0 to 1023;  
SIGNAL yaddress                         : integer range 0 to 1023;

SIGNAL screen_area                      : STD_LOGIC;
SIGNAL hsync                            : STD_LOGIC;
SIGNAL vsync                            : STD_LOGIC;

SIGNAL screen_area_delayed2             : STD_LOGIC;
SIGNAL hsync_delayed2                   : STD_LOGIC;
SIGNAL vsync_delayed2                   : STD_LOGIC;

SIGNAL pixelDataRed                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL pixelDataGreen                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL pixelDataBlue                    : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL pixelDataRed2                    : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL pixelDataGreen2                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL pixelDataBlue2                   : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL encodedDataRed                   : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL encodedDataGreen                 : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL encodedDataBlue                  : STD_LOGIC_VECTOR(9 DOWNTO 0);

SIGNAL pixelColor                       : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL dataOutRed                       : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL dataOutGreen                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL dataOutBlue                      : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL COMBINED_SYNC                    : STD_LOGIC_VECTOR(1 DOWNTO 0);

SIGNAL DATA_IN                          : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA_OUT                         : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA_OE                          : STD_LOGIC;

SIGNAL WRITE_STROBE                     : STD_LOGIC;

SIGNAL enginesResetLine                 : STD_LOGIC;
SIGNAL enginesResetScreen               : STD_LOGIC;
SIGNAL enginesRun                       : STD_LOGIC;
SIGNAL lineToDraw                       : integer range 0 to 239;
SIGNAL bufferSwap                       : STD_LOGIC;
--SIGNAL screenState25M                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
--SIGNAL screenState100M                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL screenState                      : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL graphicsMode                     : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL textEngineRun                    : STD_LOGIC;
SIGNAL tileEngine1Run                   : STD_LOGIC;
SIGNAL tileEngine2Run                   : STD_LOGIC;
SIGNAL spriteEngineRun                  : STD_LOGIC;
SIGNAL affineEngineRun                  : STD_LOGIC;
SIGNAL bitmapEngineRun                  : STD_LOGIC;

SIGNAL affineTransparencyColor          : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL bitmapTransparencyColor          : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL affineTransEnable                : STD_LOGIC;
SIGNAL affineLayer                      : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL affineEdgeRepeat                 : STD_LOGIC;
SIGNAL bitmapTransEnable                : STD_LOGIC;
SIGNAL bitmapLayer                      : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL bitmapMode                       : STD_LOGIC_VECTOR(2 DOWNTO 0);

--engine to buffer steering signals
SIGNAL buffer0Select                    : integer range 0 to 1;
SIGNAL buffer1Select                    : integer range 0 to 1;
SIGNAL buffer2Select                    : integer range 0 to 2;
SIGNAL buffer3Select                    : integer range 0 to 2;

--linebuffer enable flags
SIGNAL layerEnable                      : STD_LOGIC_VECTOR(3 DOWNTO 0);

--address select from the copper
SIGNAL copper_int_address               : STD_LOGIC_VECTOR(5 DOWNTO 0);

--read/write byte flags from the copper
SIGNAL copper_byte_flags                : STD_LOGIC_VECTOR(1 DOWNTO 0);

--write data from the copper
SIGNAL copper_data_write                : STD_LOGIC_VECTOR(15 DOWNTO 0);

--individual copper to memory select signals
SIGNAL copper_select_system_registers   : STD_LOGIC;
SIGNAL copper_select_affine_table       : STD_LOGIC;
SIGNAL copper_select_bitmap_palette     : STD_LOGIC;

--copper to memory write strobe
SIGNAL copper_write_strobe              : STD_LOGIC;

--individual copper to memory write signals
SIGNAL copper_write_system_registers    : STD_LOGIC;
SIGNAL copper_write_affine_table        : STD_LOGIC;
SIGNAL copper_write_bitmap_palette      : STD_LOGIC;

--data return from the memories to the copper
SIGNAL copper_read_data_system_registers: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL copper_read_data_affine_table    : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL copper_read_data_bitmap_palette  : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL copper_read_data                 : STD_LOGIC_VECTOR(15 DOWNTO 0);

--copper access to the lookup tables
SIGNAL copper_lookup_address		    : integer range 0 to 511;
SIGNAL copper_invsqrt_data			    : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL copper_sincos_data		        : STD_LOGIC_VECTOR(15 DOWNTO 0);

--copper interrupt
SIGNAL copper_interrupt			        : STD_LOGIC;

--engine to bank address steering
SIGNAL bank0AddressSelect               : integer range 0 to 2; --address from Text, Bitmap
SIGNAL bank1AddressSelect               : integer range 0 to 2; --address from Tile A map, Affine Map, Bitmap
SIGNAL bank2AddressSelect               : integer range 0 to 3; --address from Tile B map, Affine Map, Bitmap
SIGNAL bank3AddressSelect               : integer range 0 to 2; --address from Tile A graphics, Affine graphics, Bitmap
SIGNAL bank4AddressSelect               : integer range 0 to 3; --address from Tile B graphics, Affine graphics, Bitmap
SIGNAL bank5AddressSelect               : integer range 0 to 1; --address from Sprite graphics, Bitmap
SIGNAL bank6AddressSelect               : integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile B Map
SIGNAL bank7AddressSelect               : integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile B Graphics
SIGNAL bank8AddressSelect               : integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile A Map
SIGNAL bank9AddressSelect               : integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile A Graphics

--select lines from decoded CPU address
SIGNAL select_system_registers          : STD_LOGIC;
SIGNAL select_audio_raw                 : STD_LOGIC;
SIGNAL select_affine_table              : STD_LOGIC;
SIGNAL select_bitmap_palette            : STD_LOGIC;
SIGNAL select_collision_flags           : STD_LOGIC;
SIGNAL select_palette_red               : STD_LOGIC;
SIGNAL select_palette_green             : STD_LOGIC;
SIGNAL select_palette_blue              : STD_LOGIC;
SIGNAL select_sprite_data               : STD_LOGIC;
SIGNAL select_audio_data                : STD_LOGIC;
SIGNAL select_sine_table                : STD_LOGIC;
SIGNAL select_inverse_table             : STD_LOGIC;
SIGNAL select_sample_table              : STD_LOGIC;
SIGNAL select_copper_list               : STD_LOGIC;
SIGNAL select_font                      : STD_LOGIC;
SIGNAL select_bank_1                    : STD_LOGIC;
SIGNAL select_bank_2                    : STD_LOGIC;
SIGNAL select_bank_3                    : STD_LOGIC;
SIGNAL select_bank_4                    : STD_LOGIC;
SIGNAL select_bank_5                    : STD_LOGIC;
SIGNAL select_bank_6                    : STD_LOGIC;
SIGNAL select_bank_7                    : STD_LOGIC;

--remapped memory block select lines
SIGNAL select_block_0                   : STD_LOGIC;
SIGNAL select_block_1                   : STD_LOGIC;
SIGNAL select_block_2                   : STD_LOGIC;
SIGNAL select_block_3                   : STD_LOGIC;
SIGNAL select_block_4                   : STD_LOGIC;
SIGNAL select_block_5                   : STD_LOGIC;
SIGNAL select_block_6                   : STD_LOGIC;
SIGNAL select_block_7                   : STD_LOGIC;
SIGNAL select_block_8                   : STD_LOGIC;
SIGNAL select_block_9                   : STD_LOGIC;

--write signals from select and write enable
SIGNAL write_system_registers           : STD_LOGIC;
SIGNAL write_affine_table               : STD_LOGIC;
SIGNAL write_bitmap_palette             : STD_LOGIC;
SIGNAL write_collision_flags            : STD_LOGIC;
SIGNAL write_palette_red                : STD_LOGIC;
SIGNAL write_palette_green              : STD_LOGIC;
SIGNAL write_palette_blue               : STD_LOGIC;
SIGNAL write_sprite_data                : STD_LOGIC;
SIGNAL write_audio_data                 : STD_LOGIC;
SIGNAL write_sample_table               : STD_LOGIC;
SIGNAL write_copper_list                : STD_LOGIC;
SIGNAL write_font                       : STD_LOGIC;

--renmapped memory block write lines
SIGNAL write_block_0                    : STD_LOGIC;
SIGNAL write_block_1                    : STD_LOGIC;
SIGNAL write_block_2                    : STD_LOGIC;
SIGNAL write_block_3                    : STD_LOGIC;
SIGNAL write_block_4                    : STD_LOGIC;
SIGNAL write_block_5                    : STD_LOGIC;
SIGNAL write_block_6                    : STD_LOGIC;
SIGNAL write_block_7                    : STD_LOGIC;
SIGNAL write_block_8                    : STD_LOGIC;
SIGNAL write_block_9                    : STD_LOGIC;

--read data from the memory blocks, for the CPU
SIGNAL read_data_system_registers       : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_audio_raw              : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_affine_table           : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_bitmap_palette         : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_collision_flags        : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_palette_red            : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_palette_green          : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_palette_blue           : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_sprite_data            : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_audio_data             : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_sine_table             : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_inverse_table          : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_sample_table           : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_copper_list            : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_font                   : STD_LOGIC_VECTOR(7 DOWNTO 0);

--direct read data from the memory banks
SIGNAL read_data_block_0                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_1                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_2                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_3                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_4                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_5                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_6                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_7                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_8                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_block_9                : STD_LOGIC_VECTOR(7 DOWNTO 0);

--remapped read data for the CPU
SIGNAL read_data_bank_1                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_bank_2                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_bank_3                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_bank_4                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_bank_5                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_bank_6                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL read_data_bank_7                 : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL collisionFlags                   : STD_LOGIC_VECTOR(7 DOWNTO 0);

--scroll and other signals from the system registers
SIGNAL TEXT_WIDTH                       : integer range 0 to 7;
SIGNAL TEXT_Y_SCROLL                    : integer range 0 to 255;
SIGNAL TILE_Y_SCROLL_1                  : integer range 0 to 255;
SIGNAL TILE_X_SCROLL_1                  : integer range 0 to 511;
SIGNAL TILE_Y_SCROLL_2                  : integer range 0 to 255;
SIGNAL TILE_X_SCROLL_2                  : integer range 0 to 511;
SIGNAL SPRITE_SCROLL_X                  : integer range 0 to 511;
SIGNAL SPRITE_SCROLL_Y                  : integer range 0 to 255;
SIGNAL masterAudioVolume                : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL copperReset                      : STD_LOGIC;
SIGNAL copperEnable                     : STD_LOGIC;

SIGNAL audioLoadOK                      : STD_LOGIC;

--address, data, and control from the graphics engines
SIGNAL text_write_address               : integer range 0 to 511;
SIGNAL text_write_strobe                : STD_LOGIC;
SIGNAL text_write_data                  : STD_LOGIC_VECTOR(9 DOWNTO 0);
        
SIGNAL tile_1_write_address             : integer range 0 to 511;
SIGNAL tile_1_write_strobe              : STD_LOGIC;
SIGNAL tile_1_write_data                : STD_LOGIC_VECTOR(9 DOWNTO 0);
        
SIGNAL tile_2_write_address             : integer range 0 to 511;
SIGNAL tile_2_write_strobe              : STD_LOGIC;
SIGNAL tile_2_write_data                : STD_LOGIC_VECTOR(9 DOWNTO 0);
        
SIGNAL sprite_write_address             : integer range 0 to 511;
SIGNAL sprite_write_strobe              : STD_LOGIC;
SIGNAL sprite_write_data                : STD_LOGIC_VECTOR(9 DOWNTO 0);
        
SIGNAL affine_write_address             : integer range 0 to 511;
SIGNAL affine_write_strobe              : STD_LOGIC;
SIGNAL affine_write_data                : STD_LOGIC_VECTOR(9 DOWNTO 0);
        
SIGNAL bitmap_write_address             : integer range 0 to 511;
SIGNAL bitmap_write_strobe              : STD_LOGIC;
SIGNAL bitmap_write_data                : STD_LOGIC_VECTOR(9 DOWNTO 0);
        
--address, data, and control to the line buffers
SIGNAL buffer_0_write_address           : integer range 0 to 511;
SIGNAL buffer_0_write_strobe            : STD_LOGIC;
SIGNAL buffer_0_write_data              : STD_LOGIC_VECTOR(9 DOWNTO 0);

SIGNAL buffer_1_write_address           : integer range 0 to 511;
SIGNAL buffer_1_write_strobe            : STD_LOGIC;
SIGNAL buffer_1_write_data              : STD_LOGIC_VECTOR(9 DOWNTO 0);

SIGNAL buffer_2_write_address           : integer range 0 to 511;
SIGNAL buffer_2_write_strobe            : STD_LOGIC;
SIGNAL buffer_2_write_data              : STD_LOGIC_VECTOR(9 DOWNTO 0);

SIGNAL buffer_3_write_address           : integer range 0 to 511;
SIGNAL buffer_3_write_strobe            : STD_LOGIC;
SIGNAL buffer_3_write_data              : STD_LOGIC_VECTOR(9 DOWNTO 0);

--animation cycle / frame counter register
SIGNAL animation_cycle                  : integer range 0 to 65535 := 0;

--address, data, and control interface signals for the memory blocks
SIGNAL audio_raw_cpu_address            : integer range 0 to 31;
SIGNAL audio_raw_read_address           : integer range 0 to 31;
SIGNAL audio_raw_read_data              : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL audio_raw_write_data             : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL audio_raw_write_strobe           : STD_LOGIC;

SIGNAL affine_cpu_address               : integer range 0 to 15;

SIGNAL palette_cpu_address              : integer range 0 to 15;

SIGNAL sprite_col_cpu_address           : integer range 0 to 127;
SIGNAL sprite_col_write_address         : integer range 0 to 127;
SIGNAL sprite_col_write_data            : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL sprite_col_read_data             : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL sprite_col_write_strobe          : STD_LOGIC;

SIGNAL font_cpu_address                 : integer range 0 to 2047;
SIGNAL font_read_address                : integer range 0 to 2047;
SIGNAL font_read_data                   : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL sprite_cpu_address               : integer range 0 to 1023;
SIGNAL sprite_read_address              : integer range 0 to 127;
SIGNAL sprite_read_data                 : STD_LOGIC_VECTOR(63 DOWNTO 0);

SIGNAL audio_cpu_address                : integer range 0 to 511;
SIGNAL audio_read_address               : integer range 0 to 511;
SIGNAL audio_read_data                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL audio_write_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL audio_write_strobe               : STD_LOGIC;

SIGNAL sine_table_cpu_address           : integer range 0 to 511;
SIGNAL sine_table_read_address          : integer range 0 to 255;
SIGNAL sine_table_read_data             : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL inv_table_cpu_address            : integer range 0 to 511;
SIGNAL inv_table_read_address           : integer range 0 to 255;
SIGNAL inv_table_read_data              : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL sample_table_cpu_address         : integer range 0 to 1023;
SIGNAL sample_table_read_address        : integer range 0 to 1023;
SIGNAL sample_table_read_data           : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL copper_list_cpu_address          : integer range 0 to 2047;
SIGNAL copper_list_read_address         : integer range 0 to 1023;
SIGNAL copper_list_read_data            : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL bank_cpu_address                 : integer range 0 to 8191;


SIGNAL bank_0_read_address              : integer range 0 to 2047;
SIGNAL bank_0_read_data                 : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL bank_1_read_address              : integer range 0 to 2047;
SIGNAL bank_1_read_data                 : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL bank_2_read_address              : integer range 0 to 2047;
SIGNAL bank_2_read_data                 : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL bank_3_read_address              : integer range 0 to 8191;
SIGNAL bank_3_read_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL bank_4_read_address              : integer range 0 to 8191;
SIGNAL bank_4_read_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL bank_5_read_address              : integer range 0 to 8191;
SIGNAL bank_5_read_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL bank_6_read_address              : integer range 0 to 2047;
SIGNAL bank_6_read_data                 : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL bank_7_read_address              : integer range 0 to 8191;
SIGNAL bank_7_read_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL bank_8_read_address              : integer range 0 to 2047;
SIGNAL bank_8_read_data                 : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL bank_9_read_address              : integer range 0 to 8191;
SIGNAL bank_9_read_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0);


SIGNAL text_map_read_address            : integer range 0 to 2047;
SIGNAL text_map_read_data               : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL tile_map_1_read_address          : integer range 0 to 2047;
SIGNAL tile_map_1_read_data             : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL tile_gfx_1_read_address          : integer range 0 to 8191;
SIGNAL tile_gfx_1_read_data             : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL tile_map_2_read_address          : integer range 0 to 2047;
SIGNAL tile_map_2_read_data             : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL tile_gfx_2_read_address          : integer range 0 to 8191;
SIGNAL tile_gfx_2_read_data             : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL sprite_gfx_read_address          : integer range 0 to 65535;
SIGNAL sprite_gfx_read_data             : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL affine_map_read_address          : integer range 0 to 16383;
SIGNAL affine_map_read_data             : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL affine_gfx_read_address          : integer range 0 to 16383;
SIGNAL affine_gfx_read_data             : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL bitmap_read_address              : integer range 0 to 131071;
SIGNAL bitmap_read_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0);


SIGNAL sprite_engine_debug              : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL tile_1_collision_write_strobe    : STD_LOGIC;
SIGNAL tile_2_collision_write_strobe    : STD_LOGIC;
SIGNAL sprite_collision_write_strobe    : STD_LOGIC;

SIGNAL tile_1_collision_address         : integer range 0 to 511;
SIGNAL tile_2_collision_address         : integer range 0 to 511;
SIGNAL sprite_collision_address         : integer range 0 to 511;

SIGNAL tile_1_collision_write_data      : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL tile_2_collision_write_data      : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL sprite_collision_write_data      : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL sprite_collision_read_data       : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL text_completed                   : STD_LOGIC;
SIGNAl tile_1_completed                 : STD_LOGIC;
SIGNAl tile_2_completed                 : STD_LOGIC;
SIGNAl tile_engines_completed           : STD_LOGIC;
SIGNAL sprite_completed                 : STD_LOGIC;
SIGNAL bitmap_completed                 : STD_LOGIC;
SIGNAL affine_completed                 : STD_LOGIC;
SIGNAL blanking_completed               : STD_LOGIC;

SIGNAL system_conditions                : STD_LOGIC_VECTOR(10 DOWNTO 0);

SIGNAL audioDebug                       : STD_LOGIC_VECTOR(5 DOWNTO 0);

SIGNAL gatedCS                          : STD_LOGIC;
SIGNAL int_address                      : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL LATCH_ADDRESS                    : STD_LOGIC;
SIGNAL LATCH_DATA_IN                    : STD_LOGIC;

SIGNAL DATA0_OUT_LATCH                  : STD_LOGIC;
SIGNAL DATA1_OUT_LATCH                  : STD_LOGIC;
SIGNAL DATA2_OUT_LATCH                  : STD_LOGIC;
SIGNAL DATA3_OUT_LATCH                  : STD_LOGIC;
SIGNAL DATA4_OUT_LATCH                  : STD_LOGIC;
SIGNAL DATA5_OUT_LATCH                  : STD_LOGIC;
SIGNAL DATA6_OUT_LATCH                  : STD_LOGIC;
SIGNAL DATA7_OUT_LATCH                  : STD_LOGIC;

SIGNAL int_write_strobe                 : STD_LOGIC;

SIGNAL nCSDebounced                     : STD_LOGIC;
SIGNAL nWEDebounced                     : STD_LOGIC;
SIGNAL nREDebounced                     : STD_LOGIC;

SIGNAL memory_remap                     : integer range 0 to 2;

SIGNAL effect_blank_value_R             : integer range 0 to 255;
SIGNAL effect_blank_value_G             : integer range 0 to 255;
SIGNAL effect_blank_value_B             : integer range 0 to 255;

SIGNAL effect_value_R                   : integer range 0 to 255;
SIGNAL effect_value_G                   : integer range 0 to 255;
SIGNAL effect_value_B                   : integer range 0 to 255;

SIGNAL effect_window_start_1            : integer range 0 to 511;
SIGNAL effect_window_stop_1             : integer range 0 to 511;
SIGNAL effect_window_start_2            : integer range 0 to 511;
SIGNAL effect_window_stop_2             : integer range 0 to 511;

SIGNAL effect_control_bits              : STD_LOGIC_VECTOR(15 DOWNTO 0);


BEGIN

-- ***** SYSTEM BUS INTERFACE LOGIC *****

    --system bus input/output
    
    PROCESS(CLK100M,DATA_OE,
            DATA0_OUT_LATCH,DATA1_OUT_LATCH,DATA2_OUT_LATCH,DATA3_OUT_LATCH,
            DATA4_OUT_LATCH,DATA5_OUT_LATCH,DATA6_OUT_LATCH,DATA7_OUT_LATCH)
    BEGIN
        IF RISING_EDGE(CLK100M) THEN
            DATA0_OUT_LATCH <= DATA_OUT(0);
            DATA1_OUT_LATCH <= DATA_OUT(1);
            DATA2_OUT_LATCH <= DATA_OUT(2);
            DATA3_OUT_LATCH <= DATA_OUT(3);
            DATA4_OUT_LATCH <= DATA_OUT(4);
            DATA5_OUT_LATCH <= DATA_OUT(5);
            DATA6_OUT_LATCH <= DATA_OUT(6);
            DATA7_OUT_LATCH <= DATA_OUT(7);
        END IF;
    
        DATA0_OE <= DATA_OE;
        DATA1_OE <= DATA_OE;
        DATA2_OE <= DATA_OE;
        DATA3_OE <= DATA_OE;
        DATA4_OE <= DATA_OE;
        DATA5_OE <= DATA_OE;
        DATA6_OE <= DATA_OE;
        DATA7_OE <= DATA_OE;
    
        if DATA_OE = '1' then
            DATA0_OUT <= DATA0_OUT_LATCH;
            DATA1_OUT <= DATA1_OUT_LATCH;
            DATA2_OUT <= DATA2_OUT_LATCH;
            DATA3_OUT <= DATA3_OUT_LATCH;
            DATA4_OUT <= DATA4_OUT_LATCH;
            DATA5_OUT <= DATA5_OUT_LATCH;
            DATA6_OUT <= DATA6_OUT_LATCH;
            DATA7_OUT <= DATA7_OUT_LATCH;
        else      
            DATA0_OUT <= '1';    
            DATA1_OUT <= '1';  
            DATA2_OUT <= '1';  
            DATA3_OUT <= '1';  
            DATA4_OUT <= '1';  
            DATA5_OUT <= '1';  
            DATA6_OUT <= '1';  
            DATA7_OUT <= '1';    
        end if;
    END PROCESS;

    
    led0 <= DATA0_IN;
    led1 <= DATA1_IN;
    led2 <= DATA2_IN;
    led3 <= DATA3_IN;
    led4 <= DATA4_IN;
    led5 <= DATA5_IN;
    led6 <= DATA6_IN;
    led7 <= DATA7_IN;
    
    --debounce nCS, nRE, nWE
    
    CSDebouncer: debouncer
        PORT MAP (CLK               => CLK100M,
                  INP               => nCS,
                  OUTP              => nCSDebounced
                  );

    REDebouncer: debouncer
        PORT MAP (CLK               => CLK100M,
                  INP               => nRE,
                  OUTP              => nREDebounced
                  );

    WEDebouncer: debouncer
        PORT MAP (CLK               => CLK100M,
                  INP               => nWE,
                  OUTP              => nWEDebounced
                  );
                  
    --address and data input latching, and override for internal coprocessor access.
    
    PROCESS(CLK200M,LATCH_DATA_IN,LATCH_ADDRESS,int_address,DATA_IN,ADDR,DATA0_IN,DATA1_IN,DATA2_IN,DATA3_IN,DATA4_IN,DATA5_IN,DATA6_IN,DATA7_IN)
        VARIABLE NEXT_DATA_IN                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE NEXT_INT_ADDRESS                 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        if LATCH_DATA_IN = '1' then
            NEXT_DATA_IN(0) := DATA0_IN;
            NEXT_DATA_IN(1) := DATA1_IN;
            NEXT_DATA_IN(2) := DATA2_IN;
            NEXT_DATA_IN(3) := DATA3_IN;
            NEXT_DATA_IN(4) := DATA4_IN;
            NEXT_DATA_IN(5) := DATA5_IN;
            NEXT_DATA_IN(6) := DATA6_IN;
            NEXT_DATA_IN(7) := DATA7_IN;
        else
            NEXT_DATA_IN := DATA_IN;
        end if;
            
        if LATCH_ADDRESS = '1' THEN
            NEXT_INT_ADDRESS := ADDR;
        ELSE
            NEXT_INT_ADDRESS := int_address;
        END IF;
        
        IF RISING_EDGE(CLK200M) THEN
            int_address <= NEXT_INT_ADDRESS;
            DATA_IN <= NEXT_DATA_IN;
        END IF;
    END PROCESS;
    
    gatedCS <= nCSDebounced;
    
    --instantiate the memory interface
    cpuInterface: cpu_interface
        PORT MAP (CLK               => CLK100M,
                  CS                => gatedCS,
                  RE                => nREDebounced,
                  WE                => nWEDebounced,
                  WRITE_STROBE      => WRITE_STROBE,
                  TRISTATE_OUT      => DATA_OE,
                  READY             => nREADY,
                  LATCH_ADDRESS     => LATCH_ADDRESS,
                  LATCH_DATA_IN     => LATCH_DATA_IN
                  );

    int_write_strobe <= WRITE_STROBE;
    
    --instantiate the mode decoder
    
    modeDecode: mode_decode
        PORT MAP (
                clk                      => CLK25M,
                enginesRun               => enginesRun,
                mode                     => graphicsMode,
                enableTextEngine         => textEngineRun,
                enableTileAEngine        => tileEngine1Run,
                enableTileBEngine        => tileEngine2Run,
                enableSpriteEngine       => spriteEngineRun,
                enableAffineEngine       => affineEngineRun,
                enableBitmapEngine       => bitmapEngineRun,
                bitmapMode               => bitmapMode,
                buffer0Select            => buffer0Select,
                buffer1Select            => buffer1Select,
                buffer2Select            => buffer2Select,
                buffer3Select            => buffer3Select,
                bank0AddressSelect       => bank0AddressSelect,
                bank1AddressSelect       => bank1AddressSelect,
                bank2AddressSelect       => bank2AddressSelect,
                bank3AddressSelect       => bank3AddressSelect,
                bank4AddressSelect       => bank4AddressSelect,
                bank5AddressSelect       => bank5AddressSelect,
                bank6AddressSelect       => bank6AddressSelect,
                bank7AddressSelect       => bank7AddressSelect,
                bank8AddressSelect       => bank8AddressSelect,
                bank9AddressSelect       => bank9AddressSelect,
                LAYER_ENABLE             => layerEnable
        );
    
    --instantiate the address decoder
    addressDecode: address_decode
        PORT MAP (ADDRESS_IN        => int_address,
                  SEL_SYS_REG       => select_system_registers,
                  SEL_AUDIO_RAW     => select_audio_raw,
                  SEL_AFFINE        => select_affine_table,
                  SEL_PALETTE       => select_bitmap_palette,
                  SEL_COL_FLAGS     => select_collision_flags,
                  SEL_PAL_RED       => select_palette_red,
                  SEL_PAL_GREEN     => select_palette_green,
                  SEL_PAL_BLUE      => select_palette_blue,
                  SEL_SPRITE_DATA   => select_sprite_data,
                  SEL_AUDIO_DATA    => select_audio_data,
                  SEL_SAMPLE_TABLE  => select_sample_table,
                  SEL_COPPER_LIST   => select_copper_list,
                  SEL_FONT          => select_font,
                  SEL_BANK_1        => select_bank_1,
                  SEL_BANK_2        => select_bank_2,
                  SEL_BANK_3        => select_bank_3,
                  SEL_BANK_4        => select_bank_4,
                  SEL_BANK_5        => select_bank_5,
                  SEL_BANK_6        => select_bank_6,
                  SEL_BANK_7        => select_bank_7
                  );
    
    --write strobe steering
    write_system_registers      <= int_write_strobe AND select_system_registers;
    write_affine_table          <= int_write_strobe AND select_affine_table;
    write_bitmap_palette        <= int_write_strobe AND select_bitmap_palette;
    write_collision_flags       <= int_write_strobe AND select_collision_flags;
    write_palette_red           <= int_write_strobe AND select_palette_red;
    write_palette_green         <= int_write_strobe AND select_palette_green;
    write_palette_blue          <= int_write_strobe AND select_palette_blue;
    write_sprite_data           <= int_write_strobe AND select_sprite_data;
    write_audio_data            <= int_write_strobe AND select_audio_data;
    write_sample_table          <= int_write_strobe AND select_sample_table;
    write_copper_list           <= int_write_strobe AND select_copper_list;
    write_font                  <= int_write_strobe AND select_font;
    
    --cpu interface to memory block steering
    --blocks 0-4 aways have the same steering
    
    select_block_0               <= select_bank_1;
    read_data_bank_1             <= read_data_block_0;
    
    select_block_1               <= select_bank_2;
    read_data_bank_2             <= read_data_block_1;
    
    select_block_2               <= select_bank_3;
    read_data_bank_3             <= read_data_block_2;
    
    select_block_3               <= select_bank_4;
    read_data_bank_4             <= read_data_block_3;
    
    select_block_4               <= select_bank_5;
    read_data_bank_5             <= read_data_block_4;
    
    --blocks 5-9 remapped as needed, controlled by the memory remap register
    PROCESS(memory_remap,select_bank_6,select_bank_7,read_data_block_5,read_data_block_6,read_data_block_7,read_data_block_8,read_data_block_9)
    BEGIN
        CASE memory_remap IS
            WHEN 0 =>
                select_block_5      <= select_bank_6;
                select_block_6      <= select_bank_7;
                select_block_7      <= '0';
                select_block_8      <= '0';
                select_block_9      <= '0';
                
                read_data_bank_6    <= read_data_block_5;
                read_data_bank_7    <= read_data_block_6;
            WHEN 1 =>
                select_block_5      <= '0';
                select_block_6      <= '0';
                select_block_7      <= select_bank_6;
                select_block_8      <= select_bank_7;
                select_block_9      <= '0';
                
                read_data_bank_6    <= read_data_block_7;
                read_data_bank_7    <= read_data_block_8;
            WHEN 2 =>
                select_block_5      <= '0';
                select_block_6      <= '0';
                select_block_7      <= '0';
                select_block_8      <= '0';
                select_block_9      <= select_bank_6;
                
                read_data_bank_6    <= read_data_block_9;
                read_data_bank_7    <= "00000000";
            --WHEN OTHERS =>
            --    select_block_5      <= '0';
            --    select_block_6      <= '0';
            --    select_block_7      <= '0';
            --    select_block_8      <= '0';
            --    select_block_9      <= '0';
                
            --    read_data_bank_6    <= "00000000";
            --    read_data_bank_7    <= "00000000";
        END CASE;
    END PROCESS;
    
    write_block_0                <= int_write_strobe AND select_block_0;
    write_block_1                <= int_write_strobe AND select_block_1;
    write_block_2                <= int_write_strobe AND select_block_2;
    write_block_3                <= int_write_strobe AND select_block_3;
    write_block_4                <= int_write_strobe AND select_block_4;
    write_block_5                <= int_write_strobe AND select_block_5;
    write_block_6                <= int_write_strobe AND select_block_6;
    write_block_7                <= int_write_strobe AND select_block_7;
    write_block_8                <= int_write_strobe AND select_block_8;
    write_block_9                <= int_write_strobe AND select_block_9;

    audio_raw_cpu_address <= to_integer(unsigned(int_address(4 downto 0)));
    affine_cpu_address <= to_integer(unsigned(int_address(3 downto 0)));
    palette_cpu_address <= to_integer(unsigned(int_address(3 downto 0)));
    sprite_col_cpu_address <= to_integer(unsigned(int_address(6 downto 0)));
    font_cpu_address <= to_integer(unsigned(int_address(10 downto 0)));
    sprite_cpu_address <= to_integer(unsigned(int_address(9 downto 0)));
    audio_cpu_address <= to_integer(unsigned(int_address(8 downto 0)));
    sine_table_cpu_address <= to_integer(unsigned(int_address(8 downto 0)));
    inv_table_cpu_address <= to_integer(unsigned(int_address(8 downto 0)));
    sample_table_cpu_address <= to_integer(unsigned(int_address(9 downto 0)));
    copper_list_cpu_address <= to_integer(unsigned(int_address(10 downto 0)));
    bank_cpu_address <= to_integer(unsigned(int_address(12 downto 0)));
    
--copper address decode, write strobe and data steering
    PROCESS(copper_int_address)
    BEGIN
        IF copper_int_address(5) = '0' THEN
            copper_select_system_registers <= '1';
        ELSE
            copper_select_system_registers <= '0';
        END IF;
        
        --Address range 101xxxxx is the audio raw, which the copper does not have access to.
        
        IF copper_int_address(5 downto 3) = "110" THEN
            copper_select_affine_table <= '1';
        ELSE
            copper_select_affine_table <= '0';
        END IF;
        
        IF copper_int_address(5 downto 3) = "111" THEN
            copper_select_bitmap_palette <= '1';
        ELSE
            copper_select_bitmap_palette <= '0';
        END IF;
    END PROCESS;
    
    copper_write_system_registers <= copper_select_system_registers AND copper_write_strobe;
    copper_write_affine_table <= copper_select_affine_table AND copper_write_strobe;
    copper_write_bitmap_palette <= copper_select_bitmap_palette AND copper_write_strobe;
    
    PROCESS(copper_read_data_system_registers,copper_select_system_registers,copper_read_data_affine_table,copper_select_affine_table,copper_read_data_bitmap_palette,copper_select_bitmap_palette)
    BEGIN
        IF (copper_select_system_registers) THEN
            copper_read_data <= copper_read_data_system_registers;
        ELSIF (copper_select_affine_table) THEN
            copper_read_data <= copper_read_data_affine_table;
        ELSIF (copper_select_bitmap_palette) THEN
            copper_read_data <= copper_read_data_bitmap_palette;
        ELSE
            copper_read_data <= "0000000000000000";
        END IF;
    END PROCESS;
    
--instantiate the bank to engine steering logic
    memSteer: bankEngineAttach
        PORT MAP(
            clk                       => CLK100M,
            --clk                       => CLK25M,
            bank0AddressSelect        => bank0AddressSelect,
            bank1AddressSelect        => bank1AddressSelect,
            bank2AddressSelect        => bank2AddressSelect,
            bank3AddressSelect        => bank3AddressSelect,
            bank4AddressSelect        => bank4AddressSelect,
            bank5AddressSelect        => bank5AddressSelect,
            bank6AddressSelect        => bank6AddressSelect,
            bank7AddressSelect        => bank7AddressSelect,
            bank8AddressSelect        => bank8AddressSelect,
            bank9AddressSelect        => bank9AddressSelect,
            bank_0_read_address       => bank_0_read_address,
            bank_0_read_data          => bank_0_read_data,
            bank_1_read_address       => bank_1_read_address,
            bank_1_read_data          => bank_1_read_data,
            bank_2_read_address       => bank_2_read_address,
            bank_2_read_data          => bank_2_read_data,
            bank_3_read_address       => bank_3_read_address,
            bank_3_read_data          => bank_3_read_data,
            bank_4_read_address       => bank_4_read_address,
            bank_4_read_data          => bank_4_read_data,
            bank_5_read_address       => bank_5_read_address,
            bank_5_read_data          => bank_5_read_data,
            bank_6_read_address       => bank_6_read_address,
            bank_6_read_data          => bank_6_read_data,
            bank_7_read_address       => bank_7_read_address,
            bank_7_read_data          => bank_7_read_data,
            bank_8_read_address       => bank_8_read_address,
            bank_8_read_data          => bank_8_read_data,
            bank_9_read_address       => bank_9_read_address,
            bank_9_read_data          => bank_9_read_data,
            text_map_read_address     => text_map_read_address,
            text_map_read_data        => text_map_read_data,
            tile_map_1_read_address   => tile_map_1_read_address,
            tile_map_1_read_data      => tile_map_1_read_data,
            tile_gfx_1_read_address   => tile_gfx_1_read_address,
            tile_gfx_1_read_data      => tile_gfx_1_read_data,
            tile_map_2_read_address   => tile_map_2_read_address,
            tile_map_2_read_data      => tile_map_2_read_data,
            tile_gfx_2_read_address   => tile_gfx_2_read_address,
            tile_gfx_2_read_data      => tile_gfx_2_read_data,
            sprite_gfx_read_address   => sprite_gfx_read_address,
            sprite_gfx_read_data      => sprite_gfx_read_data,
            affine_map_read_address   => affine_map_read_address,
            affine_map_read_data      => affine_map_read_data,
            affine_gfx_read_address   => affine_gfx_read_address,
            affine_gfx_read_data      => affine_gfx_read_data,
            bitmap_read_address       => bitmap_read_address,
            bitmap_read_data          => bitmap_read_data
        );
    
-- ***** MEMORY MAP *****

--    0x0000 to 0x003F      64   	control registers (not a block ram)
    
--    0x0040 to 0x005F      32  	audio channel raw (read-only) (32x8bit read-only, 32x8bit) (TODO: make not a block ram)
    arawmem: audioRawMem 
        PORT MAP(
            clk         => CLK200M,
            addrA       => audio_raw_cpu_address,
            rdataA      => read_data_audio_raw,
            addrB       => audio_raw_read_address,
            wdataB      => audio_raw_write_data,
            rdataB      => audio_raw_read_data,
            weB         => audio_raw_write_strobe
        );
    
--    0x0060 to 0x006F      16  	affine table (not a block ram)

--    0x0070 to 0x007F      16  	bitmap palette (not a block ram)

--    0x0080 to 0x00FF      128    	sprite collision flags (128x8bit, 128x8bit)
-- NOTE:  this is built from a single 512x10b block memory
     colMem: mem128b 
        PORT MAP(
            clk         => CLK200M,
            addrA       => sprite_col_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_collision_flags,
            weA         => write_collision_flags,
            addrB       => sprite_col_write_address,
            wdataB      => sprite_col_write_data,
            rdataB      => sprite_col_read_data,
            weB         => sprite_col_write_strobe
            );
    
--    0x0100 to 0x01FF       256    main palette (red) (256x8bit, 256x8bit read-only, pre-loaded with palette data)
-- NOTE:  this is built from a single 512x10b block memory
    paletteRed: ColorRAMRed
        PORT MAP ( wdataA       => DATA_IN,
                   addrA        => int_address(7 downto 0),
                   addrB        => pixelColor,
                   clkA         => CLK100M,
                   weA          => write_palette_red,
                   clkB         => CLK25M,
                   --clkB         => CLK200M,
                   rdataA       => read_data_palette_red,
                   rdataB       => pixelDataRed
        );
    
--    0x0200 to 0x02FF      256    main palette (green) (256x8bit, 256x8bit read-only, pre-loaded with palette data)
-- NOTE:  this is built from a single 512x10b block memory
    paletteGreen: ColorRAMGreen
        PORT MAP ( wdataA       => DATA_IN,
                   addrA        => int_address(7 downto 0),
                   addrB        => pixelColor,
                   clkA         => CLK100M,
                   weA          => write_palette_green,
                   clkB         => CLK25M,
                   --clkB         => CLK200M,
                   rdataA       => read_data_palette_green,
                   rdataB       => pixelDataGreen
        );
    
--    0x0300 to 0x03FF      256    main palette (blue)  (256x8bit, 256x8bit read-only, pre-loaded with palette data)   
-- NOTE:  this is built from a single 512x10b block memory
    paletteBlue: ColorRAMBlue
        PORT MAP ( wdataA       => DATA_IN,
                   addrA        => int_address(7 downto 0),
                   addrB        => pixelColor,
                   clkA         => CLK100M,
                   weA          => write_palette_blue,
                   clkB         => CLK25M,
                   --clkB         => CLK200M,
                   rdataA       => read_data_palette_blue,
                   rdataB       => pixelDataBlue
        );
    
--    0x0400 to 0x07FF      1K      sprite data (1024x8bit, 128x64bit)
-- NOTE:  this could theoretically be built from two 256x16b blocks
-- It is currently being built from 8 blocks to permit 64 bit wide fetch
-- we might rewrite the sprite code to perform 16 bit wide fetches
-- to free up 6 memory blocks
    spriteDataMem: mem1K1to8
        PORT MAP(
            clk         => CLK200M,
            addrA       => sprite_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_sprite_data,
            weA         => write_sprite_data,
            addrB       => sprite_read_address,
            rdataB      => sprite_read_data
        );
    
--    0x0800 to 0x09FF      512  	audio synth control (512x8bit, 512x8bit)
-- NOTE:  this is built from a single 512x10b block memory
    amem: audioMem
        PORT MAP(
            clk         => CLK200M,
            addrA       => audio_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_audio_data,
            weA         => write_audio_data,
            addrB       => audio_read_address,
            wdataB      => audio_write_data,
            rdataB      => audio_read_data,
            weB         => audio_write_strobe
        );
        
--    0x0A00 to 0x0BFF      512      currently unused
    
--    0x0C00 to 0x0FFF      1024     sample wavetable (1024x8b, 1024x8b read-only)
-- This holds four 256x8bit audio waveforms
-- TODO: pre-load this with interesting samples
    smem : wavetableMem
        PORT MAP (
            we_a        => write_sample_table,
            addr_a      => STD_LOGIC_VECTOR(to_unsigned(sample_table_cpu_address,10)),
            wdata_a     => DATA_IN,
            rdata_a     => read_data_sample_table,
            rdata_b     => sample_table_read_data,
            addr_b      => STD_LOGIC_VECTOR(to_unsigned(sample_table_read_address,10)),
            wdata_b     => "00000000",
            clk         => CLK200M
        );

--    0x1000 to 0x17FF      2K      copper list (2048 x 8b, 1024x16b read-only)
-- NOTE: this is built from four 512x10b blocks
-- This is actually the minimum size, so it's fine as is.
    cmem: copperMem
        PORT MAP(
            clk         => CLK200M,
            addrA       => copper_list_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_copper_list,
            weA         => write_copper_list,
            addrB       => copper_list_read_address,
            rdataB      => copper_list_read_data
            );
    
--    0x1800 to 0x1FFF       2K      256 characters, 8x8, 1bpp font bitmaps (2048x8bit, 2048x8bit read-only)
-- NOTE: this is built from four 512x10b blocks
-- This is actually the minimum size, so it's fine as is.
    fontMem: mem2Kfonts 
        PORT MAP(
            clk         => CLK200M,
            addrA       => font_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_font,
            weA         => write_font,
            addrB       => font_read_address,
            rdataB      => font_read_data
            );
            
--      Memory from 0x2000-0xFFFF is remapped as needed:
    
    --0x2000-0x3FFF: Bank 0 (Text map or bitmap 9)
    --0x4000-0x5FFF: Bank 1 (Tile A map, Affine map 1, or bitmap 8)
    --0x6000-0x7FFF: Bank 2 (Tile B map, Affine map 2, or bitmap 7)
    --0x8000-0x9FFF: Bank 3 (Tile A graphics, Affine graphics 1, or bitmap 6)
    --0xA000-0xBFFF: Bank 4 (Tile B graphics, Affine graphics 2, or bitmap 5)
    --0xC000-0xDFFF: Bank 5 (Sprite 0, bitmap 4) or Bank 7 (sprite 2, bitmap 2) or Bank 9 (sprite 4, or bitmap 0)
    --0xE000-0xFFFF: Bank 6 (Sprite 1, bitmap 3) or Bank 8 (sprite 3, or bitmap 1)
    
    --Bitmap memory remap select register is used to select banks 5/6/7/8/9. 
    
    --Banks 0, 1, and 2 are 8Kx8b on port A, 2Kx32b on port B
    --These use 16 bram blocks each.
    --Banks 3 though 9 are 8Kx8b on port A, 8Kx8b on port B
    --These also use 16 bram blocks each.
    
    bank0: mem8K1to4 --Bank 0: 32bit, Text map or Bitmap 9
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_0,
            weA         => write_block_0,
            addrB       => bank_0_read_address,
            rdataB      => bank_0_read_data
            );
    
    bank1: mem8K1to4 --Bank 1: 32bit, Tile A map or Affine Map 1 or Bitmap 8
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_1,
            weA         => write_block_1,
            addrB       => bank_1_read_address,
            rdataB      => bank_1_read_data
            );
            
    bank2: mem8K1to4 --Bank 2: 32bit, Tile B map or Affine Map 2 or Bitmap 7
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_2,
            weA         => write_block_2,
            addrB       => bank_2_read_address,
            rdataB      => bank_2_read_data
            );
            
    bank3: mem8K    --Bank 3: 8bit, Tile A graphics or Affine Graphics 1 or Bitmap 6
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_3,
            weA         => write_block_3,
            addrB       => bank_3_read_address,
            rdataB      => bank_3_read_data
            );
            
    bank4: mem8K    --Bank 4: 8bit, Tile B graphics or Affine Graphics 2 or Bitmap 5
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_4,
            weA         => write_block_4,
            addrB       => bank_4_read_address,
            rdataB      => bank_4_read_data
            );
            
    bank5: mem8K    --Bank 5: 8bit, Sprite graphics 0 or Bitmap 4
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_5,
            weA         => write_block_5,
            addrB       => bank_5_read_address,
            rdataB      => bank_5_read_data
            );
            
    bank6: mem8K1to4    --Bank 6: 32bit, Sprite graphics 1, Bitmap 3, or Tile B map
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_6,
            weA         => write_block_6,
            addrB       => bank_6_read_address,
            rdataB      => bank_6_read_data
            );
            
    bank7: mem8K    --Bank 7: 8bit, Sprite graphics 2, Bitmap 2, or Tile B graphics
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_7,
            weA         => write_block_7,
            addrB       => bank_7_read_address,
            rdataB      => bank_7_read_data
            );
            
    bank8: mem8K1to4    --Bank 8: 32bit, Sprite graphics 3, Bitmap 1, or Tile A map
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_8,
            weA         => write_block_8,
            addrB       => bank_8_read_address,
            rdataB      => bank_8_read_data
            );
            
    bank9: mem8K    --Bank 9: 8bit, Sprite graphics 4, Bitmap 0, or Tile A graphics
        PORT MAP(
            clk         => CLK200M,
            addrA       => bank_cpu_address,
            wdataA      => DATA_IN,
            rdataA      => read_data_block_9,
            weA         => write_block_9,
            addrB       => bank_9_read_address,
            rdataB      => bank_9_read_data
            );
            
/*
--Current BRAM usage:

User accessible memory: (184 blocks)

1*	arawmem		    32x8b / 16x16b      16 bits for each of 16 voices           *could be converted to registers instead of bram
1*	colMem          128x8b / 128x8b     8 bits for each of 128 sprites          *only using 25% of this bram
1*	paletteRed      256x8b / 256x8b     8 bits for each of 256 colors           *only using 50% of red/green/blue palette brams
1*	paletteGreen    256x8b / 256x8b     8 bits for each of 256 colors           
1*	paletteBlue     256x8b / 256x8b     8 bits for each of 256 colors           
8*	spriteDataMem	1024x8b / 128x64b   8 bytes for each of 128 sprites         *could be done with 2 bram - would need to rewrite sprite engine to read 16 bits at a time.
1	amem            512x8b / 512x8b     32 bytes for each of 16 voices
2	smem		    1024x8b / 1024x8b   8 bits for 256 entries in each of 4 tables
4	cmem            2048x8b / 1024x16b  1024 16 bit instructions for copper
4	fontMem         2048x8b / 2048x8b   8 bytes for each of 256 characters
16	bank0           8192x8b / 2048x32b  64x32 map, 4 bytes per position
16	bank1           8192x8b / 2048x32b  64x32 map, 4 bytes per position
16	bank2           8192x8b / 2048x32b  64x32 map, 4 bytes per position
16	bank3           8192x8b / 8192x8b   8K of tile/bitmap space
16	bank4           8192x8b / 8192x8b   8K of tile/bitmap space
16	bank5           8192x8b / 8192x8b   8K of sprite/bitmap space
16	bank6           8192x8b / 8192x8b   8K of sprite/bitmap space
16	bank7           8192x8b / 8192x8b   8K of sprite/bitmap space
16	bank8           8192x8b / 8192x8b   8K of sprite/bitmap space
16	bank9           8192x8b / 8192x8b   8K of sprite/bitmap space

Internal memory: (18 blocks)

2*  sineTableMem    256x16b             16 bits for each entry                  *could be done with 1 bram
2   invSqrtTableMem 512x16b             16 bits for each entry
1	collmemA        512x4b              4 bits for each pixel
1	collmemB        512x4b              4 bits for each pixel
1	buffer0A        512x10b             10 bits for each pixel
1	buffer0B        512x10b             10 bits for each pixel
1	buffer1A        512x10b             10 bits for each pixel
1	buffer1B        512x10b             10 bits for each pixel
1	buffer2A        512x10b             10 bits for each pixel
1	buffer2B        512x10b             10 bits for each pixel
1	buffer3A        512x10b             10 bits for each pixel
1	buffer3B        512x10b             10 bits for each pixel
4* 	blitter FIFO    16x64b              64 bits for each of 16 FIFO spots       *could be done with 1 bram - would need dedicated pipeline code to transfer data in and out 16 bits at a time 

202 out of 204 BRAM used (12 could be freed with some effort)
*/
            
--sine/cos and inverse/square root table ROMs
--Used by both the audio synthesis logic and the copper
--Not externally accessible
            
    sineTableMem : sineTableRom
        PORT MAP (
            addr_a => STD_LOGIC_VECTOR(to_unsigned(copper_lookup_address,8)),
            rdata_a => copper_sincos_data,
            rdata_b => sine_table_read_data,
            addr_b => STD_LOGIC_VECTOR(to_unsigned(sine_table_read_address,8)),
            clk => CLK100M
        );

    invSqrtTableMem : invSqrtTableRom
        PORT MAP (
            addr_a => STD_LOGIC_VECTOR(to_unsigned(copper_lookup_address,9)),
            rdata_a => copper_invsqrt_data,
            rdata_b => inv_table_read_data,
            addr_b => STD_LOGIC_VECTOR(to_unsigned(inv_table_read_address,9)),
            clk => CLK100M
        );
    
    
-- ***** SYSTEM REGISTERS AND MODE CONTROL *****

    --instantiate the LFSR RNG
    rng : LFSR16
       PORT MAP (
            clk                     => CLK100M,
            output                  => LFSRrng
            );
            
    --instantiate the system registers
    sysreg: system_registers 
            PORT MAP (
                CLK                 => CLK100M,
                ADDRESS_IN          => int_address(5 downto 0),
                DATA_IN             => DATA_IN,
                DATA_OUT            => read_data_system_registers,
                WRITE_STROBE        => write_system_registers,
                
                COPPER_ADDRESS_IN   => copper_int_address(4 downto 0),
                COPPER_DATA_IN      => copper_data_write,
                COPPER_DATA_OUT     => copper_read_data_system_registers,
                COPPER_WRITE_STROBE => copper_write_system_registers,
                COPPER_BYTE_FLAGS   => copper_byte_flags,
                
                FRAME_COUNT         => animation_cycle,
                INTERRUPT_OUT       => nINT,
                TEXT_WIDTH          => TEXT_WIDTH,
                TEXT_Y_SCROLL       => TEXT_Y_SCROLL,
                TILE_Y_SCROLL_1     => TILE_Y_SCROLL_1,
                TILE_X_SCROLL_1     => TILE_X_SCROLL_1,
                TILE_Y_SCROLL_2     => TILE_Y_SCROLL_2,
                TILE_X_SCROLL_2     => TILE_X_SCROLL_2,
                SPRITE_SCROLL_Y     => SPRITE_SCROLL_Y,
                SPRITE_SCROLL_X     => SPRITE_SCROLL_X,
                LINE_ACTIVE         => lineToDraw,
                X_ACTIVE            => tempX,
                GRAPHICS_MODE       => graphicsMode,
                AUDIO_VOLUME        => masterAudioVolume,
                COLLISION_FLAGS     => collisionFlags,
                --SCREEN_STATE        => screenState100M,
                SCREEN_STATE        => screenState,
                RNG                 => LFSRrng(7 downto 0),
                AUDIOLOADPULSE      => audioLoadOK,
                AFFINE_TRANS_COLOR  => affineTransparencyColor,
                BITMAP_TRANS_COLOR  => bitmapTransparencyColor,
                AFFINE_TRANS_ENABLE => affineTransEnable,
                AFFINE_LAYER        => affineLayer,
                AFFINE_EDGE_REPEAT  => affineEdgeRepeat,
                BITMAP_TRANS_ENABLE => bitmapTransEnable,
                BITMAP_LAYER        => bitmapLayer,
                MEMORY_REMAP        => memory_remap,
                COPPER_ENABLE       => copperEnable,
                COPPER_RESET        => copperReset,
                BLANK_R             => effect_blank_value_R,
                BLANK_G             => effect_blank_value_G,
                BLANK_B             => effect_blank_value_B,
                EFFECT_R            => effect_value_R,
                EFFECT_G            => effect_value_G,
                EFFECT_B            => effect_value_B,
                WINDOW_START_1      => effect_window_start_1,
                WINDOW_STOP_1       => effect_window_stop_1,
                WINDOW_START_2      => effect_window_start_2,
                WINDOW_STOP_2       => effect_window_stop_2,
                EFFECT_CONTROL_BITS => effect_control_bits,
                COPPER_INTERRUPT    => copper_interrupt,
                COPPER_ADDRESS      => copper_list_read_address
            );

-- ***** AUDIO SYNTHESIS *****

    --audio synth  engine
    audio: audiogen
       PORT MAP (
            CLK25       => CLK25M,
            CLK100      => CLK100M,
            MCLK        => CLK1M535,
            
            AUDIO_DAT_ADDRESS_OUT   => audio_read_address,
            AUDIO_DAT_DATA_IN       => audio_read_data,
            AUDIO_DAT_DATA_OUT      => audio_write_data,
            AUDIO_DAT_WRITE_OUT     => audio_write_strobe,
            RNG16                   => LFSRrng,
            SINE_TABLE_ADDRESS_OUT  => sine_table_read_address,
            SINE_TABLE_DATA_IN      => sine_table_read_data,
            INV_TABLE_ADDRESS_OUT   => inv_table_read_address,
            INV_TABLE_DATA_IN       => inv_table_read_data,
            SAMPLE_TABLE_ADDRESS_OUT=> sample_table_read_address,
            SAMPLE_TABLE_DATA_IN    => sample_table_read_data,
            
            RAW_VALUE_ADDRESS_OUT   => audio_raw_read_address,
            RAW_VALUE_DATA_IN       => audio_raw_read_data,
            RAW_VALUE_DATA_OUT      => audio_raw_write_data,
            RAW_VALUE_WRITE_OUT     => audio_raw_write_strobe,
            
            --CPU_ADDR                => audio_raw_cpu_address,
            --CPU_RDATA               => read_data_audio_raw;
            
            masterVolumeIn          => masterAudioVolume,
            loadOkPulse             => audioLoadOK,
            sclk                    => SCLK,
            lrclk                   => LRCLK,
            sdata                   => SDATA,
            debug                   => audioDebug
            );

    MCLK <= '0'; --unused
   
-- ***** VIDEO TIMING CONTROL *****

    --instantiate the video timing controller
    masterTimer: timing_control
        PORT MAP (
            clk               => CLK25M,
            --clk               => CLK100M,
            xpos              => xaddress,
            ypos              => yaddress,
            screen_area       => screen_area,
            hsync             => hsync,
            vsync             => vsync,
            line_reset        => enginesResetLine,
            screen_reset      => enginesResetScreen,
            engine_run        => enginesRun,
            buffer_swap       => bufferSwap,
            line_to_draw      => lineToDraw,
            --screen_state      => screenState25M
            screen_state      => screenState
        );
    
    --clock domain crossing for screen state
    --PROCESS(CLK100M,screenState25M)
    --BEGIN
    --    IF RISING_EDGE(CLK100M) THEN
    --        screenState100M <= screenState25M;
    --    END IF;
    --END PROCESS;
    
    --animation loop timer
    PROCESS(CLK100M,animation_cycle,enginesResetScreen)
        VARIABLE state                      : integer range 0 to 2 := 0;
        VARIABLE next_state                 : integer range 0 to 2;
        VARIABLE next_animation_cycle       : integer range 0 to 65535;
        VARIABLE incCycle                   : STD_LOGIC;
    BEGIN
        CASE state IS
            WHEN 0 =>
                incCycle := '0';
                IF enginesResetScreen THEN
                    next_state := 1;
                ELSE
                    next_state := 0;
                END IF;
            WHEN 1 =>
                incCycle := '1';
                next_state := 2;
            WHEN 2 =>
                incCycle := '0';
                IF enginesResetScreen THEN
                    next_state := 2;
                ELSE
                    next_state := 0;
                END IF;
            --WHEN OTHERS =>
            --    incCycle := '0';
            --    next_state := 0;
        END CASE;
    
        IF incCycle THEN
            next_animation_cycle := animation_cycle + 1;
        ELSE
            next_animation_cycle := animation_cycle;
        END IF;
        
        IF RISING_EDGE(CLK100M) THEN
            animation_cycle <= next_animation_cycle;
            state := next_state;
        END IF;
    END PROCESS;
    
-- ***** COPROCESSOR *****
    
    --system_conditions <= enginesResetScreen & enginesResetLine & screenState100M(3) & screenState100M(2) & sprite_completed & tile_2_completed & tile_1_completed & text_completed & bitmap_completed & affine_completed & "0";
    system_conditions <= enginesResetScreen & enginesResetLine & screenState(3) & screenState(2) & sprite_completed & tile_2_completed & tile_1_completed & text_completed & bitmap_completed & affine_completed & "0";
        
    coprocessor: copper
        PORT MAP (
            --CLK25M                  => CLK25M,
            CLK100M                 => CLK100M,
            --RESET_LINE              => enginesResetLine,
            --RESET_SCREEN            => enginesResetScreen,
            COPPER_RESET            => copperReset,
            COPPER_RUN              => copperEnable,
            CONDITIONS              => system_conditions,
            ACTIVE_LINE             => lineToDraw,
            ADDRESS_OUT             => copper_int_address,
            DATA_OUT                => copper_data_write,
            DATA_IN                 => copper_read_data,
            WRITE_STROBE            => copper_write_strobe,
            BYTE_FLAGS              => copper_byte_flags,
            COPPER_ADDRESS_OUT      => copper_list_read_address,
            COPPER_INST_IN          => copper_list_read_data,
            LOOKUP_ADDRESS_OUT      => copper_lookup_address,
            INVSQRT_DATA_IN         => copper_invsqrt_data,
            SINCOS_DATA_IN          => copper_sincos_data,
            COPPER_INTERRUPT_OUT     => copper_interrupt
        );
        
-- ***** TEXT ENGINE *****
    
    --instantiate the text engine
    textEngine: text_engine
       PORT MAP (CLK                     => CLK100M,
                 RESET_LINE              => enginesResetLine,
                 RESET_SCREEN            => enginesResetScreen,
                 RUN                     => textEngineRun,
                 LINE_TO_DRAW            => lineToDraw,
                 DONE                    => text_completed,
                 TEXT_WIDTH              => TEXT_WIDTH,
                 TEXT_Y_SCROLL           => TEXT_Y_SCROLL,
                 ANIM_CYCLE              => animation_cycle,
                 MAP_READ_ADDRESS        => text_map_read_address,
                 MAP_DATA_IN             => text_map_read_data,
                 FONT_READ_ADDRESS       => font_read_address,
                 FONT_DATA_IN            => font_read_data,
                 BUFFER_WRITE_ADDRESS    => text_write_address,
                 BUFFER_WRITE_DATA       => text_write_data,
                 BUFFER_WRITE_STROBE     => text_write_strobe
             );
    
-- ***** TILE ENGINE 1 *****
    
    --instantiate the first tile engine
    tile1Engine: tile_engine
       PORT MAP (CLK25M                 => CLK25M,
                 CLK100M                 => CLK100M,
                 RESET_LINE              => enginesResetLine,
                 RESET_SCREEN            => enginesResetScreen,
                 RUN                     => tileEngine1Run,
                 LINE_TO_DRAW            => lineToDraw,
                 DONE                    => tile_1_completed,
                 TILE_Y_SCROLL           => TILE_Y_SCROLL_1,
                 TILE_X_SCROLL           => TILE_X_SCROLL_1,
                 ANIM_CYCLE              => animation_cycle,
                 MAP_READ_ADDRESS        => tile_map_1_read_address,
                 MAP_DATA_IN             => tile_map_1_read_data,
                 TILE_GFX_READ_ADDRESS   => tile_gfx_1_read_address,
                 TILE_GFX_DATA_IN        => tile_gfx_1_read_data,
                 BUFFER_WRITE_ADDRESS    => tile_1_write_address,
                 BUFFER_WRITE_DATA       => tile_1_write_data,
                 BUFFER_WRITE_STROBE     => tile_1_write_strobe,
                 COLLISION_WRITE_ADDRESS => tile_1_collision_address,
                 COLLISION_WRITE_DATA    => tile_1_collision_write_data,
                 COLLISION_WRITE_STROBE  => tile_1_collision_write_strobe
             );
    
-- ***** TILE ENGINE 2 *****

    --instantiate the second tile engine
    tile2Engine: tile_engine
       PORT MAP (CLK25M                 => CLK25M,
                 CLK100M                 => CLK100M,
                 RESET_LINE              => enginesResetLine,
                 RESET_SCREEN            => enginesResetScreen,
                 RUN                     => tileEngine2Run,
                 LINE_TO_DRAW            => lineToDraw,
                 DONE                    => tile_2_completed,
                 TILE_Y_SCROLL           => TILE_Y_SCROLL_2,
                 TILE_X_SCROLL           => TILE_X_SCROLL_2,
                 ANIM_CYCLE              => animation_cycle,
                 MAP_READ_ADDRESS        => tile_map_2_read_address,
                 MAP_DATA_IN             => tile_map_2_read_data,
                 TILE_GFX_READ_ADDRESS   => tile_gfx_2_read_address,
                 TILE_GFX_DATA_IN        => tile_gfx_2_read_data,
                 BUFFER_WRITE_ADDRESS    => tile_2_write_address,
                 BUFFER_WRITE_DATA       => tile_2_write_data,
                 BUFFER_WRITE_STROBE     => tile_2_write_strobe,
                 COLLISION_WRITE_ADDRESS => tile_2_collision_address,
                 COLLISION_WRITE_DATA    => tile_2_collision_write_data,
                 COLLISION_WRITE_STROBE  => tile_2_collision_write_strobe
             );
             
-- ***** SPRITE ENGINE *****

    tile_engines_completed <= tile_1_completed AND tile_2_completed;
    
    --sprite collsion buffers are not accessible from the external system bus

    --instantiate the first collision buffer
    collmemA: mem512x4bit
        PORT MAP(
            we_a        => tile_1_collision_write_strobe,
            we_b        => sprite_collision_write_strobe,
            
            addr_a      => STD_LOGIC_VECTOR(to_unsigned(tile_1_collision_address,9)),
            rdata_a     => open,
            wdata_a     => tile_1_collision_write_data,
            
            addr_b      => STD_LOGIC_VECTOR(to_unsigned(sprite_collision_address,9)),
            rdata_b     => sprite_collision_read_data(3 downto 0),
            wdata_b     => sprite_collision_write_data(3 downto 0),
            
            clk_a       => CLK200M,
            clk_b       => CLK200M,
            clke_b      => '1',
            clke_a      => '1'
        );
    
    --instantiate the second collision buffer
    collmemB: mem512x4bit
        PORT MAP(
            we_a        => tile_2_collision_write_strobe,
            we_b        => sprite_collision_write_strobe,
            
            addr_a      => STD_LOGIC_VECTOR(to_unsigned(tile_2_collision_address,9)),
            rdata_a     => open,
            wdata_a     => tile_2_collision_write_data,
            
            addr_b      => STD_LOGIC_VECTOR(to_unsigned(sprite_collision_address,9)),
            rdata_b     => sprite_collision_read_data(7 downto 4),
            wdata_b     => sprite_collision_write_data(7 downto 4),
            
            clk_a       => CLK200M,
            clk_b       => CLK200M,
            clke_b      => '1',
            clke_a      => '1'
        );
        
    --instantiate the engine itself
    spriteEngine: sprite_engine
        PORT MAP (
            CLK25M                  => CLK25M,
            CLK100M                 => CLK100M,
            RESET_LINE              => enginesResetLine,
            RESET_SCREEN            => enginesResetScreen,
            RUN                     => spriteEngineRun,
            LINE_TO_DRAW            => lineToDraw,
            DONE                    => sprite_completed,
            SPRITE_SCROLL_X         => SPRITE_SCROLL_X,
            SPRITE_SCROLL_Y         => SPRITE_SCROLL_Y,
            ANIM_CYCLE              => animation_cycle,
            SPRITE_READ_ADDRESS     => sprite_read_address,
            SPRITE_DATA_IN          => sprite_read_data,
            SPRITE_GFX_READ_ADDRESS => sprite_gfx_read_address,
            SPRITE_GFX_DATA_IN      => sprite_gfx_read_data,
            COLLISION_WRITE_ADDRESS => sprite_col_write_address,
            COLLISION_WRITE_STROBE  => sprite_col_write_strobe,
            COLLISION_WRITE_DATA    => sprite_col_write_data,
            COLLISION_READ_DATA     => sprite_col_read_data,
            COLLISION_INTERRUPTS    => collisionFlags,
            BUFFER_WRITE_ADDRESS    => sprite_write_address,
            BUFFER_WRITE_DATA       => sprite_write_data,
            BUFFER_WRITE_STROBE     => sprite_write_strobe,
            DEBUG_OUT               => sprite_engine_debug,
            COL_BUFF_ADDRESS        => sprite_collision_address,
            COL_BUFF_WRITE_DATA     => sprite_collision_write_data,
            COL_BUFF_READ_DATA      => sprite_collision_read_data,
            COL_BUFF_WRITE_STROBE   => sprite_collision_write_strobe,
            COL_BUFF_READY          => tile_engines_completed
        );
    
-- ***** AFFINE TILE ENGINE  *****

    affEngine: affine_engine
        PORT MAP (
            CLK25M                      => CLK25M,
            CLK100M                     => CLK100M,
            RESET_LINE                  => enginesResetLine,
            RESET_SCREEN                => enginesResetScreen,
            RUN                         => affineEngineRun,
            LINE_TO_DRAW                => lineToDraw,
            DONE                        => affine_completed,
            AFFINE_TRANS_FLAG           => affineTransEnable,
            AFFINE_TRANS_COLOR          => affineTransparencyColor,
            AFFINE_LAYER                => affineLayer,
            AFFINE_EDGE_REPEAT          => affineEdgeRepeat,
            CPU_ADDR                    => affine_cpu_address,
            CPU_WDATA                   => DATA_IN,
            CPU_RDATA                   => read_data_affine_table,
            CPU_WE                      => write_affine_table,
            COPPER_ADDRESS_IN           => copper_int_address(2 downto 0),
            COPPER_DATA_IN              => copper_data_write,
            COPPER_DATA_OUT             => copper_read_data_affine_table,
            COPPER_WRITE_STROBE         => copper_write_affine_table,
            COPPER_BYTE_FLAGS           => copper_byte_flags,
            AFFINE_MAP_READ_ADDRESS     => affine_map_read_address,
            AFFINE_MAP_READ_DATA        => affine_map_read_data,
            AFFINE_GFX_READ_ADDRESS     => affine_gfx_read_address,
            AFFINE_GFX_READ_DATA        => affine_gfx_read_data,
            BUFFER_WRITE_ADDRESS        => affine_write_address,
            BUFFER_WRITE_DATA           => affine_write_data,
            BUFFER_WRITE_STROBE         => affine_write_strobe
        );

-- ***** BITMAP ENGINE  *****

    bitmapEngine: bitmap_engine
        PORT MAP (
            CLK25M                  => CLK25M,
            CLK100M                 => CLK100M,
            RESET_LINE              => enginesResetLine,
            RESET_SCREEN            => enginesResetScreen,
            RUN                     => bitmapEngineRun,
            LINE_TO_DRAW            => lineToDraw,
            DONE                    => bitmap_completed,
            BITMAP_MODE             => bitmapMode,
            BITMAP_TRANS_FLAG       => bitmapTransEnable,
            BITMAP_TRANS_COLOR      => bitmapTransparencyColor,
            BITMAP_LAYER            => bitmapLayer,
            CPU_ADDR                => palette_cpu_address,
            CPU_WDATA               => DATA_IN,
            CPU_RDATA               => read_data_bitmap_palette,
            CPU_WE                  => write_bitmap_palette,
            COPPER_ADDRESS_IN       => copper_int_address(2 downto 0),
            COPPER_DATA_IN          => copper_data_write,
            COPPER_DATA_OUT         => copper_read_data_bitmap_palette,
            COPPER_WRITE_STROBE     => copper_write_bitmap_palette,
            COPPER_BYTE_FLAGS       => copper_byte_flags,
            BITMAP_READ_ADDRESS     => bitmap_read_address,
            BITMAP_READ_DATA        => bitmap_read_data,
            BUFFER_WRITE_ADDRESS    => bitmap_write_address,
            BUFFER_WRITE_DATA       => bitmap_write_data,
            BUFFER_WRITE_STROBE     => bitmap_write_strobe
        );
    
-- ***** BUS INTERFACE - DATA OUTPUT MUX *****

    dataoutmux : registeredmux20x8
    PORT MAP (
      CLK => CLK100M,
      S0  => select_system_registers,
      Q0  => read_data_system_registers,
      S1  => select_collision_flags,
      Q1  => read_data_collision_flags,
      S2  => select_palette_red,
      Q2  => read_data_palette_red,
      S3  => select_palette_green,
      Q3  => read_data_palette_green,
      S4  => select_palette_blue,
      Q4  => read_data_palette_blue,
      S5  => select_audio_data,
      Q5  => read_data_audio_data,
      S6  => select_audio_raw,
      Q6  => read_data_audio_raw,
      S7  => select_affine_table,
      Q7  => read_data_affine_table,
      S8 => select_bitmap_palette,
      Q8 => read_data_bitmap_palette,
      S9 => select_sample_table,
      Q9 => read_data_sample_table,
      S10 => select_copper_list,
      Q10 => read_data_copper_list,
      S11  => select_sprite_data,
      Q11  => read_data_sprite_data,
      S12  => select_font,
      Q12  => read_data_font,
      S13  => select_bank_1,
      Q13  => read_data_bank_1,
      S14  => select_bank_2,
      Q14  => read_data_bank_2,
      S15  => select_bank_3,
      Q15  => read_data_bank_3,
      S16  => select_bank_4,
      Q16  => read_data_bank_4,
      S17  => select_bank_5,
      Q17  => read_data_bank_5,
      S18  => select_bank_6,
      Q18  => read_data_bank_6,
      S19  => select_bank_7,
      Q19  => read_data_bank_7,
      
      D   => DATA_OUT
      );

-- ***** LINEBUFFERS AND VIDEO OUTPUT *****
    
    --steering mux between engines and output buffers
    
    buffer0Steering: engineBufferAttach
        PORT MAP (
            bufferSelect           => buffer0Select,
            sel_0_write_address    => text_write_address,
            sel_0_write_strobe     => text_write_strobe,
            sel_0_write_data       => text_write_data,
            sel_1_write_address    => tile_2_write_address,
            sel_1_write_strobe     => tile_2_write_strobe,
            sel_1_write_data       => tile_2_write_data,
            buffer_write_address   => buffer_0_write_address,
            buffer_write_strobe    => buffer_0_write_strobe,
            buffer_write_data      => buffer_0_write_data
       );
    
    buffer1Steering: engineBufferAttach
        PORT MAP (
            bufferSelect           => buffer1Select,
            sel_0_write_address    => tile_1_write_address,
            sel_0_write_strobe     => tile_1_write_strobe,
            sel_0_write_data       => tile_1_write_data,
            sel_1_write_address    => affine_write_address,
            sel_1_write_strobe     => affine_write_strobe,
            sel_1_write_data       => affine_write_data,
            buffer_write_address   => buffer_1_write_address,
            buffer_write_strobe    => buffer_1_write_strobe,
            buffer_write_data      => buffer_1_write_data
       );
       
    buffer2Steering: engineBufferAttach3
        PORT MAP (
            bufferSelect           => buffer2Select,
            sel_0_write_address    => tile_2_write_address,
            sel_0_write_strobe     => tile_2_write_strobe,
            sel_0_write_data       => tile_2_write_data,
            sel_1_write_address    => sprite_write_address,
            sel_1_write_strobe     => sprite_write_strobe,
            sel_1_write_data       => sprite_write_data,
            sel_2_write_address    => tile_1_write_address,
            sel_2_write_strobe     => tile_1_write_strobe,
            sel_2_write_data       => tile_1_write_data,
            buffer_write_address   => buffer_2_write_address,
            buffer_write_strobe    => buffer_2_write_strobe,
            buffer_write_data      => buffer_2_write_data
       );
       
    buffer3Steering: engineBufferAttach3
        PORT MAP (
            bufferSelect           => buffer3Select,
            sel_0_write_address    => sprite_write_address,
            sel_0_write_strobe     => sprite_write_strobe,
            sel_0_write_data       => sprite_write_data,
            sel_1_write_address    => bitmap_write_address,
            sel_1_write_strobe     => bitmap_write_strobe,
            sel_1_write_data       => bitmap_write_data,
            sel_2_write_address    => tile_2_write_address,
            sel_2_write_strobe     => tile_2_write_strobe,
            sel_2_write_data       => tile_2_write_data,
            buffer_write_address   => buffer_3_write_address,
            buffer_write_strobe    => buffer_3_write_strobe,
            buffer_write_data      => buffer_3_write_data
       );
       
    --instantiate the line buffers
    lineBuffers: line_buffers
        PORT MAP (
            CLKW                => CLK100M,
            CLKR                => CLK100M,
            SWAP_BUFFERS        => bufferSwap,
            LAYER_ENABLE        => layerEnable,
            WRITE_ADDRESS_0     => buffer_0_write_address,
            WE_0                => buffer_0_write_strobe,
            DATA_IN_0           => buffer_0_write_data,
            WRITE_ADDRESS_1     => buffer_1_write_address,
            WE_1                => buffer_1_write_strobe,
            DATA_IN_1           => buffer_1_write_data,
            WRITE_ADDRESS_2     => buffer_2_write_address,
            WE_2                => buffer_2_write_strobe,
            DATA_IN_2           => buffer_2_write_data,
            WRITE_ADDRESS_3     => buffer_3_write_address,
            WE_3                => buffer_3_write_strobe,
            DATA_IN_3           => buffer_3_write_data,
            READ_ADDRESS        => bufferReadAddress,
            READ_DATA           => pixelColor
        );
          
    tempX <= std_logic_vector(to_unsigned(xaddress, 10));
    
    -- signal delays for video output
    PROCESS(CLK25M,screen_area,hsync,vsync)
        VARIABLE screen_area_delayed              : STD_LOGIC;
        VARIABLE hsync_delayed                    : STD_LOGIC;
        VARIABLE vsync_delayed                    : STD_LOGIC;
    BEGIN
        IF RISING_EDGE(CLK25M) THEN
            screen_area_delayed := screen_area;
            hsync_delayed := hsync;
            vsync_delayed := vsync;
            bufferReadAddress <= to_integer(unsigned(tempX(9 downto 1)));
        END IF;
        
        IF RISING_EDGE(CLK25M) THEN
            screen_area_delayed2 <= screen_area_delayed;
            hsync_delayed2 <= hsync_delayed;
            vsync_delayed2 <= vsync_delayed;
            bufferReadAddressDelayed <= bufferReadAddress;
        END IF;
    END PROCESS;
    
    COMBINED_SYNC <= (hsync_delayed2,vsync_delayed2);
    
    window_effect_gen : windowed_effects
        PORT MAP (
            CLK                 => CLK25M,
            CONTROL_BITS        => effect_control_bits,
            R_BLANK_VALUE       => effect_blank_value_R,
            G_BLANK_VALUE       => effect_blank_value_G,
            B_BLANK_VALUE       => effect_blank_value_B,
            R_VALUE             => effect_value_R,
            G_VALUE             => effect_value_G,
            B_VALUE             => effect_value_B,
            WINDOW_START_0      => effect_window_start_1,
            WINDOW_STOP_0       => effect_window_stop_1,
            WINDOW_START_1      => effect_window_start_2,
            WINDOW_STOP_1       => effect_window_stop_2,
            --X_ADDRESS           => bufferReadAddressDelayed,
            X_ADDRESS           => bufferReadAddress,
            COLOR_IN_RED_BITS   => pixelDataRed,
            COLOR_IN_GREEN_BITS => pixelDataGreen,
            COLOR_IN_BLUE_BITS  => pixelDataBlue,
            COLOR_OUT_RED_BITS  => pixelDataRed2,
            COLOR_OUT_GREEN_BITS=> pixelDataGreen2,
            COLOR_OUT_BLUE_BITS => pixelDataBlue2
        );

    --TODO: audio on the HDMI output?
    
    --instantiate the tmds encoders
    tmdsRed: tmds_encoder
        PORT MAP (clk => CLK25M,
                  disp_ena => screen_area_delayed2,
                  control => ('0','0'),
                  d_in => pixelDataRed2,
                  q_out => encodedDataRed);
   
    tmdsGreen: tmds_encoder
        PORT MAP (clk => CLK25M,
                  disp_ena => screen_area_delayed2,
                  control => ('0','0'),
                  d_in => pixelDataGreen2,
                  q_out => encodedDataGreen);
   
    tmdsBlue: tmds_encoder
        PORT MAP (clk => CLK25M,
                  disp_ena => screen_area_delayed2,
                  control => COMBINED_SYNC,
                  d_in => pixelDataBlue2,
                  q_out => encodedDataBlue);
    
    --hdmi data output steering
    PROCESS(CLK25M, CLK50M,encodedDataBlue,encodedDataGreen,encodedDataRed)
    BEGIN
       IF RISING_EDGE(CLK50M) THEN
           IF (CLK25M = '0') THEN
                HDMI0_DATA <= encodedDataBlue(4 downto 0);
                HDMI1_DATA <= encodedDataGreen(4 downto 0);
                HDMI2_DATA <= encodedDataRed(4 downto 0);
                HDMICLK_DATA <= (others => '0');
           ELSE
                HDMI0_DATA <= encodedDataBlue(9 downto 5);
                HDMI1_DATA <= encodedDataGreen(9 downto 5);
                HDMI2_DATA <= encodedDataRed(9 downto 5);
                HDMICLK_DATA <= (others => '1');
           END IF;
       END IF;
    END PROCESS;
   
   --debugging output
   --DEBUG_OUT <= enginesRun & screen_area & enginesResetScreen & enginesResetLine & sprite_completed & tile_2_completed & tile_1_completed & text_completed;
   DEBUG_OUT <= sprite_engine_debug;
   
END behavior;