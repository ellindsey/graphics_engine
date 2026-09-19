LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY affine_engine IS
    PORT(
        CLK25M                      : IN  STD_LOGIC;
        CLK100M                     : IN  STD_LOGIC;
        RESET_LINE                  : IN  STD_LOGIC;
        RESET_SCREEN                : IN  STD_LOGIC;
        RUN                         : IN  STD_LOGIC;
        LINE_TO_DRAW                : IN  integer range 0 to 239;
        DONE                        : OUT STD_LOGIC;
        
        AFFINE_TRANS_FLAG           : IN  STD_LOGIC;
        AFFINE_TRANS_COLOR          : IN  STD_LOGIC_VECTOR(7 downto 0);
        AFFINE_LAYER                : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        AFFINE_EDGE_REPEAT          : IN  STD_LOGIC;
         
        CPU_ADDR                    : IN  integer range 0 to 15;
        CPU_WDATA                   : IN  STD_LOGIC_VECTOR(7 downto 0);
        CPU_RDATA                   : OUT STD_LOGIC_VECTOR(7 downto 0);
        CPU_WE                      : IN  STD_LOGIC;
        
        COPPER_ADDRESS_IN           : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        COPPER_DATA_IN              : IN  STD_LOGIC_VECTOR(15 downto 0);
        COPPER_DATA_OUT             : OUT STD_LOGIC_VECTOR(15 downto 0);
        COPPER_WRITE_STROBE         : IN  STD_LOGIC;
        COPPER_BYTE_FLAGS           : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        AFFINE_MAP_READ_ADDRESS     : OUT integer range 0 to 16383;
        AFFINE_MAP_READ_DATA        : IN  STD_LOGIC_VECTOR(7 downto 0);
        
        AFFINE_GFX_READ_ADDRESS     : OUT integer range 0 to 16383;
        AFFINE_GFX_READ_DATA        : IN  STD_LOGIC_VECTOR(7 downto 0);
        
        BUFFER_WRITE_ADDRESS        : OUT integer range 0 to 319;
        BUFFER_WRITE_DATA           : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE         : OUT STD_LOGIC
    );
END affine_engine;

ARCHITECTURE behavioral OF affine_engine IS
    type state_type is (state_reset,
                        state_wait_for_line_start,
                        state_do_math_1,
                        state_do_math_2,
                        state_tile_read_set_address,
                        state_tile_read_wait,
                        state_bitmap_read_set_address,
                        state_bitmap_read_wait,
                        state_write_pixel,
                        state_next_pixel,
                        state_line_done);
                        
    SIGNAL xaddress                 : integer range 0 to 319 := 0;
    SIGNAL next_xaddress            : integer range 0 to 319 := 0; 
    
    SIGNAL next_we                  : STD_LOGIC := '0';
    
    SIGNAL local_lineToDraw         : integer range 0 to 239;
    
    SIGNAL line_complete            : STD_LOGIC := '0';
    
    SIGNAL step                     : state_type := state_reset;
    SIGNAL next_step                : state_type := state_reset;
    
    SIGNAL next_done                : STD_LOGIC;
    
    SIGNAL pixel_color              : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    
    SIGNAL tileX                    : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
    SIGNAL next_tileX               : STD_LOGIC_VECTOR(6 DOWNTO 0);
    
    SIGNAL tileY                    : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
    SIGNAL next_tileY               : STD_LOGIC_VECTOR(6 DOWNTO 0);
    
    SIGNAL pixelX                   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL next_pixelX              : STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    SIGNAL pixelY                   : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL next_pixelY              : STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    SIGNAL tile_id                  : STD_LOGIC_VECTOR(7 downto 0);
    
    SIGNAL result_in_map            : STD_LOGIC;
        
    SIGNAL calculated_map_X         : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL calculated_map_Y         : STD_LOGIC_VECTOR(9 DOWNTO 0);
    
    SIGNAL bread_addr               : STD_LOGIC_VECTOR(13 DOWNTO 0) := "00000000000000";
    SIGNAL next_bread_addr          : STD_LOGIC_VECTOR(13 DOWNTO 0);
    
    SIGNAL tile_map_read_address    : STD_LOGIC_VECTOR(13 DOWNTO 0) := "00000000000000";
    
    SIGNAL affine_trans_flag_int    : STD_LOGIC;
    SIGNAL affine_trans_color_int   : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL affine_layer_int         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL affine_edge_repeat_int   : STD_LOGIC;
    
    type xaddress_action is (xaddress_zero,
                             xaddress_keep,
                             xaddress_step);
                             
    SIGNAL COPPER_ADDR              : integer range 0 to 7;
    --SIGNAL COPPER_BYTE_FLAGS        : STD_LOGIC_VECTOR(1 DOWNTO 0);
                         
    SIGNAL coeff0                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL coeff1                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL coeff2                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL coeff3                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL coeff4                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL coeff5                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL coeff6                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL coeff7                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    COMPONENT affine_memory IS
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
            C0                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            C1                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            C2                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            C3                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            C4                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            C5                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            C6                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            C7                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
            );
    END COMPONENT affine_memory;                         
                             
    COMPONENT affine_math IS
        PORT(
            clk                         : IN  STD_LOGIC;
            xin                         : IN  integer range 0 to 319;
            yin                         : IN  integer range 0 to 239;
            xoff                        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            yoff                        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            a                           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            b                           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            c                           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            d                           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            xc                          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            yc                          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            xout                        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            yout                        : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            in_map                      : OUT STD_LOGIC
            );
    END COMPONENT affine_math;
                             
