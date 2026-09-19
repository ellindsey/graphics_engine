library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity graphics_mode_decocder is
    PORT(
        GRAPHICS_MODE       : IN integer range 0 to 47;
        
        layerEnable         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        buffer0Steer        : OUT integer range 0 to 2; --0: blank, 1: text, 2: sprites
        buffer1Steer        : OUT integer range 0 to 2; --0: blank, 1: tile A, 2: affine
        buffer2Steer        : OUT integer range 0 to 3; --0: blank, 1: tile B, 2: affine, 3: sprites
        buffer3Steer        : OUT integer range 0 to 2; --0: blank, 1: bitmap, 2: sprites
        
        bank0AddressSteer   : OUT integer range 0 to 4; --0: text map, 1: bitmap 0, 2: bitmop 2, 3: sprite 0, 4: sprite 1
        bank1AddressSteer   : OUT integer range 0 to 2; --0: tile A map, 1: bitmap 0, 2: sprite 1
        bank2AddressSteer   : OUT integer range 0 to 3; --0: tile A graphics, 1: bitmap 1, 2: sprite 0, 3: sprite 2
        bank3AddressSteer   : OUT integer range 0 to 4; --0: tile B map, 1: affine map 0, 2: bitmap  3, 3: sprite 0, 4: sprite 2
        bank4AddressSteer   : OUT integer range 0 to 4; --0: tile B graphics, 1: affine map 1, 2: bitmap 2, 3: sprite 1, 4: sprite 3
        bank5AddressSteer   : OUT integer range 0 to 3; --0: affine graphics 0, 1: bitmap 0, 2: bitmap 4, 3: sprite 0
        bank6AddressSteer   : OUT integer range 0 to 4; --0: affine graphics 1, 1: bitamp 1, 2: bitmap 5, 3: sprite 1, 4: sprite 2
        
        bitmap0DataSteer    : OUT integer range 0 to 2; --0: bank 0, 1: bank 1, 2: bank 5
        bitmap1DataSteer    : OUT integer range 0 to 2; --0: bank 1, 1: bank 2, 3: bank 6
        bitmap2DataSteer    : OUT integer range 0 to 1; --0: bank 0, 1: bank 4
        
        sprite0DataSteer    : OUT integer range 0 to 3; --0: bank 0, 1: bank 2, 2: bank 3, 3: bank 5
        sprite1DataSteer    : OUT integer range 0 to 3; --0: bank 0, 1: bank 1, 2: bank 4, 3: bank 6
        sprite2DataSteer    : OUT integer range 0 to 3; --0: bank 2, 1: bank 3, 2: bank 6
        
        bitmapResolution    : OUT integer range 0 to 1; --0: 320x240, 1: 160x130
        bitmapColorDepth    : OUT integer range 0 to 5  --0: 1bpp, 1: 2bpp, 2: 3bpp, 3: 4bpp, 4: 5bpp, 5: 8bpp
    );
end graphics_mode_decocder;

architecture Behavioral of graphics_mode_decocder is

    SIGNAL enableText       : STD_LOGIC := '0';
    SIGNAL enableTileA      : STD_LOGIC := '0';
    SIGNAL enableTileB      : STD_LOGIC := '0';
    SIGNAL enableSprites    : STD_LOGIC := '0';
    SIGNAL enableAffine     : STD_LOGIC := '0';
    SIGNAL enableBitmap     : STD_LOGIC := '0';
    
