LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

    --Note: at the moment, 4 bpp sprites can only access 32K of the sprite graphics memory.
    --Might try to see if this could be fixed in the future.
            
ENTITY sprite_blitter IS
    PORT(
        CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        RESET_SCREEN            : IN  STD_LOGIC;
        RESET_LINE              : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        FIFO_EMPTY              : IN  STD_LOGIC;
        FIFO_READ_DATA          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
        SPRITE_GFX_DATA_IN      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        FIFO_READ               : OUT STD_LOGIC;
        SPRITE_GFX_READ_ADDRESS : OUT integer range 0 to 65535;
        COLLISION_WRITE_ADDRESS : OUT integer range 0 to 127;
        COLLISION_WRITE_STROBE  : OUT STD_LOGIC;
        COLLISION_WRITE_DATA    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLLISION_READ_DATA     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        COLLISION_INTERRUPTS    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 319;
        BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE     : OUT STD_LOGIC;
        DEBUG_OUT               : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        COLLISION_BUFF_READY    : IN  STD_LOGIC;
        COL_BUFF_ADDRESS        : OUT integer range 0 to 511;
        COL_BUFF_WRITE_DATA     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        COL_BUFF_READ_DATA      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        COL_BUFF_WRITE_STROBE   : OUT STD_LOGIC
    );
END sprite_blitter;

ARCHITECTURE behavioral OF sprite_blitter IS

    SIGNAL blitStartAddress         : STD_LOGIC_VECTOR(16 DOWNTO 0);
    SIGNAL blitIncrementDirection   : STD_LOGIC;
    SIGNAL blitIncrement            : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL blitXposition            : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL blitBgColor              : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL blitLayer                : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL blitSize                 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL blitCollBits             : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL blitCollEnable           : STD_LOGIC;
    SIGNAL blitSpriteID             : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL colorDepth               : STD_LOGIC;
    SIGNAL palette                  : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    type blit_state_type is (blit_reset,
                             blit_clean_loop_1,
                             blit_clean_loop_2,
                             blit_wait_fifo,
                             blit_read_fifo,
                             blit_read_fifo_1,
                             blit_read_fifo_1a,
                             --blit_read_fifo_1b,
                             blit_read_fifo_2,
                             blit_loop_1,
                             blit_loop_2,
                             blit_loop_write,
                             blit_loop_write_col,
                             blit_loop_3);
   
    SIGNAl blit_step                : blit_state_type := blit_reset;
    SIGNAl next_blit_step           : blit_state_type := blit_reset;
    
    type line_address_action is (address_zero,
                                 address_preset,
                                 address_load,
                                 address_keep,
                                 address_increment,
                                 address_decrement);
    
    type col_data_action is (coldata_zero,
                             coldata_read_sprite,
                             coldata_keep,
                             coldata_or_prior);
   
    type bitmap_address_action is (baddress_zero,
                                   baddress_load,
                                   baddress_keep,
                                   baddress_step);                      
                                  
    type blit_count_action is (blit_count_zero,
                               blit_count_load,
                               blit_count_keep,
                               blit_count_decrement);
                            
    SIGNAL blit_count               : integer range 0 to 63;
    SIGNAL next_blit_count          : integer range 0 to 63;
    
    SIGNAL bitmap_read_address      : integer range 0 to 131071;
    SIGNAL next_bitmap_read_address : integer range 0 to 131071;
    
    SIGNAL line_write_address       : integer range 0 to 1023;
    SIGNAL next_line_write_address  : integer range 0 to 1023;
    
    SIGNAL blit_increment           : integer range 0 to 127;
    
    SIGNAL next_line_write          : STD_LOGIC;
    SIGNAL line_write               : STD_LOGIC;
    
    SIGNAL bit_not_transparent      : STD_LOGIC;
    
    SIGNAL fifoRead                 : STD_LOGIC;
    SIGNAL next_fifo_read           : STD_LOGIC; 
    
    SIGNAL write_blank_data         : STD_LOGIC;
    SIGNAL next_write_blank_data    : STD_LOGIC;
    
    SIGNAL collision_data           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL next_collision_data      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL collision_flags_write        : STD_LOGIC;
    SIGNAL next_collision_flags_write   : STD_LOGIC;
    
    SIGNAL reset                       : STD_LOGIC;
    
    SIGNAL care_about_collisions    : STD_LOGIC;
    
    SIGNAL blitSizeInt              : integer range 0 to 63;
    SIGNAL bitmap_read_address_bits : STD_LOGIC_VECTOR(16 DOWNTO 0);
    
    SIGNAL pixel_adjusted           : STD_LOGIC_VECTOR(7 DOWNTO 0);
        