--General sequence of operation:
--At the start of each line, fetch all coefficients from memory. (Or do this during hblank instead? Need to check timing margin.)
--For each pixel, take the X and Y screen address, and then perform the matrix math required to get the position on the map.
--Using the upper 7 bits of map position X and Y, fetch the tile ID for this position on the map.
--Using the tile ID and the lower 3 bits of X and Y to get the pixel color for that pixel on that tile.
--Output that pixel to the screen and then go on to the next pixel.

--Position on screen is 0-319 for X (9 bits) and 0-239 for Y (8 bits)
--Position on map is 0-1023 (10 bits) for X and Y
--Map is 128x128 tiles, each tile is 8x8 pixels (16K of map space)
--256 possible tiles (16K of bitmap space)
--No tile animation or flip/rotate
--No tile-to-sprite collision detection

--flag determines how pixels off the edge of the map are handled.

--Sequence of events:
--Wait for the start of the line
--Load coefficients (16x 16 bit values)
--For each pixel on the screen:
--    Canculate translated position on the tile map
--    From that, determine tile and pixel position in the tile
--    Load the tile data from the tile map
--    Load the pixel data from the tile graphics for that pixel in that tile
--    Write that pixel data out to the graphics buffer (and do transparency check in the process)
--Wait for the horizontal blanking period

--Memory map:
--0x0060-0x0061     X offset            10.6 fixed point signed     default 0.0
--0x0062-0x0063     Y offset            10.6 fixed point signed     default 0.0
--0x0064-0x0065     Transform matrix A  8.8 fixed point signed      default 1.0
--0x0066-0x0067     Transform matrix B  8.8 fixed point signed      default 0.0
--0x0068-0x0069     Transform matrix C  8.8 fixed point signed      default 0.0
--0x006A-0x006B     Transform matrix D  8.8 fixed point signed      default 1.0
--0x006C-0x006D     X center            10.6 fixed point unsigned   default 159.0
--0x006E-0x006F     Y center            10.6 fixed point unsigned   default 119.0

