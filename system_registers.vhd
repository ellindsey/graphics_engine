library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--System registers map:

--0x0000: Graphics mode
    --0: Text engine enable
    --1: Tile A engine enable
    --2: Tile B/affine engine select
    --3: Sprite engine enable
    --4: Bitmap engine enable
    --5: Bitmap color depth 0
    --6: Bitmap color depth 1
    --7: Bitmap resolution
--0x0001: Screen state			        (read-only)
    --0: vsync
    --1: hsync
    --2: vblank
    --3: hblank
    --4: in screen area
    --5: not vblank
    --6: not hblank
    --7: not in screen area
--0x0002: Interrupt enable bits 8-15
    --8: audio load pulse (48khz)
    --9: copper interrupt
    --10: Unused
    --11: horizontal blanking period begin
    --12: horizontal blanking period end
    --13: vertical blanking period begin
    --14: vertical blanking period end
    --15: line matched
--0x0003: Interrupt enable bits 0-7
    --0: sprite collision flag 0
    --1: sprite collision flag 1
    --2: sprite collision flag 2
    --3: sprite collision flag 3
    --4: sprite collision flag 4
    --5: sprite collision flag 5
    --6: sprite collision flag 6
    --7: sprite collision flag 7
--0x0004: Interrupt flags 8-15
    --8: audio load pulse (48khz)
    --9: copper interrupt
    --10: Unused
    --11: horizontal blanking period begin
    --12: horizontal blanking period end
    --13: vertical blanking period begin
    --14: vertical blanking period end
    --15: line matched
--0x0005: Interrupt flags 0-7
    --0: sprite collision flag 0
    --1: sprite collision flag 1
    --2: sprite collision flag 2
    --3: sprite collision flag 3
    --4: sprite collision flag 4
    --5: sprite collision flag 5
    --6: sprite collision flag 6
    --7: sprite collision flag 7
--0x0006: Text font width (default 7)
--0x0007: Text Y scroll	
--0x0008: Tile A Y scroll
--0x0009: Tile B Y scroll
--0x000A: Tile A X scroll MSB
--0x000B: Tile A X scroll LSB
--0x000C: Tile B X scroll MSB
--0x000D: Tile B X scroll LSB
--0x000E: Active Pixel X being output MSB       (read-only)
--0x000F: Active Pixel X being output LSB       (read-only)
--0x0010: Frame count MSB		                (read-only)
--0x0011: Frame count LSB		                (read-only)
--0x0012: Active line			                (read-only)
--0x0013: Line match register
--0x0014: Coprocessor control
--      Bit 7: Coprocessor reset bit
--      Bit 6: Coprocessor enable bit
--      Bits 2 to 5: Unused
--      Bits 0 to 1: Coprocessor program address bits 8-9 (read-only)
--0x0015: Coprocessor program address bits 0-7 (read-only)
--0x0016: Hardware random number                (read-only)
--0x0017: Master audio volume
--0x0018: Unused
--0x0019: Sprite Y scroll
--0x001A: Sprite X scroll MSB
--0x001B: Sprite X scroll LSB
--0x001C: Affine layer transparency color
--0x001D: Bitmap layer transparency color
--0x001E: Extended memory remap select
--0x001F: Bitmap and affine layer control bits
    --0: Affine layer transparency enable
    --1: Affine layer priority bit 0
    --2: Affine layer priority bit 1
    --3: Affine edge repeat flag
    --4: Bitmap layer transparency enable
    --5: Bitmap layer priority bit 0
    --6: Bitmap layer priority bit 1
    --7: Unused
--0x0020: Window effect R channel blank value (1 byte)
--0x0021: Window effect G channel blank value (1 byte)
--0x0022: Window effect B channel blank value (1 byte)
--0x0023: Window effect R channel value (1 byte)
--0x0024: Window effect G channel value (1 byte)
--0x0025: Window effect B channel value (1 byte)
--0x0026, 0x0027:	Windowed effects control
--0x0028, 0x0029:	Window 1 start X - 2 bytes (9 bits, accepted values 0 to 511)
--0x002A, 0x002B:	Window 1 stop X - 2 bytes (9 bits, accepted values 0 to 511)
--0x002C, 0x002D:	Window 2 start X - 2 bytes (9 bits, accepted values 0 to 511)
--0x002E, 0x002F:	Window 2 stop X - 2 bytes (9 bits, accepted values 0 to 511)
--0x0030 to 0x003F: copper scratchpad