BEGIN

    PROCESS(GRAPHICS_MODE)
    BEGIN
        enableText <= '0';
        enableTileA <= '0';
        enableTileB <= '0';
        enableSprites <= '0';
        enableAffine <= '0';
        enableBitmap <= '0';
    
        buffer0Steer <= 0; --blank
        buffer1Steer <= 0; --blank
        buffer2Steer <= 0; --blank
        buffer3Steer <= 0; --blank
        
        bank0AddressSteer <= 0; --text map
        bank1AddressSteer <= 0; --tile A map
        bank2AddressSteer <= 0; --tile A graphics
        bank3AddressSteer <= 0; --tile B map
        bank4AddressSteer <= 0; --tile B graphics
        bank5AddressSteer <= 0; --affine graphics 0
        bank6AddressSteer <= 0; --affine graphics 1
        
        bitmap0DataSteer <= 0; --bank 0
        bitmap1DataSteer <= 0; --bank 1
        bitmap2DataSteer <= 0; --bank 0
        
        sprite0DataSteer <= 0; --bank 0
        sprite1DataSteer <= 0; --bank 0
        sprite2DataSteer <= 0; --bank 2
        
        bitmapResolution <= 0; --320x240
        bitmapColorDepth <= 0; --1bpp
        
        CASE GRAPHICS_MODE IS
            WHEN 0 => 
                --Tile A, Tile B, 8bpp Bitmap 160x120
                --memory banks: Bitmap 2, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Bitmap 0, Bitmap 1
                --output buffers: Blank, Tile A, Tile B, Bitmap

                enableTileA <= '1';
                enableTileB <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 5;  --8bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 2; --Bitmap 2
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 0; --Bank 0

            WHEN 1 => 
                --Text, Tile A, Tile B, 4bpp Bitmap 160x120
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Bitmap 0, Bitmap 1
                --output buffers: Text, Tile A, Tile B, Bitmap

                enableText <= '1';
                enableTileA <= '1';
                enableTileB <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 2 => 
                --Text, Tile A, 8K Sprites, 8bpp Bitmap 160x120
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Sprite 0, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Text, Tile A, Sprites, Bitmap

                enableText <= '1';
                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 5;  --8bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 3 => 
                --Tile A, Tile B, 8K Sprites, 4bpp Bitmap 160x120
                --memory banks: Sprite 0, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Bitmap 0, Bitmap 1
                --output buffers: Sprites, Tile A, Tile B, Bitmap

                enableTileA <= '1';
                enableTileB <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 2; --Sprites
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 0; --Bank 0

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 4 => 
                --Tile A, 16K Sprites, 8bpp Bitmap 160x120
                --memory banks: Sprite 1, Tile A Map, Tile A Gfx, Sprite 0, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Blank, Tile A, Sprites, Bitmap

                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 5;  --8bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 4; --Sprite 1
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 0; --Bank 0

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 5 => 
                --Text, Tile A, 16K Sprites, 4bpp Bitmap 160x120
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Sprite 0, Sprite 1, Bitmap 0, Bitmap 1
                --output buffers: Text, Tile A, Sprites, Bitmap

                enableText <= '1';
                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 3; --Sprite 1
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 2; --Bank 4

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 6 => 
                --Tile A, Tile B, 16K Sprites, 2bpp Bitmap 160x120
                --memory banks: Sprite 0, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Bitmap 0, Sprite 1
                --output buffers: Sprites, Tile A, Tile B, Bitmap

                enableTileA <= '1';
                enableTileB <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 2; --Sprites
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 3; --Sprite 1

                sprite0DataSteer <= 0; --Bank 0
                sprite1DataSteer <= 3; --Bank 6

                bitmap0DataSteer <= 2; --Bank 5

            WHEN 7 => 
                --Text, Tile A, Tile B, 16K Sprites
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Sprite 0, Sprite 1
                --output buffers: Text, Tile A, Tile B, Sprites

                enableText <= '1';
                enableTileA <= '1';
                enableTileB <= '1';
                enableSprites <= '1';

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 2; --Sprites

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 3; --Sprite 0
                bank6AddressSteer <= 3; --Sprite 1

                sprite0DataSteer <= 3; --Bank 5
                sprite1DataSteer <= 3; --Bank 6

            WHEN 8 => 
                --Text, 24K Sprites, 8bpp Bitmap 160x120
                --memory banks: Text Map, Sprite 1, Sprite 2, Sprite 0, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Text, Blank, Sprites, Bitmap

                enableText <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 5;  --8bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 3; --Sprite 2
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 1; --Bank 1
                sprite2DataSteer <= 0; --Bank 2

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 9 => 
                --Tile A, 24K Sprites, 4bpp Bitmap 160x120
                --memory banks: Sprite 0, Tile A Map, Tile A Gfx, Sprite 2, Sprite 1, Bitmap 0, Bitmap 1
                --output buffers: Blank, Tile A, Sprites, Bitmap

                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 4; --Sprite 2
                bank4AddressSteer <= 3; --Sprite 1
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 0; --Bank 0
                sprite1DataSteer <= 2; --Bank 4
                sprite2DataSteer <= 1; --Bank 3

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 10 => 
                --Text, Tile A, 24K Sprites, 2bpp Bitmap 160x120
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Sprite 0, Sprite 1, Bitmap 0, Sprite 2
                --output buffers: Text, Tile A, Sprites, Bitmap

                enableText <= '1';
                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 3; --Sprite 1
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 4; --Sprite 2

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 2; --Bank 4
                sprite2DataSteer <= 2; --Bank 6

                bitmap0DataSteer <= 2; --Bank 5

            WHEN 11 => 
                --Tile A, Tile B, 24K Sprites
                --memory banks: Sprite 1, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Sprite 0, Sprite 2
                --output buffers: Blank, Tile A, Tile B, Sprites

                enableTileA <= '1';
                enableTileB <= '1';
                enableSprites <= '1';

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 2; --Sprites

                bank0AddressSteer <= 4; --Sprite 1
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 3; --Sprite 0
                bank6AddressSteer <= 4; --Sprite 2

                sprite0DataSteer <= 3; --Bank 5
                sprite1DataSteer <= 0; --Bank 0
                sprite2DataSteer <= 2; --Bank 6

            WHEN 12 => 
                --32K Sprites, 8bpp Bitmap 160x120
                --memory banks: Bitmap 2, Sprite 1, Sprite 2, Sprite 0, Sprite 3, Bitmap 0, Bitmap 1
                --output buffers: Blank, Blank, Sprites, Bitmap

                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 5;  --8bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 2; --Bitmap 2
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 3; --Sprite 2
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 4; --Sprite 3
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 1; --Bank 1
                sprite2DataSteer <= 0; --Bank 2

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 0; --Bank 0

            WHEN 13 => 
                --Text, 32K Sprites, 4bpp Bitmap 160x120
                --memory banks: Text Map, Sprite 1, Sprite 2, Sprite 0, Sprite 3, Bitmap 0, Bitmap 1
                --output buffers: Text, Blank, Sprites, Bitmap

                enableText <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 3; --Sprite 2
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 4; --Sprite 3
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 1; --Bank 1
                sprite2DataSteer <= 0; --Bank 2

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 14 => 
                --Tile A, 32K Sprites, 2bpp Bitmap 160x120
                --memory banks: Sprite 1, Tile A Map, Tile A Gfx, Sprite 0, Sprite 3, Bitmap 0, Sprite 2
                --output buffers: Blank, Tile A, Sprites, Bitmap

                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 4; --Sprite 1
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 4; --Sprite 3
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 4; --Sprite 2

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 0; --Bank 0
                sprite2DataSteer <= 2; --Bank 6

                bitmap0DataSteer <= 2; --Bank 5

            WHEN 15 => 
                --Text, Tile A, 32K Sprites
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Sprite 2, Sprite 3, Sprite 0, Sprite 1
                --output buffers: Text, Tile A, Blank, Sprites

                enableText <= '1';
                enableTileA <= '1';
                enableSprites <= '1';

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 0; --Blank
                buffer3Steer <= 2; --Sprites

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 4; --Sprite 2
                bank4AddressSteer <= 4; --Sprite 3
                bank5AddressSteer <= 3; --Sprite 0
                bank6AddressSteer <= 3; --Sprite 1

                sprite0DataSteer <= 3; --Bank 5
                sprite1DataSteer <= 3; --Bank 6
                sprite2DataSteer <= 1; --Bank 3

            WHEN 16 => 
                --Affine, 8bpp Bitmap 160x120
                --memory banks: Bitmap 2, Bitmap 0, Bitmap 1, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Blank, Blank, Affine, Bitmap

                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 5;  --8bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 2; --Bitmap 2
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 1; --Bitmap 1
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 0; --Bank 2
                bitmap2DataSteer <= 0; --Bank 0

            WHEN 17 => 
                --Text, Affine, 4bpp Bitmap 160x120
                --memory banks: Text Map, Bitmap 0, Bitmap 1, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Text, Blank, Affine, Bitmap

                enableText <= '1';
                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 1; --Bitmap 1
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 0; --Bank 2

            WHEN 18 => 
                --Tile A, Affine, 2bpp Bitmap 160x120
                --memory banks: Bitmap 0, Tile A Map, Tile A Gfx, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Blank, Tile A, Affine, Bitmap

                enableTileA <= '1';
                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 1; --Bitmap 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                bitmap0DataSteer <= 0; --Bank 0

            WHEN 19 => 
                --Text, Tile A, Affine
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Text, Tile A, Affine, Blank

                enableText <= '1';
                enableTileA <= '1';
                enableAffine <= '1';

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 0; --Blank

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1



            WHEN 20 => 
                --Affine, 8K Sprites, 4bpp Bitmap 160x120
                --memory banks: Sprite 0, Bitmap 0, Bitmap 1, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Blank, Affine, Sprites, Bitmap

                enableSprites <= '1';
                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 2; --Affine
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 1; --Bitmap 1
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                sprite0DataSteer <= 0; --Bank 0

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 0; --Bank 2

            WHEN 21 => 
                --Text, Affine, 8K Sprites, 2bpp Bitmap 160x120
                --memory banks: Text Map, Bitmap 0, Sprite 0, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Text, Affine, Sprites, Bitmap

                enableText <= '1';
                enableSprites <= '1';
                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 2; --Affine
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 2; --Sprite 0
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                sprite0DataSteer <= 1; --Bank 2

                bitmap0DataSteer <= 1; --Bank 1

            WHEN 22 => 
                --Tile A, Affine, 8K Sprites
                --memory banks: Sprite 0, Tile A Map, Tile A Gfx, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Blank, Tile A, Affine, Sprites

                enableTileA <= '1';
                enableSprites <= '1';
                enableAffine <= '1';

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 2; --Sprites

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                sprite0DataSteer <= 0; --Bank 0

            WHEN 23 => 
                --Affine, 16K Sprites, 2bpp Bitmap 160x120
                --memory banks: Bitmap 0, Sprite 1, Sprite 0, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Blank, Affine, Sprites, Bitmap

                enableSprites <= '1';
                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapResolution <= 1;  --160x120
                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 2; --Affine
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 1; --Bitmap 0
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 2; --Sprite 0
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                sprite0DataSteer <= 1; --Bank 2
                sprite1DataSteer <= 1; --Bank 1

                bitmap0DataSteer <= 0; --Bank 0

            WHEN 24 => 
                --Text, Affine, 16K Sprites
                --memory banks: Text Map, Sprite 1, Sprite 0, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Text, Blank, Affine, Sprites

                enableText <= '1';
                enableSprites <= '1';
                enableAffine <= '1';

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 2; --Sprites

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 2; --Sprite 0
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                sprite0DataSteer <= 1; --Bank 2
                sprite1DataSteer <= 1; --Bank 1

            WHEN 25 => 
                --Affine, 24K Sprites
                --memory banks: Sprite 0, Sprite 1, Sprite 2, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Blank, Blank, Affine, Sprites

                enableSprites <= '1';
                enableAffine <= '1';

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 2; --Sprites

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 3; --Sprite 2
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                sprite0DataSteer <= 0; --Bank 0
                sprite1DataSteer <= 1; --Bank 1
                sprite2DataSteer <= 0; --Bank 2

            WHEN 26 => 
                --Text, 5bpp Bitmap 320x240
                --memory banks: Text Map, Bitmap 0, Bitmap 1, Bitmap 3, Bitmap 2, Bitmap 4, Bitmap 5
                --output buffers: Text, Blank, Blank, Bitmap

                enableText <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 4;  --5bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 0; --Blank
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 1; --Bitmap 1
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 2; --Bitmap 4
                bank6AddressSteer <= 2; --Bitmap 5

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 0; --Bank 2
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 27 => 
                --Tile A, 4bpp Bitmap 320x240
                --memory banks: Bitmap 0, Tile A Map, Tile A Gfx, Bitmap 3, Bitmap 2, Bitmap 4, Bitmap 1
                --output buffers: Blank, Tile A, Blank, Bitmap

                enableTileA <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 0; --Blank
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 1; --Bitmap 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 2; --Bitmap 4
                bank6AddressSteer <= 1; --Bitmap 1

                bitmap0DataSteer <= 0; --Bank 0
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 28 => 
                --Text, Tile A, 3bpp Bitmap 320x240
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Bitmap 3, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Text, Tile A, Blank, Bitmap

                enableText <= '1';
                enableTileA <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 2;  --3bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 0; --Blank
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 29 => 
                --Tile A, Tile B, 2bpp Bitmap 320x240
                --memory banks: Bitmap 2, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Bitmap 0, Bitmap 1
                --output buffers: Blank, Tile A, Tile B, Bitmap

                enableTileA <= '1';
                enableTileB <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 2; --Bitmap 2
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 0; --Bank 0

            WHEN 30 => 
                --Text, Tile A, Tile B, 1bpp Bitmap 320x240
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Bitmap 0, Bitmap 1
                --output buffers: Text, Tile A, Tile B, Bitmap

                enableText <= '1';
                enableTileA <= '1';
                enableTileB <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 0;  --1bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 31 => 
                --8K Sprites, 5bpp Bitmap 320x240
                --memory banks: Sprite 0, Bitmap 0, Bitmap 1, Bitmap 3, Bitmap 2, Bitmap 4, Bitmap 5
                --output buffers: Blank, Blank, Sprites, Bitmap

                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 4;  --5bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 1; --Bitmap 1
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 2; --Bitmap 4
                bank6AddressSteer <= 2; --Bitmap 5

                sprite0DataSteer <= 0; --Bank 0

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 0; --Bank 2
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 32 => 
                --Text, 8K Sprites, 4bpp Bitmap 320x240
                --memory banks: Text Map, Bitmap 0, Sprite 0, Bitmap 3, Bitmap 2, Bitmap 4, Bitmap 1
                --output buffers: Text, Blank, Sprites, Bitmap

                enableText <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 2; --Sprite 0
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 2; --Bitmap 4
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 1; --Bank 2

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 33 => 
                --Tile A, 8K Sprites, 3bpp Bitmap 320x240
                --memory banks: Sprite 0, Tile A Map, Tile A Gfx, Bitmap 3, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Blank, Tile A, Sprites, Bitmap

                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 2;  --3bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 0; --Bank 0

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 34 => 
                --Text, Tile A, 8K Sprites, 2bpp Bitmap 320x240
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Sprite 0, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Text, Tile A, Sprites, Bitmap

                enableText <= '1';
                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 35 => 
                --Tile A, Tile B, 8K Sprites, 1bpp Bitmap 320x240
                --memory banks: Sprite 0, Tile A Map, Tile A Gfx, Tile B Map, Tile B Gfx, Bitmap 0, Bitmap 1
                --output buffers: Sprites, Tile A, Tile B, Bitmap

                enableTileA <= '1';
                enableTileB <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 0;  --1bpp

                buffer0Steer <= 2; --Sprites
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 1; --Tile B
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 0; --Tile B Map
                bank4AddressSteer <= 0; --Tile B Gfx
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 0; --Bank 0

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 36 => 
                --16K Sprites, 4bpp Bitmap 320x240
                --memory banks: Bitmap 0, Sprite 1, Sprite 0, Bitmap 3, Bitmap 2, Bitmap 4, Bitmap 1
                --output buffers: Blank, Blank, Sprites, Bitmap

                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 3;  --4bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 1; --Bitmap 0
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 2; --Sprite 0
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 2; --Bitmap 4
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 1; --Bank 2
                sprite1DataSteer <= 1; --Bank 1

                bitmap0DataSteer <= 0; --Bank 0
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 37 => 
                --Text, 16K Sprites, 3bpp Bitmap 320x240
                --memory banks: Text Map, Sprite 1, Sprite 0, Bitmap 3, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Text, Blank, Sprites, Bitmap

                enableText <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 2;  --3bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 2; --Sprite 0
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 1; --Bank 2
                sprite1DataSteer <= 1; --Bank 1

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 38 => 
                --Tile A, 16K Sprites, 2bpp Bitmap 320x240
                --memory banks: Sprite 1, Tile A Map, Tile A Gfx, Sprite 0, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Blank, Tile A, Sprites, Bitmap

                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 4; --Sprite 1
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 0; --Bank 0

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 39 => 
                --Text, Tile A, 16K Sprites, 1bpp Bitmap 320x240
                --memory banks: Text Map, Tile A Map, Tile A Gfx, Sprite 0, Sprite 1, Bitmap 0, Bitmap 1
                --output buffers: Text, Tile A, Sprites, Bitmap

                enableText <= '1';
                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 0;  --1bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 3; --Sprite 1
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 2; --Bank 4

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 40 => 
                --24K Sprites, 3bpp Bitmap 320x240
                --memory banks: Sprite 0, Sprite 1, Sprite 2, Bitmap 3, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Blank, Blank, Sprites, Bitmap

                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 2;  --3bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 3; --Sprite 2
                bank3AddressSteer <= 2; --Bitmap 3
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 0; --Bank 0
                sprite1DataSteer <= 1; --Bank 1
                sprite2DataSteer <= 0; --Bank 2

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 41 => 
                --Text, 24K Sprites, 2bpp Bitmap 320x240
                --memory banks: Text Map, Sprite 1, Sprite 2, Sprite 0, Bitmap 2, Bitmap 0, Bitmap 1
                --output buffers: Text, Blank, Sprites, Bitmap

                enableText <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 3; --Sprite 2
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 2; --Bitmap 2
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 1; --Bank 1
                sprite2DataSteer <= 0; --Bank 2

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 1; --Bank 4

            WHEN 42 => 
                --Tile A, 24K Sprites, 1bpp Bitmap 320x240
                --memory banks: Sprite 0, Tile A Map, Tile A Gfx, Sprite 2, Sprite 1, Bitmap 0, Bitmap 1
                --output buffers: Blank, Tile A, Sprites, Bitmap

                enableTileA <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 0;  --1bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 1; --Tile A
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 0; --Tile A Map
                bank2AddressSteer <= 0; --Tile A Gfx
                bank3AddressSteer <= 4; --Sprite 2
                bank4AddressSteer <= 3; --Sprite 1
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 0; --Bank 0
                sprite1DataSteer <= 2; --Bank 4
                sprite2DataSteer <= 1; --Bank 3

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 43 => 
                --32K Sprites, 2bpp Bitmap 320x240
                --memory banks: Bitmap 2, Sprite 1, Sprite 2, Sprite 0, Sprite 3, Bitmap 0, Bitmap 1
                --output buffers: Blank, Blank, Sprites, Bitmap

                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 2; --Bitmap 2
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 3; --Sprite 2
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 4; --Sprite 3
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 1; --Bank 1
                sprite2DataSteer <= 0; --Bank 2

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6
                bitmap2DataSteer <= 0; --Bank 0

            WHEN 44 => 
                --Text, 32K Sprites, 1bpp Bitmap 320x240
                --memory banks: Text Map, Sprite 1, Sprite 2, Sprite 0, Sprite 3, Bitmap 0, Bitmap 1
                --output buffers: Text, Blank, Sprites, Bitmap

                enableText <= '1';
                enableSprites <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 0;  --1bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 2; --Sprite 1
                bank2AddressSteer <= 3; --Sprite 2
                bank3AddressSteer <= 3; --Sprite 0
                bank4AddressSteer <= 4; --Sprite 3
                bank5AddressSteer <= 1; --Bitmap 0
                bank6AddressSteer <= 1; --Bitmap 1

                sprite0DataSteer <= 2; --Bank 3
                sprite1DataSteer <= 1; --Bank 1
                sprite2DataSteer <= 0; --Bank 2

                bitmap0DataSteer <= 2; --Bank 5
                bitmap1DataSteer <= 1; --Bank 6

            WHEN 45 => 
                --Affine, 2bpp Bitmap 320x240
                --memory banks: Bitmap 2, Bitmap 0, Bitmap 1, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Blank, Blank, Affine, Bitmap

                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 1;  --2bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 2; --Bitmap 2
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 1; --Bitmap 1
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 0; --Bank 2
                bitmap2DataSteer <= 0; --Bank 0

            WHEN 46 => 
                --Text, Affine, 1bpp Bitmap 320x240
                --memory banks: Text Map, Bitmap 0, Bitmap 1, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Text, Blank, Affine, Bitmap

                enableText <= '1';
                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 0;  --1bpp

                buffer0Steer <= 1; --Text
                buffer1Steer <= 0; --Blank
                buffer2Steer <= 2; --Affine
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 0; --Text Map
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 1; --Bitmap 1
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 0; --Bank 2

            WHEN 47 => 
                --Affine, 8K Sprites, 1bpp Bitmap 320x240
                --memory banks: Sprite 0, Bitmap 0, Bitmap 1, Affine Map 0, Affine Map 1, Affine Gfx 0, Affine Gfx 1
                --output buffers: Blank, Affine, Sprites, Bitmap

                enableSprites <= '1';
                enableAffine <= '1';
                enableBitmap <= '1';

                bitmapColorDepth <= 0;  --1bpp

                buffer0Steer <= 0; --Blank
                buffer1Steer <= 2; --Affine
                buffer2Steer <= 2; --Sprites
                buffer3Steer <= 1; --Bitmap

                bank0AddressSteer <= 3; --Sprite 0
                bank1AddressSteer <= 1; --Bitmap 0
                bank2AddressSteer <= 1; --Bitmap 1
                bank3AddressSteer <= 1; --Affine Map 0
                bank4AddressSteer <= 1; --Affine Map 1
                bank5AddressSteer <= 0; --Affine Gfx 0
                bank6AddressSteer <= 0; --Affine Gfx 1

                sprite0DataSteer <= 0; --Bank 0

                bitmap0DataSteer <= 1; --Bank 1
                bitmap1DataSteer <= 0; --Bank 2

            WHEN OTHERS =>
                
                enableText <= '0';
                enableTileA <= '0';
                enableTileB <= '0';
                enableSprites <= '0';
                enableAffine <= '0';
                enableBitmap <= '0';
            
                buffer0Steer <= 0; --0: blank, 1: text, 2: sprites
                buffer1Steer <= 0; --0: blank, 1: tile A, 2: affine
                buffer2Steer <= 0; --0: blank, 1: tile B, 2: affine, 3: sprites
                buffer3Steer <= 0; --0: blank, 1: bitmap, 2: sprites
                
                bank0AddressSteer <= 0; --0: text map, 1: bitmap 0, 2: bitmop 2, 3: sprite 0, 4: sprite 1
                bank1AddressSteer <= 0; --0: tile A map, 1: bitmap 0, 2: bitmap 1, 3: sprite 1
                bank2AddressSteer <= 0; --0: tile A graphics, 1: bitmap 1, 2: sprite 0, 3: sprite 2
                bank3AddressSteer <= 0; --0: tile B map, 1: affine map 0, 2: bitmap  3, 3: sprite 0, 4: sprite 2
                bank4AddressSteer <= 0; --0: tile B graphics, 1: affine map 1, 2: bitmap 2, 3: sprite 1, 4: sprite 3
                bank5AddressSteer <= 0; --0: affine graphics 0, 1: bitmap 0, 2: bitmap 4, 3: sprite 0
                bank6AddressSteer <= 0; --0: affine graphics 1, 1: bitamp 1, 2: bitmap 5, 3: sprite 1, 4: sprite 2
                
                bitmap0DataSteer <= 0; --0: bank 0, 1: bank 1, 2: bank 5
                bitmap1DataSteer <= 0; --0: bank 1, 1: bank 2, 3: bank 6
                bitmap2DataSteer <= 0; --0: bank 0, 1: bank 4
                
                sprite0DataSteer <= 0; --0: bank 0, 1: bank 2, 2: bank 3, 3: bank 5
                sprite1DataSteer <= 0; --0: bank 0, 1: bank 1, 2: bank 4, 3: bank 6
                sprite2DataSteer <= 0; --0: bank 2, 1: bank 3, 2: bank 6
                
                bitmapResolution <= 0; --0: 320x240, 1: 160x130
                bitmapColorDepth <= 0; --0: 1bpp, 1: 2bpp, 2: 3bpp, 3: 4bpp, 4: 5bpp, 5: 8bpp
        
        END CASE;
    END PROCESS;
    
    layerEnable <= "00" & enableBitmap & enableAffine & enableSprites & enableTileB & enableTileA & enableText;
    
end Behavioral;