BEGIN

    PROCESS(AFFINE_GFX_READ_DATA,CLK100M)
    BEGIN
        IF RISING_EDGE(CLK100M)THEN
            pixel_color <= AFFINE_GFX_READ_DATA;
            tile_id <= AFFINE_MAP_READ_DATA;
        END IF;
    END PROCESS;

    PROCESS(xaddress)
    BEGIN
        IF xaddress = 319 THEN
            line_complete <= '1';
        ELSE
            line_complete <= '0';
        END IF;
    END PROCESS;
    
    PROCESS(LINE_TO_DRAW,CLK100M)
    BEGIN
        IF RISING_EDGE(CLK100M) THEN
            local_lineToDraw         <= LINE_TO_DRAW;
            affine_trans_flag_int    <= AFFINE_TRANS_FLAG;
            affine_trans_color_int   <= AFFINE_TRANS_COLOR;
            affine_layer_int         <= AFFINE_LAYER;
            affine_edge_repeat_int   <= AFFINE_EDGE_REPEAT;
        END IF;
    END PROCESS;
        
    --Affine matrix values stored locally in registers rather than using a BRAM.
    
    COPPER_ADDR <= to_integer(unsigned(COPPER_ADDRESS_IN));
    
    amem : affine_memory
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
            C0              => coeff0,
            C1              => coeff1,
            C2              => coeff2,
            C3              => coeff3,
            C4              => coeff4,
            C5              => coeff5,
            C6              => coeff6,
            C7              => coeff7
            );

    amath: affine_math 
        PORT MAP(
            clk     => clk100M,
            xin     => xaddress,
            yin     => local_lineToDraw,
            xoff    => coeff0,
            yoff    => coeff1,
            a       => coeff2,
            b       => coeff3,
            c       => coeff4,
            d       => coeff5,
            xc      => coeff6,
            yc      => coeff7,
            xout    => calculated_map_X,
            yout    => calculated_map_Y,
            in_map  => result_in_map
            );
               
    PROCESS(step,CLK100M,RUN,RESET_LINE,line_complete,calculated_map_X,calculated_map_Y,tileX,tileY,
            pixelX,pixelY,tile_id,bread_addr,xaddress)
        VARIABLE next_xaddress_action       : xaddress_action;   
        VARIABLE loadAddr                   : STD_LOGIC;
        VARIABLE loadBAddr                  : STD_LOGIC;
    BEGIN
        CASE step IS
            WHEN state_reset =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_zero;
                    
                IF RUN THEN
                    next_step <= state_line_done;
                ELSE
                    next_step <= state_reset;
                END IF;
                        
            WHEN state_wait_for_line_start =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_zero;
                
                IF RESET_LINE THEN
                    next_step <= state_wait_for_line_start;
                ELSE
                    next_step <= state_do_math_1;
                END IF;
                
            WHEN state_do_math_1 =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_keep;
                
                next_step <= state_do_math_2;
            
            WHEN state_do_math_2 =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_keep;
                
                next_step <= state_tile_read_set_address;
            
            WHEN state_tile_read_set_address =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '1';
                loadBAddr := '0';
                next_xaddress_action := xaddress_keep;
                
                next_step <= state_tile_read_wait;
            
            WHEN state_tile_read_wait =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_keep;
                
                next_step <= state_bitmap_read_set_address;
            
            WHEN state_bitmap_read_set_address =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '1';
                next_xaddress_action := xaddress_keep;
                
                next_step <= state_bitmap_read_wait;
            
            WHEN state_bitmap_read_wait =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_keep;
                
                next_step <= state_write_pixel;
            
            WHEN state_write_pixel =>
                next_we <= '1';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_keep;
                
                IF (line_complete) THEN   
                    next_step <= state_line_done;
                ELSE
                    next_step <= state_next_pixel;
                END IF;
            
            WHEN state_next_pixel =>
                next_we <= '0';
                next_done <= '0';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_step;
                
                next_step <= state_do_math_1;
                    
            WHEN state_line_done =>
                next_we <= '0';
                next_done <= '1';
                
                loadAddr := '0';
                loadBAddr := '0';
                next_xaddress_action := xaddress_zero;
                    
                IF NOT RUN THEN
                    next_step <= state_reset;
                ELSIF RESET_LINE THEN
                    next_step <= state_wait_for_line_start;
                ELSE
                    next_step <= state_line_done;
                END IF;
                
            --WHEN OTHERS =>
            --    next_we <= '0';
            --    next_done <= '0';
                
            --    loadAddr := '0';
            --    loadBAddr := '0';
            --    next_xaddress_action := xaddress_zero;
                    
            --    next_step <= state_reset;
        END CASE;
        
        --Bits 0-2 of our X and Y are our pixel X and Y.
        --Bits 3-9 of our X and Y are our tile X and Y.
        
        IF (loadAddr) THEN
            next_tileX <= calculated_map_X(9 downto 3);
            next_tileY <= calculated_map_Y(9 downto 3);
            next_pixelX <= calculated_map_X(2 downto 0);
            next_pixelY <= calculated_map_Y(2 downto 0);
        ELSE   
            next_tileX <= tileX;
            next_tileY <= tileY;
            next_pixelX <= pixelX;
            next_pixelY <= pixelY;
        END IF;
        
        IF (loadBAddr) THEN
            next_bread_addr <= tile_id & pixelY & pixelX;
        ELSE
            next_bread_addr <= bread_addr;
        END IF;
        
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
        
    END PROCESS;
    
    PROCESS(CLK100M)
    BEGIN
        IF RISING_EDGE(CLK100M)THEN
            step <= next_step;
            
            xaddress <= next_xaddress;
            
            BUFFER_WRITE_STROBE <= next_we;
            
            DONE <= next_done;
            
            tileX <= next_tileX;
            tileY <= next_tileY;
            pixelX <= next_pixelX;
            pixelY <= next_pixelY;
            
            bread_addr <= next_bread_addr;
        END IF;
    END PROCESS;
    
    PROCESS(AFFINE_LAYER,pixel_color,affine_trans_flag_int,affine_trans_color_int,affine_layer_int,affine_edge_repeat_int,result_in_map)
        VARIABLE adjusted_priority : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE adjusted_color : STD_LOGIC_VECTOR(7 downto 0);
    BEGIN
        IF affine_edge_repeat_int OR result_in_map THEN
            adjusted_color := pixel_color; 
            
            IF (affine_trans_flag_int='1') AND (pixel_color=affine_trans_color_int) THEN
                adjusted_priority := "00";
            ELSE
                adjusted_priority := affine_layer_int;
            END IF;
        ELSE
            adjusted_color := affine_trans_color_int; 
            
            IF (affine_trans_flag_int='1') THEN
                adjusted_priority := "00";
            ELSE
                adjusted_priority := affine_layer_int;
            END IF;
        END IF;
        
        BUFFER_WRITE_DATA <= adjusted_priority & adjusted_color;
    END PROCESS;
    
    tile_map_read_address <= tileY & tileX;
            
    AFFINE_MAP_READ_ADDRESS <= to_integer(unsigned(tile_map_read_address));
    AFFINE_GFX_READ_ADDRESS <= to_integer(unsigned(bread_addr));
    BUFFER_WRITE_ADDRESS <= xaddress;
    
END behavioral;