BEGIN

    --read 64 bits of data from the FIFO:
    
    --Bitmap source address: 17 bits (only 16 bits will be used, lower bit controls high/low nibble in 4 bit color depth mode)
    blitStartAddress <= FIFO_READ_DATA(16 downto 0);
    
    --Source increment and direction: 5 bits (source address change per pixel)
    blitIncrementDirection <= FIFO_READ_DATA(17); --(0 = negative increment, 1 = positive increment)
    blitIncrement <= FIFO_READ_DATA(20 downto 18); --(000 = 8, 001 = 16, 010 = 32, 011 = 64, 1xx = 1)
    
    --Target address: 10 bits (signed, -512 to +511, starting X position in line buffer)
    blitXposition <= FIFO_READ_DATA(30 downto 21);
    
    --Transparency color: 8 bits (pixels matching this color will not be copied)
    blitBgColor <= FIFO_READ_DATA(38 downto 31);
    
    --Priority: 2 bits (per-pixel layer encoding)
    blitLayer <= FIFO_READ_DATA(40 downto 39);
    
    --Length of transfer: 2 bits (00 = 8px, 01 = 16px, 10 = 32px, 11 = 64px)
    blitSize <= FIFO_READ_DATA(42 downto 41);
    
    --sprite palette (for 4 bit sprites): 4 bits
    palette <= FIFO_READ_DATA(46 downto 43);
    
    --Collision flags: 8 bits (bit field for checking sprite-to-sprite collisions)
    blitCollBits <= FIFO_READ_DATA(54 downto 47);
    
    --Sprite ID: 7 bits (for logging sprite collisions)
    blitSpriteID <= FIFO_READ_DATA(61 downto 55);
    
    --Collision check enable (0 = don't check, 1 = check)
    blitCollEnable <= FIFO_READ_DATA(62);
    
    --color depth  (0 = 8 bit, 1 = 4 bit)
    colorDepth <= FIFO_READ_DATA(63);
    
    --Generate the blit size value.
    
    PROCESS(blitSize)
    BEGIN
        CASE blitSize IS
            WHEN "00" =>    --8x8
                blitSizeInt <= 7;
            WHEN "01" =>    --16x16
                blitSizeInt <= 15;
            WHEN "10" =>    --32x32
                blitSizeInt <= 31;
            WHEN "11" =>    --64x64
                blitSizeInt <= 63;
            WHEN others =>
                blitSizeInt <= 7;
        END CASE;
    END PROCESS;
    
    --check if we care about collisions at all
    PROCESS(blitCollEnable,blitCollBits)
    BEGIN
        IF (blitCollEnable = '0') AND (blitCollBits = "00000000") THEN
            care_about_collisions <= '0';
        ELSE
            care_about_collisions <= '1';
        END IF;
    END PROCESS;
    
    --Generate the source address increment value
    PROCESS(blitIncrement)
    BEGIN
        CASE blitIncrement IS
            WHEN "000" =>
                blit_increment <= 8;
            WHEN "001" =>
                blit_increment <= 16;
            WHEN "010" =>
                blit_increment <= 32;
            WHEN "011" =>
                blit_increment <= 64;
            WHEN "100" =>
                blit_increment <= 1;
            WHEN "101" =>
                blit_increment <= 1;
            WHEN "110" =>
                blit_increment <= 1;
            WHEN "111" =>
                blit_increment <= 1;
            WHEN OTHERS =>
                blit_increment <= 1;
        END CASE;
    END PROCESS;
    
    --Adjust pixel data for palette mode
    PROCESS(CLK100M,colorDepth,bitmap_read_address_bits,pixel_adjusted,SPRITE_GFX_DATA_IN,palette)
    BEGIN
        --IF RISING_EDGE(CLK100M) THEN --latch pixel data in here
            IF (colorDepth='1') THEN
                --4 bit color mode
                IF bitmap_read_address_bits(0) = '0' THEN
                    pixel_adjusted <= palette & SPRITE_GFX_DATA_IN(7 downto 4);
                ELSE
                    pixel_adjusted <= palette & SPRITE_GFX_DATA_IN(3 downto 0);
                END IF;
            ELSE
                --8 bit color mode
                pixel_adjusted <= SPRITE_GFX_DATA_IN;
            END IF;
        --END IF;
    END PROCESS;
    
    --Check if this bit is transparent
    PROCESS(pixel_adjusted,blitBgColor)
    BEGIN
        IF (pixel_adjusted = blitBgColor) THEN
            bit_not_transparent <= '0';
        ELSE
            bit_not_transparent <= '1';
        END IF;
    END PROCESS;
    
    PROCESS(CLK25M)
    BEGIN
        IF RISING_EDGE(CLK25M) THEN
            reset <= RESET_SCREEN OR RESET_LINE OR NOT RUN;
        END IF;
    END PROCESS;
    
    --Blitter state engine
    PROCESS(blit_step,RUN,CLK100M,FIFO_EMPTY,reset,line_write_address,bit_not_transparent,
            COLLISION_BUFF_READY,care_about_collisions,blit_count,blitXposition,line_write_address,
            COLLISION_READ_DATA,collision_data,blitStartAddress,bitmap_read_address,blitIncrementDirection,
            blit_increment,blitSizeInt,blit_count,COL_BUFF_READ_DATA)
        VARIABLE next_address_action         : line_address_action;
        VARIABLE next_coldata_action         : col_data_action;
        VARIABLE next_baddr_action           : bitmap_address_action;
        VARIABLE next_blit_count_action      : blit_count_action;
        --VARIABLE reset                       : STD_LOGIC;
        VARIABLE can_start                   : STD_LOGIC;
                 
    BEGIN
        --reset := RESET_SCREEN OR RESET_LINE OR NOT RUN;
        can_start := (NOT FIFO_EMPTY) AND (COLLISION_BUFF_READY OR (NOT care_about_collisions));
        --can_start := NOT FIFO_EMPTY;
        
        CASE blit_step IS
            WHEN blit_reset =>
                --next_fifo_read <= NOT (fifoRead OR FIFO_EMPTY); --toggle to clear FIFO
                next_fifo_read <= '0';
                next_line_write <= '0';
                next_write_blank_data <= '1';
                next_collision_flags_write <= '0';
                
                next_address_action := address_preset;
                next_coldata_action := coldata_zero;
                next_baddr_action := baddress_zero;
                next_blit_count_action := blit_count_zero;
                
                IF (reset) THEN
                    next_blit_step <= blit_reset;
                ELSE
                    next_blit_step <= blit_clean_loop_1;
                END IF;
                
            WHEN blit_clean_loop_1 =>
                next_fifo_read <= '0';
                next_line_write <= '1';
                next_write_blank_data <= '1';
                next_collision_flags_write <= '0';
                
                next_address_action := address_keep;
                next_coldata_action := coldata_zero;
                next_baddr_action := baddress_zero;
                next_blit_count_action := blit_count_zero;
                
                IF line_write_address = 0 THEN
                    next_blit_step <= blit_wait_fifo;
                ELSE
                    next_blit_step <= blit_clean_loop_2;
                END IF;
                
            WHEN blit_clean_loop_2 =>
                next_fifo_read <= '0';
                next_line_write <= '0';
                next_write_blank_data <= '1';
                next_collision_flags_write <= '0';
                
                next_address_action := address_decrement;
                next_coldata_action := coldata_zero;
                next_baddr_action := baddress_zero;
                next_blit_count_action := blit_count_zero;
                
                next_blit_step <= blit_clean_loop_1;
                
            WHEN blit_wait_fifo =>
                --next_fifo_read <= can_start;
                next_fifo_read <= '0';
                next_line_write <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_zero;
                next_coldata_action := coldata_zero;
                next_baddr_action := baddress_zero;
                next_blit_count_action := blit_count_zero;
                
                IF (reset) THEN
                    next_blit_step <= blit_reset;
                    --next_fifo_read <= '0';
                ELSIF (can_start) THEN
                    next_blit_step <= blit_read_fifo;
                    --next_fifo_read <= '1';
                ELSE
                    next_blit_step <= blit_wait_fifo;
                    --next_fifo_read <= '0';
                END IF;
                
            WHEN blit_read_fifo => 
                next_fifo_read <= '1';
                next_line_write <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_zero;
                next_coldata_action := coldata_zero;
                next_baddr_action := baddress_zero;
                next_blit_count_action := blit_count_zero;
                
                next_blit_step <= blit_read_fifo_1;
                
            WHEN blit_read_fifo_1 => 
                next_fifo_read <= '0';
                next_line_write <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_zero;
                next_coldata_action := coldata_zero;
                next_baddr_action := baddress_zero;
                next_blit_count_action := blit_count_zero;
                
                next_blit_step <= blit_read_fifo_1a;
                
            WHEN blit_read_fifo_1a => 
                next_fifo_read <= '0';
                next_line_write <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_zero;
                next_coldata_action := coldata_zero;
                next_baddr_action := baddress_zero;
                next_blit_count_action := blit_count_zero;
                
                next_blit_step <= blit_read_fifo_2;
                --next_blit_step <= blit_read_fifo_1b;
                
              /*  
            WHEN blit_read_fifo_1b => 
                next_fifo_read <= '0';
                next_line_write <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_zero;
                next_coldata_action := coldata_zero;
                next_baddr_action := baddress_zero;
                next_blit_count_action := blit_count_zero;
                
                next_blit_step <= blit_read_fifo_2;
                */
                
            WHEN blit_read_fifo_2 =>
                next_line_write <= '0';
                next_fifo_read <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_load;
                next_coldata_action := coldata_read_sprite;
                next_baddr_action := baddress_load;
                next_blit_count_action := blit_count_load;
                
                next_blit_step <= blit_loop_1;
                
            WHEN blit_loop_1 =>
                next_line_write <= '0';
                next_fifo_read <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_keep;
                next_coldata_action := coldata_keep;
                next_baddr_action := baddress_keep;
                next_blit_count_action := blit_count_keep;
                
                next_blit_step <= blit_loop_2;
                
            WHEN blit_loop_2 => 
                next_line_write <= '0';
                next_fifo_read <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_keep;
                next_coldata_action := coldata_or_prior;
                next_baddr_action := baddress_keep;
                next_blit_count_action := blit_count_keep;
                
                IF bit_not_transparent THEN
                    IF care_about_collisions THEN
                        next_blit_step <= blit_loop_write_col;
                    ELSE
                        next_blit_step <= blit_loop_write;
                    END IF;
                ELSE
                    next_blit_step <= blit_loop_3;
                END IF;
                
            WHEN blit_loop_write => 
                next_line_write <= '1';
                next_fifo_read <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_keep;
                next_coldata_action := coldata_keep;
                next_baddr_action := baddress_keep;
                next_blit_count_action := blit_count_keep;
            
                next_blit_step <= blit_loop_3;
            
            WHEN blit_loop_write_col => 
                next_line_write <= '1';
                next_fifo_read <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '1';
                
                next_address_action := address_keep;
                next_coldata_action := coldata_keep;
                next_baddr_action := baddress_keep;
                next_blit_count_action := blit_count_keep;
            
                next_blit_step <= blit_loop_3;
            
            WHEN blit_loop_3 =>
                next_line_write <= '0';
                next_fifo_read <= '0';
                next_write_blank_data <= '0';
                next_collision_flags_write <= '0';
                
                next_address_action := address_increment;
                next_coldata_action := coldata_keep;
                next_blit_count_action := blit_count_decrement;
                next_baddr_action := baddress_step;
                
                IF blit_count = 0 THEN
                    next_blit_step <= blit_wait_fifo;
                ELSE
                    next_blit_step <= blit_loop_1;
                END IF;
            
            --WHEN OTHERS =>
            --    next_fifo_read <= '0';
            --    next_line_write <= '0';
            --    next_write_blank_data <= '1';
            --    next_collision_flags_write <= '0';
            
            --    next_address_action := address_zero;
            --    next_coldata_action := coldata_keep;
            --    next_baddr_action := baddress_zero;
            --    next_blit_count_action := blit_count_keep;
                
            --    next_blit_step <= blit_reset;
                
        END CASE;
        
        CASE next_address_action IS
            WHEN address_zero =>
                next_line_write_address <= 0;
            WHEN address_preset =>
                next_line_write_address <= 319;
            WHEN address_load =>
                next_line_write_address <= to_integer(unsigned(blitXposition));
            WHEN address_keep =>
                next_line_write_address <= line_write_address;
            WHEN address_increment =>
                next_line_write_address <= line_write_address + 1;
            WHEN address_decrement =>
                next_line_write_address <= line_write_address - 1;
            --WHEN OTHERS =>
            --    next_line_write_address <= line_write_address;
        END CASE;
    
        CASE next_coldata_action IS
            WHEN coldata_zero =>
                next_collision_data <= "00000000";
            WHEN coldata_read_sprite =>
                next_collision_data <= COLLISION_READ_DATA;
            WHEN coldata_keep =>
                next_collision_data <= collision_data;
            WHEN coldata_or_prior =>
                next_collision_data <= COL_BUFF_READ_DATA OR collision_data;
            --WHEN OTHERS =>
            --    next_collision_data <= collision_data;
        END CASE;
    
        CASE next_baddr_action IS
            WHEN baddress_zero =>
                next_bitmap_read_address <= 0;
            WHEN baddress_load =>
                next_bitmap_read_address <= to_integer(unsigned(blitStartAddress));
            WHEN baddress_keep =>
                next_bitmap_read_address <= bitmap_read_address;
            WHEN baddress_step =>
                IF blitIncrementDirection = '0' THEN
                    next_bitmap_read_address <= bitmap_read_address - blit_increment;
                ELSE
                    next_bitmap_read_address <= bitmap_read_address + blit_increment;
                END IF;
            --WHEN OTHERS =>
            --    next_bitmap_read_address <= bitmap_read_address;
        END CASE;
     
        CASE next_blit_count_action IS
            WHEN blit_count_zero =>
                next_blit_count <= 0;
            WHEN blit_count_load =>
                next_blit_count <= blitSizeInt;
            WHEN blit_count_keep =>
                next_blit_count <= blit_count;
            WHEN blit_count_decrement =>
                next_blit_count <= blit_count - 1;   
            --WHEN OTHERS =>
            --    next_blit_count <= blit_count;
        END CASE;
         
    END PROCESS;

    PROCESS(CLK100M)
    BEGIN
        IF RISING_EDGE(CLK100M) THEN
            blit_step <= next_blit_step;
            blit_count <= next_blit_count;
            fifoRead <= next_fifo_read;
            bitmap_read_address <= next_bitmap_read_address;
            line_write_address <= next_line_write_address;
            line_write <= next_line_write;
            write_blank_data <= next_write_blank_data;
            collision_data <= next_collision_data;
            collision_flags_write <= next_collision_flags_write;
        END IF;
    END PROCESS;
    
    FIFO_READ <= fifoRead;
    
    bitmap_read_address_bits <= std_logic_vector(to_unsigned(bitmap_read_address, 17));
    
    PROCESS(bitmap_read_address_bits,colorDepth)
    BEGIN
        IF colorDepth='1' THEN
            --4 bit color mode
            SPRITE_GFX_READ_ADDRESS <= to_integer(unsigned(bitmap_read_address_bits(16 downto 1)));
        ELSE
            --8 bit color mode
            SPRITE_GFX_READ_ADDRESS <= to_integer(unsigned(bitmap_read_address_bits(15 downto 0)));
        END IF;
    END PROCESS;
    
    COLLISION_WRITE_ADDRESS <= to_integer(unsigned(blitSpriteID));
    COLLISION_WRITE_STROBE  <= collision_flags_write;
    COLLISION_WRITE_DATA    <= collision_data;
    
    BUFFER_WRITE_ADDRESS    <= line_write_address;
    
    COL_BUFF_ADDRESS        <= line_write_address;
    
    PROCESS(blitCollEnable,collision_data)
    BEGIN
        IF blitCollEnable = '1' THEN
            COLLISION_INTERRUPTS    <= collision_data;
        ELSE
            COLLISION_INTERRUPTS    <= "00000000";
        END IF;
    END PROCESS;
    
    PROCESS(write_blank_data,blitLayer,pixel_adjusted)
    BEGIN
        IF write_blank_data THEN
            BUFFER_WRITE_DATA <= "0000000000";
        ELSE
            BUFFER_WRITE_DATA <= blitLayer & pixel_adjusted;
        END IF;
    END PROCESS;
    
    BUFFER_WRITE_STROBE     <= line_write;
    COL_BUFF_WRITE_STROBE   <= line_write;
    
    COL_BUFF_WRITE_DATA     <= COL_BUFF_READ_DATA or blitCollBits;
    
    DEBUG_OUT(0) <= FIFO_EMPTY;
    DEBUG_OUT(1) <= line_write;
    
END behavioral;