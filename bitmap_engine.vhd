LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY bitmap_engine IS
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
END bitmap_engine;

--BITMAP MODE:
--bit 2: resolution
--          0: 160 x 120
--          1: 320 x 240
--bits 0-1: color depth
--          00: 1 bit
--          01: 2 bits
--          10: 4 bits
--          11: 8 bits

--Possible future TODO: per-block palette mode:

--160x120 1bpp: each 4x4 block will have 2 bytes controlling palette
--  2400 bytes used by bitmap, 600 used for color blocks, 8192 available

--160x120 2bpp: each 4x4 block will have 4 bytes controlling palette
--  4800 bytes used by bitmap, 1200 used for color blocks, 8192 available

--160x120 4bpp: each 8x8 block will have 16 bytes controlling palette
--  9600 bytes used by bitmap, 4800 used for color blocks, 16384 available

--160x120 8bpp: no color blocks needed

--320x240 1bpp: each 8x8 block will have 2 bytes controlling palette
--  9600 bytes used by bitmap, 2400 used for color blocks, 16384 available

--320x240 2bpp: each 4x4 block will have 4 bytes controlling palette
--  19200 bytes used by bitmap, 4800 used for color blocks, 24576 available

--320x240 4bpp: each 4x4 block will have 16 bytes controlling palette
--  38400 bytes used by bitmap, 19200 used for color blocks, 40960 available - this doesn't fit, it will require 7 blocks

--320x240 8bpp: no color blocks needed

ARCHITECTURE behavioral OF bitmap_engine IS
    type state_type is (state_reset_screen,
                        state_reset_line,
                        state_read_delay_1,
                        state_read_delay_2,
                        state_read_delay_3,
                        state_pixels_write,
                        state_pixels_write_pause,
                        state_pixels_write_again,
                        state_pixels_pause_again,
                        state_pixels_write_done,
                        state_next_pixel,
                        state_next_line,
                        state_line_done);

    SIGNAL source_read_address: integer range 0 to 131071;
    SIGNAL next_source_read_address: integer range 0 to 131071;

    SIGNAL xaddress         : integer range 0 to 319 := 0;
    SIGNAL next_xaddress    : integer range 0 to 319 := 0; 
    
    SIGNAL lineToDrawVec    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL next_we          : STD_LOGIC := '0';
    
    SIGNAL line_complete    : STD_LOGIC := '0';
    
    SIGNAL step             : state_type := state_reset_screen;
    SIGNAL next_step        : state_type := state_reset_screen;
    
    SIGNAL next_done        : STD_LOGIC;
    
    SIGNAL pixelColor       : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    
    SIGNAL HiRes            : STD_LOGIC;
    SIGNAL colorDepth       : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    SIGNAL bitstep                  : integer range 0 to 7 := 0;
    SIGNAL next_bitstep             : integer range 0 to 7 := 0;
    SIGNAL next_bit_when_ready      : integer range 0 to 7 := 0;
    
    SIGNAL readNextByte             : STD_LOGIC;
    
    SIGNAL bitmapData               : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    type xaddress_action is (xaddress_zero,
                             xaddress_keep,
                             xaddress_step);
                                    
    type source_addr_action is (source_addr_zero,
                                source_addr_keep,
                                source_addr_step,
                                source_addr_prior_line);
                             
    type bitstep_action is (bitstep_zero,
                            bitstep_keep,
                            bitstep_next);
                            
    SIGNAL bitmap_trans_flag_int    : STD_LOGIC;
    SIGNAL bitmap_trans_color_int   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL bitmap_layer_int         : STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL COPPER_ADDR              : integer range 0 to 7;
    
    SIGNAL color0                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color1                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color2                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color3                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color4                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color5                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color6                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color7                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color8                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color9                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color10                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color11                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color12                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color13                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color14                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL color15                  : STD_LOGIC_VECTOR(7 DOWNTO 0);

    COMPONENT bitmap_palette_memory IS
        PORT(
            CLK                         : IN  STD_LOGIC;
            ADDR_1                      : IN  integer range 0 to 15;
            WRITE_DATA_1                : IN  STD_LOGIC_VECTOR(7 downto 0);
            WRITE_STROBE_1              : IN  STD_LOGIC;
            READ_DATA_1                 : OUT STD_LOGIC_VECTOR(7 downto 0);
            ADDR_2                      : IN  integer range 0 to 7;
            WRITE_DATA_2                : IN  STD_LOGIC_VECTOR(15 downto 0);
            WRITE_STROBE_2              : IN  STD_LOGIC;
            BYTE_FLAGS_2                : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            READ_DATA_2                 : OUT STD_LOGIC_VECTOR(15 downto 0);
            C0                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C1                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C2                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C3                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C4                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C5                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C6                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C7                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C8                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C9                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C10                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C11                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C12                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C13                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C14                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            C15                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
            );
    END COMPONENT bitmap_palette_memory;     
    