entity system_registers is
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
end system_registers;

architecture Behavioral of system_registers is

    SIGNAL interruptEnable              : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL interruptFlags               : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL nextInterruptFlags           : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    SIGNAL interruptClear               : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    
    SIGNAL textWidth                    : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111";
    SIGNAL textYscroll                  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL tileYscroll1                 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL tileXscroll1                 : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
    SIGNAL tileYscroll2                 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL tileXscroll2                 : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
    SIGNAL spriteYscroll                : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL spriteXscroll                : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
    SIGNAL lineActive                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL lineMatch                    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL masterVolume                 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10000000";
    
    SIGNAL scratch0                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch1                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch2                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch3                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch4                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch5                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch6                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch7                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch8                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch9                     : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch10                    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch11                    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch12                    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch13                    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch14                    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL scratch15                    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    
    --SIGNAL latchedAddress               : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL latchedDataIn                : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL latchedAddressWrite          : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL latchedByteFlags             : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    SIGNAL latchedAddressRead           : STD_LOGIC_VECTOR(5 DOWNTO 0);
    
    SIGNAL fcTemp                       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    SIGNAL graphicsMode                 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "11110000";
    
    SIGNAL prior_hblank                 : STD_LOGIC := '0';
    SIGNAL prior_vblank                 : STD_LOGIC := '0';
    
    SIGNAL hblank                       : STD_LOGIC;
    SIGNAL vblank                       : STD_LOGIC;
    
    SIGNAL prior_audio_load_pulse       : STD_LOGIC;
    
    SIGNAL prior_copper_interrupt       : STD_LOGIC;
    
    SIGNAL linematched                  : STD_LOGIC;
    SIGNAL prior_linematched            : STD_LOGIC;
    
    SIGNAl prior_collision_flags        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL affine_transparency_color    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL bitmap_transparency_color    : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    
    SIGNAL affine_transparency_enable   : STD_LOGIC := '0';
    SIGNAL affine_layer_priority        : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL affine_edge_repeat_flag      : STD_LOGIC := '0';
    
    SIGNAL bitmap_transparency_enable   : STD_LOGIC := '0';
    SIGNAL bitmap_layer_priority        : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    
    SIGNAl memory_remap_register        : integer range 0 to 2 := 0;
    SIGNAL sample_table_remap_register  : integer range 0 to 3 := 0;
    
    SIGNAL copper_enable_register       : STD_LOGIC := '0';
    SIGNAL copper_reset_register        : STD_LOGIC := '0';
    
    SIGNAL effect_R_blank_value         : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL effect_G_blank_value         : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL effect_B_blank_value         : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    
    SIGNAL effect_R_value               : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL effect_G_value               : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL effect_B_value               : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    
    SIGNAL effect_control_reg           : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
    
    SIGNAL effect_window_start_1        : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
    SIGNAL effect_window_stop_1         : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
    SIGNAL effect_window_start_2        : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
    SIGNAL effect_window_stop_2         : STD_LOGIC_VECTOR(8 DOWNTO 0) := "000000000";
    
    SIGNAL copper_address_bits          : STD_LOGIC_VECTOR(9 downto 0);
    

