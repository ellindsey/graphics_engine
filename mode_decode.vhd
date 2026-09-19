LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

/*
53 unique non-redundant graphics modes:

 10: Tile A + 64K Sprites
 11: Text + Tile A + 56K Sprites
 12: Affine + 48K Sprites
 13: Text + Affine + 40K Sprites
 14: Tile A + Tile B + 48K Sprites
 15: Text + Tile A + Tile B + 40K Sprites
 23: Text + Tile A + Tile B + 160x120 2 color bitmap
 26: Tile A + 56K Sprites + 160x120 2 color bitmap
 27: Text + Tile A + 48K Sprites + 160x120 2 color bitmap
 28: Affine + 40K Sprites + 160x120 2 color bitmap
 29: Text + Affine + 32K Sprites + 160x120 2 color bitmap
 30: Tile A + Tile B + 40K Sprites + 160x120 2 color bitmap
 55: Text + Tile A + Tile B + 160x120 16 color bitmap
 58: Tile A + 48K Sprites + 160x120 16 color bitmap
 59: Text + Tile A + 40K Sprites + 160x120 16 color bitmap
 60: Affine + 32K Sprites + 160x120 16 color bitmap
 61: Text + Affine + 24K Sprites + 160x120 16 color bitmap
 62: Tile A + Tile B + 32K Sprites + 160x120 16 color bitmap
 87: Text + Tile A + Tile B + 160x120 4 color bitmap
 90: Tile A + 56K Sprites + 160x120 4 color bitmap
 91: Text + Tile A + 48K Sprites + 160x120 4 color bitmap
 92: Affine + 40K Sprites + 160x120 4 color bitmap
 93: Text + Affine + 32K Sprites + 160x120 4 color bitmap
 94: Tile A + Tile B + 40K Sprites + 160x120 4 color bitmap
 95: Affine + Tile A + 32K Sprites
119: Text + Tile A + Tile B + 160x120 256 color bitmap
122: Tile A + 40K Sprites + 160x120 256 color bitmap
123: Text + Tile A + 32K Sprites + 160x120 256 color bitmap
124: Affine + 24K Sprites + 160x120 256 color bitmap
125: Text + Affine + 16K Sprites + 160x120 256 color bitmap
126: Tile A + Tile B + 24K Sprites + 160x120 256 color bitmap
127: Text + Affine + Tile A + 24K Sprites
151: Text + Tile A + Tile B + 320x240 2 color bitmap
154: Tile A + 48K Sprites + 320x240 2 color bitmap
155: Text + Tile A + 40K Sprites + 320x240 2 color bitmap
156: Affine + 32K Sprites + 320x240 2 color bitmap
157: Text + Affine + 24K Sprites + 320x240 2 color bitmap
158: Tile A + Tile B + 32K Sprites + 320x240 2 color bitmap
181: Text + Affine + 320x240 16 color bitmap
183: Text + Tile A + Tile B + 320x240 16 color bitmap
186: Tile A + 24K Sprites + 320x240 16 color bitmap
187: Text + Tile A + 16K Sprites + 320x240 16 color bitmap
188: Affine + 8K Sprites + 320x240 16 color bitmap
190: Tile A + Tile B + 8K Sprites + 320x240 16 color bitmap
191: Text + Affine + Tile A + Tile B
215: Text + Tile A + Tile B + 320x240 4 color bitmap
218: Tile A + 40K Sprites + 320x240 4 color bitmap
219: Text + Tile A + 32K Sprites + 320x240 4 color bitmap
220: Affine + 24K Sprites + 320x240 4 color bitmap
221: Text + Affine + 16K Sprites + 320x240 4 color bitmap
222: Tile A + Tile B + 24K Sprites + 320x240 4 color bitmap
223: Affine + Tile A + Tile B + 16K Sprites
240: 320x240 256 color bitmap
*/