BEGIN
    PROCESS(LINE_TO_DRAW,BITMAP_MODE,CLK100M)
    BEGIN
        IF RISING_EDGE(CLK100M)THEN
            HiRes                    <= BITMAP_MODE(2);
            colorDepth               <= BITMAP_MODE(1 downto 0);
            lineToDrawVec            <= STD_LOGIC_VECTOR(to_unsigned(LINE_TO_DRAW,8));
            bitmap_trans_flag_int    <= BITMAP_TRANS_FLAG;
            bitmap_trans_color_int   <= BITMAP_TRANS_COLOR;
            bitmap_layer_int         <= BITMAP_LAYER;
        END IF;
    END PROCESS;
    
    PROCESS(BITMAP_READ_DATA,CLK100M)
    BEGIN
        IF RISING_EDGE(CLK100M)THEN
            bitmapData <= BITMAP_READ_DATA;
        END IF;
    END PROCESS;
    
    --color palette values stored locally in registers rather than using a BRAM.
    
    COPPER_ADDR <= to_integer(unsigned(COPPER_ADDRESS_IN));
    
    cpmem : bitmap_palette_memory
        PORT MAP (
            CLK             => CLK100M,
            ADDR_1          => CPU_ADDR,
            WRITE_DATA_1    => CPU_WDATA,
            WRITE_STROBE_1  => CPU_WE,
            READ_DATA_1     => CPU_RDATA,
            ADDR_2          => COPPER_ADDR,
            WRITE_DATA_2    => COPPER_DATA_IN,
            WRITE_STROBE_2  => COPPER_WRITE_STROBE,
            BYTE_FLAGS_2    => COPPER_BYTE_FLAGS,
            READ_DATA_2     => COPPER_DATA_OUT,
            C0              => color0,
            C1              => color1,
            C2              => color2,
            C3              => color3,
            C4              => color4,
            C5              => color5,
            C6              => color6,
            C7              => color7,
            C8              => color8,
            C9              => color9,
            C10             => color10,
            C11             => color11,
            C12             => color12,
            C13             => color13,
            C14             => color14,
            C15             => color15
            );
    
    --Line complete flag generation
    PROCESS(xaddress)
    BEGIN
        --IF xaddress = 319 THEN
        IF xaddress = 320 THEN
            line_complete <= '1';
        ELSE
            line_complete <= '0';
        END IF;
    END PROCESS;
    
    --Color generation, taking color depth and palette into account
    --Also generates the next bit clock value and the nead next byte flag
    PROCESS(CLK100M,colorDepth,bitstep,bitmapData,
            color0,color1,color2,color3,color4,color5,color6,color7,
            color8,color9,color10,color11,color12,color13,color14,color15)
        VARIABLE pixelIndex       : STD_LOGIC_VECTOR(3 DOWNTO 0);
    BEGIN
        
        IF RISING_EDGE(CLK100M)THEN
        
        CASE colorDepth IS
            WHEN "00" => --1 bit color
                CASE bitstep IS
                    WHEN 0 =>
                        pixelIndex := "000" & bitmapData(7);
                        readNextByte <= '0';
                        next_bit_when_ready <= 1;
                    WHEN 1 =>
                        pixelIndex := "000" & bitmapData(6);
                        readNextByte <= '0';
                        next_bit_when_ready <= 2;
                    WHEN 2 =>
                        pixelIndex := "000" & bitmapData(5);
                        readNextByte <= '0';
                        next_bit_when_ready <= 3;
                    WHEN 3 =>
                        pixelIndex := "000" & bitmapData(4);
                        readNextByte <= '0';
                        next_bit_when_ready <= 4;
                    WHEN 4 =>
                        pixelIndex := "000" & bitmapData(3);
                        readNextByte <= '0';
                        next_bit_when_ready <= 5;
                    WHEN 5 =>
                        pixelIndex := "000" & bitmapData(2);
                        readNextByte <= '0';
                        next_bit_when_ready <= 6;
                    WHEN 6 =>
                        pixelIndex := "000" & bitmapData(1);
                        readNextByte <= '0';
                        next_bit_when_ready <= 7;
                    WHEN 7 =>
                        pixelIndex := "000" & bitmapData(0);
                        readNextByte <= '1';
                        next_bit_when_ready <= 0;
                    WHEN OTHERS =>
                        pixelIndex := "0000";
                        readNextByte <= '0';
                        next_bit_when_ready <= 0;
                END CASE;
            WHEN "01" => --2 bit color
                CASE bitstep IS
                    WHEN 0 =>
                        pixelIndex := "00" & bitmapData(7 downto 6);
                        readNextByte <= '0';
                        next_bit_when_ready <= 1;
                    WHEN 1 =>
                        pixelIndex := "00" & bitmapData(5 downto 4);
                        readNextByte <= '0';
                        next_bit_when_ready <= 2;
                    WHEN 2 =>
                        pixelIndex := "00" & bitmapData(3 downto 2);
                        readNextByte <= '0';
                        next_bit_when_ready <= 3;
                    WHEN 3 =>
                        pixelIndex := "00" & bitmapData(1 downto 0);
                        readNextByte <= '1';
                        next_bit_when_ready <= 0;
                    WHEN OTHERS =>
                        pixelIndex := "0000";
                        readNextByte <= '0';
                        next_bit_when_ready <= 0;
                END CASE;
            WHEN "10" => --4 bit color
                CASE bitstep IS
                    WHEN 0 =>
                        pixelIndex := bitmapData(7 downto 4);
                        readNextByte <= '0';
                        next_bit_when_ready <= 1;
                    WHEN 1 =>
                        pixelIndex := bitmapData(3 downto 0);
                        readNextByte <= '1';
                        next_bit_when_ready <= 0;
                    WHEN OTHERS =>
                        pixelIndex := "0000";
                        readNextByte <= '0';
                        next_bit_when_ready <= 0;
                END CASE;
            WHEN "11" => --8 bit color
                pixelIndex := "0000";
                readNextByte <= '1';
                next_bit_when_ready <= 0;
            WHEN OTHERS =>
                pixelIndex := "0000";
                readNextByte <= '1';
                next_bit_when_ready <= 0;
        END CASE;
        
        END IF;
        
        --look up color in the palette (except for 8 bit color)
        IF colorDepth = "11" THEN
            pixelColor <= bitmapData;
        ELSE
            CASE pixelIndex IS
                WHEN "0000" =>
                    pixelColor <= color0;
                WHEN "0001" =>
                    pixelColor <= color1;
                WHEN "0010" =>
                    pixelColor <= color2;
                WHEN "0011" =>
                    pixelColor <= color3;
                WHEN "0100" =>
                    pixelColor <= color4;
                WHEN "0101" =>
                    pixelColor <= color5;
                WHEN "0110" =>
                    pixelColor <= color6;
                WHEN "0111" =>
                    pixelColor <= color7;
                WHEN "1000" =>
                    pixelColor <= color8;
                WHEN "1001" =>
                    pixelColor <= color9;
                WHEN "1010" =>
                    pixelColor <= color10;
                WHEN "1011" =>
                    pixelColor <= color11;
                WHEN "1100" =>
                    pixelColor <= color12;
                WHEN "1101" =>
                    pixelColor <= color13;
                WHEN "1110" =>
                    pixelColor <= color14;
                WHEN "1111" =>
                    pixelColor <= color15;
                WHEN OTHERS =>
                    pixelColor <= color0;
            END CASE;
        END IF;
        
    END PROCESS;
    
    --State engine non-clocked process
    --Generates the next values for state variables
    PROCESS(CLK100M,step,RESET_SCREEN,RESET_LINE,RUN,HiRes,line_complete,lineToDrawVec,xaddress,
            source_read_address,bitstep,next_bit_when_ready,readNextByte,colorDepth)
        VARIABLE next_xaddress_action       : xaddress_action;
        VARIABLE next_source_addr_action    : source_addr_action;
        VARIABLE next_bitstep_action        : bitstep_action;
        VARIABLE resetHold                  : STD_LOGIC;
    BEGIN
        resetHold := RESET_LINE OR NOT RUN;
    
        CASE step IS
            WHEN state_reset_screen =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_zero;
                next_xaddress_action := xaddress_zero;
                next_source_addr_action := source_addr_zero;
                
                IF RESET_SCREEN THEN
                    next_step <= state_reset_screen;
                ELSE
                    next_step <= state_reset_line;
                END IF;
            
            WHEN state_reset_line =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_zero;
                next_xaddress_action := xaddress_zero;
                next_source_addr_action := source_addr_keep;
                
                IF RESET_SCREEN THEN
                    next_step <= state_reset_screen;
                ELSIF resetHold THEN
                    next_step <= state_reset_line;
                ELSE
                    next_step <= state_read_delay_1;
                END IF;
                
            WHEN state_read_delay_1 =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_keep;
                next_xaddress_action := xaddress_keep;
                next_source_addr_action := source_addr_keep;
                
                next_step <= state_read_delay_2;
                
            WHEN state_read_delay_2 =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_keep;
                next_xaddress_action := xaddress_keep;
                next_source_addr_action := source_addr_keep;
                
                next_step <= state_read_delay_3;
                
            WHEN state_read_delay_3 =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_keep;
                next_xaddress_action := xaddress_keep;
                next_source_addr_action := source_addr_keep;
                
                next_step <= state_pixels_write;
    
            WHEN state_pixels_write =>
                next_we <= '1';
                next_done <= '0';
                
                next_bitstep_action := bitstep_keep;
                next_xaddress_action := xaddress_keep;
                next_source_addr_action := source_addr_keep;
                    
                next_step <= state_pixels_write_pause;
                    
            WHEN state_pixels_write_pause =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_keep;
                next_xaddress_action := xaddress_step;
                next_source_addr_action := source_addr_keep;
                
                IF HiRes = '0' THEN
                    next_step <= state_pixels_write_again;
                ELSE
                    next_step <= state_pixels_write_done;
                END IF;
            
            WHEN state_pixels_write_again =>
                next_we <= '1';
                next_done <= '0';
                
                next_bitstep_action := bitstep_keep;
                next_xaddress_action := xaddress_keep;
                next_source_addr_action := source_addr_keep;
                    
                next_step <= state_pixels_pause_again;
                
            WHEN state_pixels_pause_again =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_keep;
                next_xaddress_action := xaddress_step;
                next_source_addr_action := source_addr_keep;
                    
                next_step <= state_pixels_write_done;
                    
            WHEN state_pixels_write_done =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_keep;
                next_xaddress_action := xaddress_keep;
                
                IF line_complete THEN
                    next_step <= state_next_line;
                    next_source_addr_action := source_addr_step;
                ELSE
                    next_step <= state_next_pixel;
                    next_source_addr_action := source_addr_keep;
                END IF;
            
            WHEN state_next_pixel =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_next;
                next_xaddress_action := xaddress_keep;
                
                IF readNextByte THEN
                    next_source_addr_action := source_addr_step;
                    next_step <= state_read_delay_1;
                ELSE
                    next_source_addr_action := source_addr_keep;
                    next_step <= state_read_delay_3;
                END IF;
                
            WHEN state_next_line =>
                next_we <= '0';
                next_done <= '0';
                
                next_bitstep_action := bitstep_zero;
                next_xaddress_action := xaddress_zero;
                
                IF HiRes = '0' AND lineToDrawVec(0)='0' THEN
                    next_source_addr_action := source_addr_prior_line;
                ELSE
                    next_source_addr_action := source_addr_keep;
                END IF;
                
                next_step <= state_line_done;
                
            WHEN state_line_done =>
                next_we <= '0';
                next_done <= '1';
                
                next_bitstep_action := bitstep_zero;
                next_xaddress_action := xaddress_zero;
                next_source_addr_action := source_addr_keep;
                
                IF RESET_SCREEN THEN
                    next_step <= state_reset_screen;
                ELSIF resetHold THEN
                    next_step <= state_reset_line;
                ELSE
                    next_step <= state_line_done;
                END IF;
                    
            --WHEN OTHERS =>
            --    next_we <= '0';
            --    next_done <= '0';
                
            --    next_bitstep_action := bitstep_zero;
            --    next_xaddress_action := xaddress_zero;
            --    next_source_addr_action := source_addr_keep;
                    
            --    next_step <= state_reset_screen;
        END CASE;
        
        CASE next_xaddress_action IS
            WHEN xaddress_zero =>
                next_xaddress <= 0;
            WHEN xaddress_keep =>
                next_xaddress <= xaddress;
            WHEN xaddress_step =>
                next_xaddress <= xaddress + 1;
            --WHEN OTHERS =>
            --    next_xaddress <= xaddress;
        END CASE;
        
        CASE next_source_addr_action IS
            WHEN source_addr_zero =>
                next_source_read_address <= 0;
            WHEN source_addr_keep =>
                next_source_read_address <= source_read_address;
            WHEN source_addr_step =>
                next_source_read_address <= source_read_address + 1;
            WHEN source_addr_prior_line =>
                CASE colorDepth IS
                    WHEN "00" => --1 bit color
                        next_source_read_address <= source_read_address - 20;
                    WHEN "01" => --2 bit color
                        next_source_read_address <= source_read_address - 40;
                    WHEN "10" => --4 bit color
                        next_source_read_address <= source_read_address - 80;
                    WHEN "11" => --8 bit color
                        next_source_read_address <= source_read_address - 160;
                    WHEN OTHERS =>
                        next_source_read_address <= source_read_address;
                END CASE;
            --WHEN OTHERS =>
            --    next_source_read_address <= 0;
        END CASE;
        
        CASE next_bitstep_action IS
            WHEN bitstep_zero =>
                next_bitstep <= 0;
            WHEN bitstep_keep =>
                next_bitstep <= bitstep;
            WHEN bitstep_next =>
                next_bitstep <= next_bit_when_ready;   
            --WHEN OTHERS =>
            --    next_bitstep <= 0;
        END CASE;
        
    END PROCESS;
    
    --State engine clocked process
    --loads the next state variables on the clock edge
    PROCESS(CLK100M,next_step,next_xaddress,next_source_read_address,next_bitstep,next_we,next_done)
    BEGIN
        IF RISING_EDGE(CLK100M)THEN
            step <= next_step;
            xaddress <= next_xaddress;
            source_read_address <= next_source_read_address;
            bitstep <= next_bitstep;
            BUFFER_WRITE_STROBE <= next_we;
            DONE <= next_done;
        END IF;
    END PROCESS;
    
    --generate the buffer write data, depending on transparency
    PROCESS(pixelColor,bitmap_trans_color_int,bitmap_trans_flag_int,bitmap_layer_int)
    BEGIN
        if (pixelColor = bitmap_trans_color_int) AND (bitmap_trans_flag_int = '1') THEN
            BUFFER_WRITE_DATA <= "00" & pixelColor;
        ELSE
            BUFFER_WRITE_DATA <= bitmap_layer_int & pixelColor;
        END IF;
    END PROCESS;
    
    BUFFER_WRITE_ADDRESS <= xaddress;
    BITMAP_READ_ADDRESS <= source_read_address;
    
END behavioral;