BEGIN
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF COPPER_WRITE_STROBE THEN
                latchedAddressWrite <= COPPER_ADDRESS_IN;
                latchedDataIn <= COPPER_DATA_IN;
                latchedByteFlags <= COPPER_BYTE_FLAGS;
            ELSE
                latchedAddressWrite <= ADDRESS_IN(5 downto 1);
                latchedDataIn <= DATA_IN & DATA_IN;
                latchedByteFlags <= (NOT ADDRESS_IN(0)) & ADDRESS_IN(0);
            END IF;
            latchedAddressRead <= ADDRESS_IN;
        END IF;
    END PROCESS;
    
    lineActive <= STD_LOGIC_VECTOR(to_unsigned(LINE_ACTIVE,8));
    fcTemp <= STD_LOGIC_VECTOR(to_unsigned(FRAME_COUNT,16));
    
    copper_address_bits <= STD_LOGIC_VECTOR(to_unsigned(COPPER_ADDRESS,10));
    
    TEXT_WIDTH <= to_integer(unsigned(textWidth));
    TEXT_Y_SCROLL <= to_integer(unsigned(textYscroll));
    TILE_Y_SCROLL_1 <= to_integer(unsigned(tileYscroll1));
    TILE_X_SCROLL_1 <= to_integer(unsigned(tileXscroll1));
    TILE_Y_SCROLL_2 <= to_integer(unsigned(tileYscroll2));
    TILE_X_SCROLL_2 <= to_integer(unsigned(tileXscroll2));
    SPRITE_SCROLL_Y <= to_integer(unsigned(spriteYscroll));
    SPRITE_SCROLL_X <= to_integer(unsigned(spriteXscroll));
    
    GRAPHICS_MODE <= graphicsMode;
    
    AUDIO_VOLUME <= masterVolume;
    
    AFFINE_TRANS_COLOR  <= affine_transparency_color;
    BITMAP_TRANS_COLOR  <= bitmap_transparency_color;
    
    AFFINE_TRANS_ENABLE <= affine_transparency_enable;
    AFFINE_LAYER        <= affine_layer_priority;
    AFFINE_EDGE_REPEAT  <= affine_edge_repeat_flag;
    
    BITMAP_TRANS_ENABLE <= bitmap_transparency_enable;
    BITMAP_LAYER        <= bitmap_layer_priority;
    
    MEMORY_REMAP        <= memory_remap_register;
    
    vblank              <= SCREEN_STATE(2);
    hblank              <= SCREEN_STATE(3);
    
    COPPER_ENABLE       <= copper_enable_register;
    COPPER_RESET        <= copper_reset_register;
    
    BLANK_R             <= to_integer(unsigned(effect_R_blank_value));
    BLANK_G             <= to_integer(unsigned(effect_G_blank_value));
    BLANK_B             <= to_integer(unsigned(effect_B_blank_value));
    
    EFFECT_R            <= to_integer(unsigned(effect_R_value));
    EFFECT_G            <= to_integer(unsigned(effect_G_value));
    EFFECT_B            <= to_integer(unsigned(effect_B_value));
        
    WINDOW_START_1      <= to_integer(unsigned(effect_window_start_1));
    WINDOW_STOP_1       <= to_integer(unsigned(effect_window_stop_1));
    WINDOW_START_2      <= to_integer(unsigned(effect_window_start_2));
    WINDOW_STOP_2       <= to_integer(unsigned(effect_window_stop_2));
        
    EFFECT_CONTROL_BITS <= effect_control_reg;
    
    PROCESS(CLK, interruptFlags, COLLISION_FLAGS, hblank, vblank, interruptClear, lineActive, prior_collision_flags, AUDIOLOADPULSE, prior_audio_load_pulse, prior_hblank, prior_vblank, prior_linematched,
            lineMatch,COPPER_INTERRUPT,linematched,prior_copper_interrupt)
    BEGIN
        IF lineActive = lineMatch THEN
            linematched <= '1';
        ELSE
            linematched <= '0';
        END IF;
    
        nextInterruptFlags(7 downto 0) <= (interruptFlags(7 downto 0) OR (COLLISION_FLAGS AND NOT prior_collision_flags));
        
        if AUDIOLOADPULSE = '1' AND prior_audio_load_pulse = '0' THEN
            nextInterruptFlags(8) <= '1';
        ELSE
            nextInterruptFlags(8) <= interruptFlags(8);
        END IF;
        
        if COPPER_INTERRUPT = '1' AND prior_copper_interrupt = '0' THEN
            nextInterruptFlags(9) <= '1';
        ELSE
            nextInterruptFlags(9) <= interruptFlags(9);
        END IF;
        
        nextInterruptFlags(10) <= '0';
            
        if (hblank = '1' AND prior_hblank = '0') THEN
            nextInterruptFlags(11) <= '1';
        ELSE
            nextInterruptFlags(11) <= interruptFlags(11);
        END IF;
            
        if (hblank = '0' AND prior_hblank = '1') THEN
            nextInterruptFlags(12) <= '1';
        ELSE
            nextInterruptFlags(12) <= interruptFlags(12);
        END IF;
            
        if (vblank = '1' AND prior_vblank = '0') THEN
            nextInterruptFlags(13) <= '1';
        ELSE
            nextInterruptFlags(13) <= interruptFlags(13);
        END IF;
            
        if (vblank = '0' AND prior_vblank = '1') THEN
            nextInterruptFlags(14) <= '1';
        ELSE
            nextInterruptFlags(14) <= interruptFlags(14);
        END IF;
            
        if (linematched = '1' AND prior_linematched = '0') THEN
            nextInterruptFlags(15) <= '1';
        ELSE
            nextInterruptFlags(15) <= interruptFlags(15);
        END IF;
        
        IF RISING_EDGE(CLK) THEN
            prior_vblank <= vblank;
            prior_hblank <= hblank;
            prior_audio_load_pulse <= AUDIOLOADPULSE;
            prior_linematched <= linematched;
            prior_collision_flags <= COLLISION_FLAGS;
            prior_copper_interrupt <= COPPER_INTERRUPT;
            
            interruptFlags <= nextInterruptFlags and not interruptClear;
        END IF;
    END PROCESS;
        
    PROCESS(interruptFlags,interruptEnable)
    BEGIN
        if (interruptFlags AND interruptEnable) = "0000000000000000" THEN
            INTERRUPT_OUT <= '1';
        ELSE
            INTERRUPT_OUT <= '0';
        END IF;
    END PROCESS;
        
    PROCESS(CLK, WRITE_STROBE, latchedAddressWrite, latchedDataIn, latchedByteFlags) --write process
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF WRITE_STROBE = '1' AND latchedAddressWrite = "00010" AND latchedByteFlags(0) = '1' THEN
                interruptClear(15 downto 8) <= latchedDataIn(15 downto 8);
            ELSE
                interruptClear(15 downto 8) <= "00000000";
            END IF;
                
            IF WRITE_STROBE = '1' AND latchedAddressWrite = "00010" AND latchedByteFlags(1) = '1' THEN
                interruptClear(7 downto 0) <= latchedDataIn(7 downto 0);
            ELSE
                interruptClear(7 downto 0) <= "00000000";
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(CLK, WRITE_STROBE, latchedAddressWrite, latchedDataIn, latchedByteFlags) --write process
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF WRITE_STROBE OR COPPER_WRITE_STROBE THEN
                CASE latchedAddressWrite IS
                        
                    WHEN "00000" =>
                        IF latchedByteFlags(0) = '1' THEN
                            graphicsMode <= latchedDataIn(15 downto 8);
                        END IF;
                        
                    WHEN "00001" =>
                        IF latchedByteFlags(0) = '1' THEN
                            interruptEnable(15 downto 8) <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            interruptEnable(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "00011" =>
                        IF latchedByteFlags(0) = '1' THEN
                            textWidth <= latchedDataIn(10 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            textYscroll <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "00100" =>
                        IF latchedByteFlags(0) = '1' THEN
                            tileYscroll1 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            tileYscroll2 <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "00101" =>
                        IF latchedByteFlags(0) = '1' THEN
                            tileXscroll1(8) <= latchedDataIn(8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            tileXscroll1(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "00110" =>
                        IF latchedByteFlags(0) = '1' THEN
                            tileXscroll2(8) <= latchedDataIn(8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            tileXscroll2(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "01001" =>
                        IF latchedByteFlags(1) = '1' THEN
                            lineMatch <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "01010" =>
                        IF latchedByteFlags(0) = '1' THEN
                            copper_enable_register <= latchedDataIn(14);
                            copper_reset_register <= latchedDataIn(15);
                        END IF;
                        
                    WHEN "01011" =>
                        IF latchedByteFlags(1) = '1' THEN
                            masterVolume <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "01100" =>
                        IF latchedByteFlags(1) = '1' THEN
                            spriteYscroll <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "01101" =>
                        IF latchedByteFlags(0) = '1' THEN
                            spriteXscroll(8) <= latchedDataIn(8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            spriteXscroll(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "01110" => 
                        IF latchedByteFlags(0) = '1' THEN
                            affine_transparency_color <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            bitmap_transparency_color <= latchedDataIn(7 downto 0);
                        END IF;
                    
                    WHEN "01111" => 
                        IF latchedByteFlags(0) = '1' THEN
                            memory_remap_register <= to_integer(unsigned(latchedDataIn(9 downto 8)));
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            affine_transparency_enable <= latchedDataIn(0);
                            affine_layer_priority <= latchedDataIn(2 downto 1);
                            affine_edge_repeat_flag <= latchedDataIn(3);
                            bitmap_transparency_enable <= latchedDataIn(4);
                            bitmap_layer_priority <= latchedDataIn(6 downto 5);
                        END IF;
                        
                    WHEN "10000" =>
                        IF latchedByteFlags(0) = '1' THEN
                            effect_R_blank_value <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            effect_G_blank_value <= latchedDataIn(7 downto 0);
                        END IF;
                    
                    WHEN "10001" =>
                        IF latchedByteFlags(0) = '1' THEN
                            effect_B_blank_value <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            effect_R_value <= latchedDataIn(7 downto 0);
                        END IF;
                    
                    WHEN "10010" =>
                        IF latchedByteFlags(0) = '1' THEN
                            effect_G_value <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            effect_B_value <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "10011" =>
                        IF latchedByteFlags(0) = '1' THEN
                            effect_control_reg(15 downto 8) <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            effect_control_reg(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "10100" =>
                        IF latchedByteFlags(0) = '1' THEN
                            effect_window_start_1(8) <= latchedDataIn(8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            effect_window_start_1(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "10101" =>
                        IF latchedByteFlags(0) = '1' THEN
                            effect_window_stop_1(8) <= latchedDataIn(8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            effect_window_stop_1(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "10110" =>
                        IF latchedByteFlags(0) = '1' THEN
                            effect_window_start_2(8) <= latchedDataIn(8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            effect_window_start_2(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "10111" =>
                        IF latchedByteFlags(0) = '1' THEN
                            effect_window_stop_2(8) <= latchedDataIn(8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            effect_window_stop_2(7 downto 0) <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "11000" =>
                        IF latchedByteFlags(0) = '1' THEN
                            scratch0 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            scratch1 <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "11001" =>
                        IF latchedByteFlags(0) = '1' THEN
                            scratch2 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            scratch3 <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "11010" =>
                        IF latchedByteFlags(0) = '1' THEN
                            scratch4 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            scratch5 <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "11011" =>
                        IF latchedByteFlags(0) = '1' THEN
                            scratch6 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            scratch7 <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "11100" =>
                        IF latchedByteFlags(0) = '1' THEN
                            scratch8 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            scratch9 <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "11101" =>
                        IF latchedByteFlags(0) = '1' THEN
                            scratch10 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            scratch11 <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "11110" =>
                        IF latchedByteFlags(0) = '1' THEN
                            scratch12 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            scratch13 <= latchedDataIn(7 downto 0);
                        END IF;
                        
                    WHEN "11111" =>
                        IF latchedByteFlags(0) = '1' THEN
                            scratch14 <= latchedDataIn(15 downto 8);
                        END IF;
                        IF latchedByteFlags(1) = '1' THEN
                            scratch15 <= latchedDataIn(7 downto 0);
                        END IF;
                    
                    WHEN OTHERS =>
                
                END CASE;
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(ALL) --CPU read process
    BEGIN
        CASE latchedAddressRead IS
                
            WHEN "000000" =>
                DATA_OUT <= graphicsMode;
                
            WHEN "000001" =>
                DATA_OUT <= SCREEN_STATE;
                
            WHEN "000010" =>
                DATA_OUT <= interruptEnable(15 downto 8);
            WHEN "000011" =>
                DATA_OUT <= interruptEnable(7 downto 0);
                
            WHEN "000100" =>
                DATA_OUT <= interruptFlags(15 downto 8);
            WHEN "000101" =>
                DATA_OUT <= interruptFlags(7 downto 0);
                
            WHEN "000110" =>
                DATA_OUT <= "00000" & textWidth;
                        
            WHEN "000111" =>
                DATA_OUT <= textYscroll;
                
            WHEN "001000" =>
                DATA_OUT <= tileYscroll1;
                
            WHEN "001001" =>
                DATA_OUT <= tileYscroll2;
                
            WHEN "001010" =>
                DATA_OUT <= "0000000" & tileXscroll1(8);
            WHEN "001011" =>
                DATA_OUT <= tileXscroll1(7 downto 0);
                
            WHEN "001100" =>
                DATA_OUT <= "0000000" & tileXscroll2(8);
            WHEN "001101" =>
                DATA_OUT <= tileXscroll2(7 downto 0);
                
            WHEN "001110" =>
                DATA_OUT <= "000000" & X_ACTIVE(9 downto 8);
            WHEN "001111" =>
                DATA_OUT <= X_ACTIVE(7 downto 0);
                
            WHEN "010000" =>
                DATA_OUT <= fcTemp(15 downto 8);
            WHEN "010001" =>
                DATA_OUT <= fcTemp(7 downto 0);
                
            WHEN "010010" =>
                DATA_OUT <= lineActive;
                
            WHEN "010011" =>
                DATA_OUT <= lineMatch;
                
            WHEN "010100" =>
                DATA_OUT <= copper_reset_register & copper_enable_register & "0000" & copper_address_bits(9 downto 8);
                
            WHEN "010101" =>     
                DATA_OUT <= copper_address_bits(7 downto 0);
                
            WHEN "010110" =>
                DATA_OUT <= RNG;
                
            WHEN "010111" =>
                DATA_OUT <= masterVolume;
                
            WHEN "011001" =>
                DATA_OUT <= spriteYscroll;
                
            WHEN "011010" =>
                DATA_OUT <= "0000000" & spriteXscroll(8);
            WHEN "011011" =>
                DATA_OUT <= spriteXscroll(7 downto 0);
                
            WHEN "011100" => 
                DATA_OUT <= affine_transparency_color;
                    
            WHEN "011101" => 
                DATA_OUT <= bitmap_transparency_color;
                
            WHEN "011110" => 
                DATA_OUT <= "000000" & std_logic_vector(to_unsigned(memory_remap_register, 2));
                
            WHEN "011111" => 
                DATA_OUT <= '0' & bitmap_layer_priority & bitmap_transparency_enable & affine_edge_repeat_flag & affine_layer_priority & affine_transparency_enable;
                    
            WHEN "100000" =>
                DATA_OUT <= effect_R_blank_value;
                    
            WHEN "100001" =>
                DATA_OUT <= effect_G_blank_value;
                    
            WHEN "100010" =>
                DATA_OUT <= effect_B_blank_value;
                
            WHEN "100011" =>
                DATA_OUT <= effect_R_value;
                    
            WHEN "100100" =>
                DATA_OUT <= effect_G_value;
                    
            WHEN "100101" =>
                DATA_OUT <= effect_B_value;
                        
            WHEN "100110" =>
                DATA_OUT <= effect_control_reg(15 downto 8);
                        
            WHEN "100111" =>
                DATA_OUT <= effect_control_reg(7 downto 0);
                        
            WHEN "101000" =>
                DATA_OUT <= "0000000" & effect_window_start_1(8);
                        
            WHEN "101001" =>
                DATA_OUT <= effect_window_start_1(7 downto 0);
                        
            WHEN "101010" =>
                DATA_OUT <= "0000000" & effect_window_stop_1(8);
                        
            WHEN "101011" =>
                DATA_OUT <= effect_window_stop_1(7 downto 0);
                        
            WHEN "101100" =>
                DATA_OUT <= "0000000" & effect_window_start_2(8);
                        
            WHEN "101101" =>
                DATA_OUT <= effect_window_start_2(7 downto 0);
                        
            WHEN "101110" =>
                DATA_OUT <= "0000000" & effect_window_stop_2(8);
                        
            WHEN "101111" =>
                DATA_OUT <= effect_window_stop_2(7 downto 0);
                        
            WHEN "110000" =>
                DATA_OUT <= scratch0;
                
            WHEN "110001" =>
                DATA_OUT <= scratch1;
                
            WHEN "110010" =>
                DATA_OUT <= scratch2;
                
            WHEN "110011" =>
                DATA_OUT <= scratch3;
                
            WHEN "110100" =>
                DATA_OUT <= scratch4;
                
            WHEN "110101" =>
                DATA_OUT <= scratch5;
                
            WHEN "110110" =>
                DATA_OUT <= scratch6;
                
            WHEN "110111" =>
                DATA_OUT <= scratch7;
                
            WHEN "111000" =>
                DATA_OUT <= scratch8;
                
            WHEN "111001" =>
                DATA_OUT <= scratch9;
                
            WHEN "111010" =>
                DATA_OUT <= scratch10;
                
            WHEN "111011" =>
                DATA_OUT <= scratch11;
                
            WHEN "111100" =>
                DATA_OUT <= scratch12;
                
            WHEN "111101" =>
                DATA_OUT <= scratch13;
                
            WHEN "111110" =>
                DATA_OUT <= scratch14;
                
            WHEN "111111" =>
                DATA_OUT <= scratch15;
                  
            WHEN OTHERS =>
                DATA_OUT <= "00000000";
        END CASE;
    END PROCESS;
    
    PROCESS(ALL) --copper read process
    BEGIN
        CASE COPPER_ADDRESS_IN IS
                
            WHEN "00000" =>
                COPPER_DATA_OUT <= graphicsMode & SCREEN_STATE;
                
            WHEN "00001" =>
                COPPER_DATA_OUT <= interruptEnable;
                
            WHEN "00010" =>
                COPPER_DATA_OUT <= interruptFlags;
                
            WHEN "00011" =>
                COPPER_DATA_OUT <= "00000" & textWidth & textYscroll;
                
            WHEN "00100" =>
                COPPER_DATA_OUT <= tileYscroll1 & tileYscroll2;
                
            WHEN "00101" =>
                COPPER_DATA_OUT <= "0000000" & tileXscroll1;
                
            WHEN "00110" =>
                COPPER_DATA_OUT <= "0000000" & tileXscroll2;
                
            WHEN "00111" =>
                COPPER_DATA_OUT <= "000000" & X_ACTIVE;
                
            WHEN "01000" =>
                COPPER_DATA_OUT <= fcTemp;
                
            WHEN "01001" =>
                COPPER_DATA_OUT <= lineActive & lineMatch;
                
            WHEN "01010" =>
                COPPER_DATA_OUT <= copper_reset_register & copper_enable_register & "0000" & copper_address_bits;
                
            WHEN "01011" =>
                COPPER_DATA_OUT <= RNG & masterVolume;
                
            WHEN "01100" =>
                COPPER_DATA_OUT <= "00000000" & spriteYscroll;
                
            WHEN "01101" =>
                COPPER_DATA_OUT <= "0000000" & spriteXscroll;
                
            WHEN "01110" => 
                COPPER_DATA_OUT <= affine_transparency_color & bitmap_transparency_color;
                
            WHEN "01111" => 
                COPPER_DATA_OUT <= "000000" & std_logic_vector(to_unsigned(memory_remap_register, 2)) & '0' & bitmap_layer_priority & bitmap_transparency_enable & affine_edge_repeat_flag & affine_layer_priority & affine_transparency_enable;
                    
            WHEN "10000" =>
                COPPER_DATA_OUT <= effect_R_blank_value & effect_G_blank_value;
                    
            WHEN "10001" =>
                COPPER_DATA_OUT <= effect_B_blank_value & effect_R_value;
                    
            WHEN "10010" =>
                COPPER_DATA_OUT <= effect_G_value & effect_B_value;
                        
            WHEN "10011" =>
                COPPER_DATA_OUT <= effect_control_reg;
                        
            WHEN "10100" =>
                COPPER_DATA_OUT <= "0000000" & effect_window_start_1;
                        
            WHEN "10101" =>
                COPPER_DATA_OUT <= "0000000" & effect_window_stop_1;
                        
            WHEN "10110" =>
                COPPER_DATA_OUT <= "0000000" & effect_window_start_2;
                        
            WHEN "10111" =>
                COPPER_DATA_OUT <= "0000000" & effect_window_stop_2;
                        
            WHEN "11000" =>
                COPPER_DATA_OUT <= scratch0 & scratch1;
                
            WHEN "11001" =>
                COPPER_DATA_OUT <= scratch2 & scratch3;
                
            WHEN "11010" =>
                COPPER_DATA_OUT <= scratch4 & scratch5;
                
            WHEN "11011" =>
                COPPER_DATA_OUT <= scratch6 & scratch7;
                
            WHEN "11100" =>
                COPPER_DATA_OUT <= scratch8 & scratch9;
                
            WHEN "11101" =>
                COPPER_DATA_OUT <= scratch10 & scratch11;
                
            WHEN "11110" =>
                COPPER_DATA_OUT <= scratch12 & scratch13;
                
            WHEN "11111" =>
                COPPER_DATA_OUT <= scratch14 & scratch15;
                
            WHEN OTHERS =>
                COPPER_DATA_OUT <= "0000000000000000";
        END CASE;
    END PROCESS;
    
end Behavioral;