ENTITY mode_decode IS
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
        bank0AddressSelect      : OUT integer range 0 to 2; --address from Text, Bitmap, Sprite graphics
        bank1AddressSelect      : OUT integer range 0 to 2; --address from Tile A map, Affine Map, Bitmap
        bank2AddressSelect      : OUT integer range 0 to 3; --address from Tile B map, Affine Map, Bitmap, Sprite graphics
        bank3AddressSelect      : OUT integer range 0 to 2; --address from Tile A graphics, Affine graphics, Bitmap
        bank4AddressSelect      : OUT integer range 0 to 3; --address from Tile B graphics, Affine graphics, Bitmap, Sprite graphics
        bank5AddressSelect      : OUT integer range 0 to 1; --address from Sprite graphics, Bitmap
        bank6AddressSelect      : OUT integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile B map
        bank7AddressSelect      : OUT integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile B graphics
        bank8AddressSelect      : OUT integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile A map
        bank9AddressSelect      : OUT integer range 0 to 2; --address from Sprite graphics, Bitmap, Tile A graphics
        
        LAYER_ENABLE            : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
END mode_decode;

    
ARCHITECTURE behavior OF mode_decode IS

    SIGNAL enableTextEngineInt     : STD_LOGIC;
    SIGNAL enableTileAEngineInt    : STD_LOGIC;
    SIGNAL enableTileBEngineInt    : STD_LOGIC;
    SIGNAL enableSpriteEngineInt   : STD_LOGIC;
    SIGNAL enableAffineEngineInt   : STD_LOGIC;
    SIGNAL enableBitmapEngineInt   : STD_LOGIC;
        
    SIGNAL bitmapModeInt           : STD_LOGIC_VECTOR(2 DOWNTO 0);
        
    SIGNAL buffer0SelectInt        : integer range 0 to 1;
    SIGNAL buffer1SelectInt        : integer range 0 to 1;
    SIGNAL buffer2SelectInt        : integer range 0 to 2;
    SIGNAL buffer3SelectInt        : integer range 0 to 2;
        
        --engine to bank address steering
    SIGNAL bank0AddressSelectInt   : integer range 0 to 2;
    SIGNAL bank1AddressSelectInt   : integer range 0 to 2;
    SIGNAL bank2AddressSelectInt   : integer range 0 to 3;
    SIGNAL bank3AddressSelectInt   : integer range 0 to 2;
    SIGNAL bank4AddressSelectInt   : integer range 0 to 3;
    SIGNAL bank5AddressSelectInt   : integer range 0 to 1;
    SIGNAL bank6AddressSelectInt   : integer range 0 to 2;
    SIGNAL bank7AddressSelectInt   : integer range 0 to 2;
    SIGNAL bank8AddressSelectInt   : integer range 0 to 2;
    SIGNAL bank9AddressSelectInt   : integer range 0 to 2;
    
    SIGNAL layerEnable             : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    SIGNAL modeInt                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL specialMode             : STD_LOGIC;
    
BEGIN

    --Latch mode in on 25mhz clock
    PROCESS(CLK,mode)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            modeInt <= mode;
        END IF;
    END PROCESS;
    
    PROCESS(modeInt)
    BEGIN
    
        -- Graphics Mode Bit 0: Text engine enable
        -- Graphics Mode Bit 1: Tile A engine enable
        -- Graphics Mode Bit 2: Tile B/affine engine select
        -- Graphics Mode Bit 3: Sprite engine enable
        -- Graphics Mode Bit 4: Bitmap engine enable
        -- Graphics Mode Bit 5: Bitmap color depth 0
        -- Graphics Mode Bit 6: Bitmap color depth 1
        -- Graphics Mode Bit 7: Bitmap resolution
        
        --Bitmap color depth:
        --  00     1bpp (2 color)
        --  01     2bpp (4 color)
        --  10     4bpp (16 color)
        --  11	     8bpp (256 color)
        
        --Bitmap resolution:
        --  0	160x120
        --  1	320x240
        
        --Tile and affine select, bits 5-6
        --  00	No tile or affine
        --  01	Affine engine only
        --  10	Tile A engine only
        --  11	        Tile A and B engines
        
        bitmapModeInt               <= modeInt(7 downto 5);
            
        if (modeInt(4 downto 0) = "11111") THEN --Affine + tile, no bitmap modes
            specialMode                 <= '1';
            enableBitmapEngineInt       <= '0';
            enableAffineEngineInt       <= '1';
            enableTileAEngineInt        <= '1';
            enableTextEngineInt         <= modeInt(5);
            enableSpriteEngineInt       <= modeInt(6);
            enableTileBEngineInt        <= modeInt(7) AND NOT (modeInt(5) AND modeInt(6));
            
        ELSE
            specialMode                 <= '0';
            
            enableBitmapEngineInt       <= modeInt(4);
            
            --IF modeInt(7 downto 6) = "11" AND modeInt(0) = "1" THEN
            --    enableSpriteEngineInt   <= '0';
            --ELSE
            enableSpriteEngineInt       <= modeInt(3);
            --END IF;
            
            enableAffineEngineInt       <= modeInt(2) AND NOT modeInt(1);
            enableTileBEngineInt        <= modeInt(2) AND modeInt(1);
            enableTileAEngineInt        <= modeInt(1);
            enableTextEngineInt         <= modeInt(0);
        END IF;
    END PROCESS;
        
    --Line buffer assignments:
    
    PROCESS(enableTextEngineInt,enableTileBEngineInt,enableBitmapEngineInt,enableSpriteEngineInt,specialMode)
    BEGIN
        --Buffer 0: Text or Tile B

        IF enableTextEngineInt THEN
            buffer0SelectInt <= 0;
            layerEnable(0) <= '1';
        ELSIF enableTileBEngineInt AND enableBitmapEngineInt AND enableSpriteEngineInt THEN
            buffer0SelectInt <= 1;
            layerEnable(0) <= '1';
        ELSIF enableTileBEngineInt AND specialMode THEN
            buffer0SelectInt <= 1;
            layerEnable(0) <= '1';
        ELSE
            buffer0SelectInt <= 0;
            layerEnable(0) <= '0';
        END IF;
    END PROCESS;
        
    PROCESS(enableTileAEngineInt,enableAffineEngineInt)
    BEGIN
        --Buffer 1: Tile A or Affine
        
        IF enableAffineEngineInt THEN
            buffer1SelectInt <= 1;
            layerEnable(1) <= '1';
        ELSIF enableTileAEngineInt THEN
            buffer1SelectInt <= 0;
            layerEnable(1) <= '1';
        ELSE
            buffer1SelectInt <= 0;
            layerEnable(1) <= '0';
        END IF;
    END PROCESS;
        
    PROCESS(enableBitmapEngineInt,enableSpriteEngineInt,enableTileBEngineInt,specialMode)
    BEGIN
        --Buffer 2: Tile B, Sprite, or Tile A
        
        IF enableBitmapEngineInt AND enableSpriteEngineInt THEN
            buffer2SelectInt <= 1;
            layerEnable(2) <= '1';
        ELSIF specialMode THEN
            buffer2SelectInt <= 2;
            layerEnable(2) <= '1';
        ELSIF enableTileBEngineInt THEN
            buffer2SelectInt <= 0;
            layerEnable(2) <= '1';
        ELSE
            buffer2SelectInt <= 0;
            layerEnable(2) <= '0';
        END IF;
    END PROCESS;
        
    PROCESS(enableBitmapEngineInt,enableSpriteEngineInt,enableTextEngineInt,enableTileBEngineInt,specialMode)
    BEGIN
        --Buffer 3: Sprite, Bitmap, or Tile B
        
        IF enableBitmapEngineInt THEN
            buffer3SelectInt <= 1;
            layerEnable(3) <= '1';
        ELSIF enableSpriteEngineInt THEN
            buffer3SelectInt <= 0;
            layerEnable(3) <= '1';
        ELSIF specialMode AND enableTextEngineInt AND enableTileBEngineInt THEN
            buffer3SelectInt <= 2;
            layerEnable(3) <= '1';
        ELSE
            buffer3SelectInt <= 0;
            layerEnable(3) <= '0';
        END IF;
    END PROCESS;
        
    --Memory banks:
    
    PROCESS(enableTextEngineInt)
    BEGIN
        --Bank 0: 32bit, Text map, Bitmap 9, or Sprite 5

        IF enableTextEngineInt THEN
            bank0AddressSelectInt <= 0;
        ELSIF enableBitmapEngineInt = '1' AND bitmapModeInt = "111" THEN
            bank0AddressSelectInt <= 1;
        ELSE
            bank0AddressSelectInt <= 2;
        END IF;
    END PROCESS;
    
    PROCESS(enableAffineEngineInt,enableTileAEngineInt,enableSpriteEngineInt,enableBitmapEngineInt,bitmapModeInt)
    BEGIN
        --Bank 1: 32bit, Tile A map or Affine Map 1 or Bitmap 8
        --Bank 2: 32bit, Tile B map or Affine Map 2 or Bitmap 7 or Sprite 6
        --Bank 3: 8bit, Tile A graphics or Affine Graphics 1 or Bitmap 6
        --Bank 4: 8bit, Tile B graphics or Affine Graphics 2 or Bitmap 5 or Sprite 7

        IF enableAffineEngineInt THEN
            bank1AddressSelectInt <= 1;
            bank2AddressSelectInt <= 1;
            bank3AddressSelectInt <= 1;
            bank4AddressSelectInt <= 1;
        ELSE
            IF enableTileAEngineInt THEN
                bank1AddressSelectInt <= 0;
                bank3AddressSelectInt <= 0;
                IF enableTileBEngineInt THEN
                    bank2AddressSelectInt <= 0;
                    bank4AddressSelectInt <= 0;
                ELSE
                    bank2AddressSelectInt <= 3;
                    bank4AddressSelectInt <= 3;
                END IF;
            ELSE
                bank1AddressSelectInt <= 2;
                bank2AddressSelectInt <= 2;
                bank3AddressSelectInt <= 2;
                bank4AddressSelectInt <= 2;
            END IF;
        END IF;
    END PROCESS;
        
    PROCESS(enableBitmapEngineInt,bitmapModeInt,enableTileAEngineInt,enableTileBEngineInt,specialMode)
    BEGIN
        --Bank 5: 8bit, Sprite graphics 0 or Bitmap 4
        --Bank 6: 8bit, Sprite graphics 1, Bitmap 3, or Tile B map
        --Bank 7: 8bit, Sprite graphics 2, Bitmap 2, or Tile B graphics
        --Bank 8: 8bit, Sprite graphics 3, Bitmap 1, or Tile A map
        --Bank 9: 8bit, Sprite graphics 4, Bitmap 0, or Tile A graphics

        IF enableBitmapEngineInt THEN
            CASE bitmapModeInt IS
                WHEN "000" => --160x120 1bpp 1 bank required
                    --Sprite data in banks 5-8, bitmap data in bank 9
                    bank5AddressSelectInt <= 0;
                    bank6AddressSelectInt <= 0;
                    bank7AddressSelectInt <= 0;
                    bank8AddressSelectInt <= 0;
                    bank9AddressSelectInt <= 1;
                WHEN "001" => --160x120 2bpp 1 bank required
                    --Sprite data in banks 5-8, bitmap data in bank 9
                    bank5AddressSelectInt <= 0;
                    bank6AddressSelectInt <= 0;
                    bank7AddressSelectInt <= 0;
                    bank8AddressSelectInt <= 0;
                    bank9AddressSelectInt <= 1;
                WHEN "010" => --160x120 4bpp 2 banks required
                    --Sprite data in banks 5-7, bitmap data in banks 8-9
                    bank5AddressSelectInt <= 0;
                    bank6AddressSelectInt <= 0;
                    bank7AddressSelectInt <= 0;
                    bank8AddressSelectInt <= 1;
                    bank9AddressSelectInt <= 1;
                WHEN "011" => --160x120 8bpp 3 banks required
                    --Sprite data in banks 5-6, bitmap data in banks 7-9
                    bank5AddressSelectInt <= 0;
                    bank6AddressSelectInt <= 0;
                    bank7AddressSelectInt <= 1;
                    bank8AddressSelectInt <= 1;
                    bank9AddressSelectInt <= 1;
                WHEN "100" => --320x240 1bpp 2 banks required
                    --Sprite data in banks 5-7, bitmap data in banks 8-9
                    bank5AddressSelectInt <= 0;
                    bank6AddressSelectInt <= 0;
                    bank7AddressSelectInt <= 0;
                    bank8AddressSelectInt <= 1;
                    bank9AddressSelectInt <= 1;
                WHEN "101" => --320x240 2bpp 3 banks required
                    --Sprite data in banks 5-6, bitmap data in banks 7-9
                    bank5AddressSelectInt <= 0;
                    bank6AddressSelectInt <= 0;
                    bank7AddressSelectInt <= 1;
                    bank8AddressSelectInt <= 1;
                    bank9AddressSelectInt <= 1;
                WHEN "110" => --320x240 4bpp 5 banks required
                    --Bitmap data in banks 5-9, sprite engine is disabled
                    bank5AddressSelectInt <= 1;
                    bank6AddressSelectInt <= 1;
                    bank7AddressSelectInt <= 1;
                    bank8AddressSelectInt <= 1;
                    bank9AddressSelectInt <= 1;
                WHEN "111" => --320x240 8bpp 10 banks required (uses tile and text memory if possible)
                    --Bitmap data in banks 5-9, sprite engine is disabled
                    --Can also take bitmap data from banks 0-4 if tile, text, or affine engines aren't using them.
                    bank5AddressSelectInt <= 1;
                    bank6AddressSelectInt <= 1;
                    bank7AddressSelectInt <= 1;
                    bank8AddressSelectInt <= 1;
                    bank9AddressSelectInt <= 1;
                WHEN OTHERS =>
                    bank5AddressSelectInt <= 0;
                    bank6AddressSelectInt <= 0;
                    bank7AddressSelectInt <= 0;
                    bank8AddressSelectInt <= 0;
                    bank9AddressSelectInt <= 0;
            END CASE;
        ELSIF specialMode THEN
            bank5AddressSelectInt <= 0; --sprite graphics
            IF enableTileBEngineInt THEN
                bank6AddressSelectInt <= 2; --tile B map
                bank7AddressSelectInt <= 2; --tile B graphics
            ELSE
                bank6AddressSelectInt <= 0; --sprite graphics
                bank7AddressSelectInt <= 0; --sprite graphics
            END IF;
            IF enableTileAEngineInt THEN
                bank8AddressSelectInt <= 2; --tile A map
                bank9AddressSelectInt <= 2; --tile A graphics
            ELSE
                bank8AddressSelectInt <= 0; --sprite graphics
                bank9AddressSelectInt <= 0; --sprite graphics
            END IF;
        ELSE
            bank5AddressSelectInt <= 0; --sprite graphics
            bank6AddressSelectInt <= 0; --sprite graphics
            bank7AddressSelectInt <= 0; --sprite graphics
            bank8AddressSelectInt <= 0; --sprite graphics
            bank9AddressSelectInt <= 0; --sprite graphics
        END IF;
    END PROCESS;
    
    --Latch signals out on 25mhz clock
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            enableTextEngine     <= enableTextEngineInt AND enginesRun;
            enableTileAEngine    <= enableTileAEngineInt AND enginesRun;
            enableTileBEngine    <= enableTileBEngineInt AND enginesRun;
            enableSpriteEngine   <= enableSpriteEngineInt AND enginesRun;
            enableAffineEngine   <= enableAffineEngineInt AND enginesRun;
            enableBitmapEngine   <= enableBitmapEngineInt AND enginesRun;
            
            bitmapMode           <= bitmapModeInt;
            
            buffer0Select        <= buffer0SelectInt;
            buffer1Select        <= buffer1SelectInt;
            buffer2Select        <= buffer2SelectInt;
            buffer3Select        <= buffer3SelectInt;
            
            --engine to bank address steering
            bank0AddressSelect   <= bank0AddressSelectInt;
            bank1AddressSelect   <= bank1AddressSelectInt;
            bank2AddressSelect   <= bank2AddressSelectInt;
            bank3AddressSelect   <= bank3AddressSelectInt;
            bank4AddressSelect   <= bank4AddressSelectInt;
            bank5AddressSelect   <= bank5AddressSelectInt;
            bank6AddressSelect   <= bank6AddressSelectInt;
            bank7AddressSelect   <= bank7AddressSelectInt;
            bank8AddressSelect   <= bank8AddressSelectInt;
            bank9AddressSelect   <= bank9AddressSelectInt;
            
            LAYER_ENABLE         <= layerEnable;
        END IF;
    END PROCESS;

END behavior;