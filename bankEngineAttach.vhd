LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY bankEngineAttach IS
   PORT(
        clk                       : IN  STD_LOGIC;
        
        bank0AddressSelect        : IN  integer range 0 to 2; --Text map, Bitmap 9, or Sprite 4
        bank1AddressSelect        : IN  integer range 0 to 2; --Tile A map, Affine map 1, or Bitmap 8
        bank2AddressSelect        : IN  integer range 0 to 3; --Tile B map, Affine map 2, Bitmap 7, or Sprite 3
        bank3AddressSelect        : IN  integer range 0 to 2; --Tile A graphics, Affine graphics 1, or Bitmap 6
        bank4AddressSelect        : IN  integer range 0 to 3; --Tile B graphics, Affine graphics 2, Bitmap 5, or Sprite 4
        bank5AddressSelect        : IN  integer range 0 to 1; --Sprite 0 or Bitmap 4
        bank6AddressSelect        : IN  integer range 0 to 2; --Sprite 1, Bitmap 3, or Tile B map
        bank7AddressSelect        : IN  integer range 0 to 2; --Sprite 2, Bitmap 2, or Tile B graphics
        bank8AddressSelect        : IN  integer range 0 to 2; --Sprite 3, Bitmap 1, or Tile A map
        bank9AddressSelect        : IN  integer range 0 to 2; --Sprite 4, Bitmap 0, or Tile A graphics
        
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

        tile_map_2_read_address   : IN  integer range 0 to 2047;
        tile_map_2_read_data      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        tile_gfx_1_read_address   : IN  integer range 0 to 8191;
        tile_gfx_1_read_data      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
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
END bankEngineAttach;

ARCHITECTURE behavior OF bankEngineAttach IS

    SIGNAL bank0AddressSelectInt     : integer range 0 to 2;
    SIGNAL bank1AddressSelectInt     : integer range 0 to 2; --Tile A map, Affine map 1, or Bitmap 8
    SIGNAL bank2AddressSelectInt     : integer range 0 to 3; --Tile B map, Affine map 2, or Bitmap 7
    SIGNAL bank3AddressSelectInt     : integer range 0 to 2; --Tile A graphics, Affine graphics 1, or Bitmap 6
    SIGNAL bank4AddressSelectInt     : integer range 0 to 3; --Tile B graphics, Affine graphics 2, or Bitmap 5
    SIGNAL bank5AddressSelectInt     : integer range 0 to 1; --Sprite 0 or Bitmap 4
    SIGNAL bank6AddressSelectInt     : integer range 0 to 2; --Sprite 1, Bitmap 3, or Tile B map
    SIGNAL bank7AddressSelectInt     : integer range 0 to 2; --Sprite 2, Bitmap 2, or Tile B graphics
    SIGNAL bank8AddressSelectInt     : integer range 0 to 2; --Sprite 3, Bitmap 1, or Tile A map
    SIGNAL bank9AddressSelectInt     : integer range 0 to 2; --Sprite 4, Bitmap 0, or Tile A graphics
    
BEGIN

    -- Latch bank address select lines to internal registers.
    PROCESS(ALL)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            bank0AddressSelectInt <= bank0AddressSelect;
            bank1AddressSelectInt <= bank1AddressSelect;
            bank2AddressSelectInt <= bank2AddressSelect;
            bank3AddressSelectInt <= bank3AddressSelect;
            bank4AddressSelectInt <= bank4AddressSelect;
            bank5AddressSelectInt <= bank5AddressSelect;
            bank6AddressSelectInt <= bank6AddressSelect;
            bank7AddressSelectInt <= bank7AddressSelect;
            bank8AddressSelectInt <= bank8AddressSelect;
            bank9AddressSelectInt <= bank9AddressSelect;
        END IF;
    END PROCESS;
    
    --Text map always comes from bank 0
    text_map_read_data <= bank_0_read_data;
    
    --Select tile 1 map data from bank 1 or bank 8
    PROCESS(bank_1_read_data,bank_8_read_data,bank1AddressSelectInt)
    BEGIN
        CASE bank1AddressSelectInt IS
            WHEN 0 => --Tile A map
                tile_map_1_read_data <= bank_1_read_data;
            WHEN OTHERS =>
                tile_map_1_read_data <= bank_8_read_data;
        END CASE;
    END PROCESS;
    
    --Select tile 2 map data from bank 2 or bank 6
    PROCESS(bank_2_read_data,bank_6_read_data,bank2AddressSelectInt)
    BEGIN
        CASE bank2AddressSelectInt IS
            WHEN 0 => --Tile B map
                tile_map_2_read_data <= bank_2_read_data;
            WHEN OTHERS =>
                tile_map_2_read_data <= bank_6_read_data;
        END CASE;
    END PROCESS;
    
    --Select tile 1 graphics data from bank 3 or bank 9
    PROCESS(bank_3_read_data,bank_9_read_data,bank3AddressSelectInt)
    BEGIN
        CASE bank3AddressSelectInt IS
            WHEN 0 => --Tile A graphics
                tile_gfx_1_read_data <= bank_3_read_data;
            WHEN OTHERS =>
                tile_gfx_1_read_data <= bank_9_read_data;
        END CASE;
    END PROCESS;
    
    --Select tile 2 graphics data from bank 4 or bank 7
    PROCESS(bank_4_read_data,bank_7_read_data,bank4AddressSelectInt)
    BEGIN
        CASE bank4AddressSelectInt IS
            WHEN 0 => --Tile B graphics
                tile_gfx_2_read_data <= bank_4_read_data;
            WHEN OTHERS =>
                tile_gfx_2_read_data <= bank_7_read_data;
        END CASE;
    END PROCESS;
    
    --Select sprite graphics data from 8 possible banks according to upper graphics address bits.
    PROCESS(sprite_gfx_read_address,bank0AddressSelect,bank2AddressSelect,bank4AddressSelect,bank_0_read_data,bank_2_read_data,bank_4_read_data,bank_5_read_data,bank_6_read_data,bank_7_read_data,bank_8_read_data,bank_9_read_data)
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        CASE sprite_gfx_read_address_vec(15 downto 13) IS
            WHEN "000" => --sprite graphics 0
                sprite_gfx_read_data <= bank_5_read_data;
            WHEN "001" => --sprite graphics 1
                CASE sprite_gfx_read_address_vec(1 downto 0) IS
                    WHEN "00" =>
                        sprite_gfx_read_data <= bank_6_read_data(7 downto 0);
                    WHEN "01" =>
                        sprite_gfx_read_data <= bank_6_read_data(15 downto 8);
                    WHEN "10" =>
                        sprite_gfx_read_data <= bank_6_read_data(23 downto 16);
                    WHEN "11" =>
                        sprite_gfx_read_data <= bank_6_read_data(31 downto 24);
                    WHEN OTHERS =>
                        sprite_gfx_read_data <= "00000000";
                END CASE;
            WHEN "010" => --sprite graphics 2
                sprite_gfx_read_data <= bank_7_read_data;
            WHEN "011" => --sprite graphics 3
                CASE sprite_gfx_read_address_vec(1 downto 0) IS
                    WHEN "00" =>
                        sprite_gfx_read_data <= bank_8_read_data(7 downto 0);
                    WHEN "01" =>
                        sprite_gfx_read_data <= bank_8_read_data(15 downto 8);
                    WHEN "10" =>
                        sprite_gfx_read_data <= bank_8_read_data(23 downto 16);
                    WHEN "11" =>
                        sprite_gfx_read_data <= bank_8_read_data(31 downto 24);
                    WHEN OTHERS =>
                        sprite_gfx_read_data <= "00000000";
                END CASE;
            WHEN "100" => --sprite graphics 4
                sprite_gfx_read_data <= bank_9_read_data;
            WHEN "101" => --sprite graphics 5
                CASE sprite_gfx_read_address_vec(1 downto 0) IS
                    WHEN "00" =>
                        sprite_gfx_read_data <= bank_0_read_data(7 downto 0);
                    WHEN "01" =>
                        sprite_gfx_read_data <= bank_0_read_data(15 downto 8);
                    WHEN "10" =>
                        sprite_gfx_read_data <= bank_0_read_data(23 downto 16);
                    WHEN "11" =>
                        sprite_gfx_read_data <= bank_0_read_data(31 downto 24);
                    WHEN OTHERS =>
                        sprite_gfx_read_data <= "00000000";
                END CASE;
            WHEN "110" => --sprite graphics 6
                CASE sprite_gfx_read_address_vec(1 downto 0) IS
                    WHEN "00" =>
                        sprite_gfx_read_data <= bank_2_read_data(7 downto 0);
                    WHEN "01" =>
                        sprite_gfx_read_data <= bank_2_read_data(15 downto 8);
                    WHEN "10" =>
                        sprite_gfx_read_data <= bank_2_read_data(23 downto 16);
                    WHEN "11" =>
                        sprite_gfx_read_data <= bank_2_read_data(31 downto 24);
                    WHEN OTHERS =>
                        sprite_gfx_read_data <= "00000000";
                END CASE;
            WHEN "111" => --sprite graphics 7
                sprite_gfx_read_data <= bank_4_read_data;
            WHEN OTHERS =>
                sprite_gfx_read_data <= "00000000";
        END CASE;
    END PROCESS;
    
    --Select bitmap data from 10 possible banks according to upper bitmap address bits.
    --Blank data from banks if those banks are used by other engines.
    --Also do 32 to 8 bit selection as needed.
    PROCESS(bitmap_read_address,
            bank0AddressSelect,bank1AddressSelect,bank2AddressSelect,bank3AddressSelect,bank4AddressSelect,
            bank5AddressSelect,bank6AddressSelect,bank7AddressSelect,bank8AddressSelect,bank9AddressSelect,
            bank_0_read_data,bank_1_read_data,bank_2_read_data,bank_3_read_data,bank_4_read_data,
            bank_5_read_data,bank_6_read_data,bank_7_read_data,bank_8_read_data,bank_9_read_data)
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
    BEGIN
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        CASE bitmap_read_address_vec(16 downto 13) IS
            WHEN "0000" =>
                CASE bank9AddressSelect IS
                    WHEN 1 => --Bitmap
                        bitmap_read_data <= bank_9_read_data;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "0001" =>
                CASE bank8AddressSelect IS
                    WHEN 1 => --Bitmap
                        CASE bitmap_read_address_vec(1 downto 0) IS
                            WHEN "00" =>
                                bitmap_read_data <= bank_8_read_data(7 downto 0);
                            WHEN "01" =>
                                bitmap_read_data <= bank_8_read_data(15 downto 8);
                            WHEN "10" =>
                                bitmap_read_data <= bank_8_read_data(23 downto 16);
                            WHEN "11" =>
                                bitmap_read_data <= bank_8_read_data(31 downto 24);
                            WHEN OTHERS =>
                                bitmap_read_data <= "00000000";
                        END CASE;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "0010" =>
                CASE bank7AddressSelect IS
                    WHEN 1 => --Bitmap
                        bitmap_read_data <= bank_7_read_data;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "0011" =>
                CASE bank6AddressSelect IS
                    WHEN 1 => --Bitmap
                        CASE bitmap_read_address_vec(1 downto 0) IS
                            WHEN "00" =>
                                bitmap_read_data <= bank_6_read_data(7 downto 0);
                            WHEN "01" =>
                                bitmap_read_data <= bank_6_read_data(15 downto 8);
                            WHEN "10" =>
                                bitmap_read_data <= bank_6_read_data(23 downto 16);
                            WHEN "11" =>
                                bitmap_read_data <= bank_6_read_data(31 downto 24);
                            WHEN OTHERS =>
                                bitmap_read_data <= "00000000";
                        END CASE;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "0100" =>
                CASE bank5AddressSelect IS
                    WHEN 1 => --Bitmap
                        bitmap_read_data <= bank_5_read_data;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "0101" =>
                CASE bank4AddressSelect IS
                    WHEN 2 => --Bitmap
                        bitmap_read_data <= bank_4_read_data;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "0110" =>
                CASE bank3AddressSelect IS
                    WHEN 2 => --Bitmap
                        bitmap_read_data <= bank_3_read_data;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "0111" =>
                CASE bank2AddressSelect IS
                    WHEN 2 => --Bitmap
                        CASE bitmap_read_address_vec(1 downto 0) IS
                            WHEN "00" =>
                                bitmap_read_data <= bank_2_read_data(7 downto 0);
                            WHEN "01" =>
                                bitmap_read_data <= bank_2_read_data(15 downto 8);
                            WHEN "10" =>
                                bitmap_read_data <= bank_2_read_data(23 downto 16);
                            WHEN "11" =>
                                bitmap_read_data <= bank_2_read_data(31 downto 24);
                            WHEN OTHERS =>
                                bitmap_read_data <= "00000000";
                        END CASE;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "1000" =>
                CASE bank1AddressSelect IS
                    WHEN 2 => --Bitmap
                        CASE bitmap_read_address_vec(1 downto 0) IS
                            WHEN "00" =>
                                bitmap_read_data <= bank_1_read_data(7 downto 0);
                            WHEN "01" =>
                                bitmap_read_data <= bank_1_read_data(15 downto 8);
                            WHEN "10" =>
                                bitmap_read_data <= bank_1_read_data(23 downto 16);
                            WHEN "11" =>
                                bitmap_read_data <= bank_1_read_data(31 downto 24);
                            WHEN OTHERS =>
                                bitmap_read_data <= "00000000";
                        END CASE;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN "1001" =>
                CASE bank0AddressSelect IS
                    WHEN 1 => --Bitmap
                        CASE bitmap_read_address_vec(1 downto 0) IS
                            WHEN "00" =>
                                bitmap_read_data <= bank_0_read_data(7 downto 0);
                            WHEN "01" =>
                                bitmap_read_data <= bank_0_read_data(15 downto 8);
                            WHEN "10" =>
                                bitmap_read_data <= bank_0_read_data(23 downto 16);
                            WHEN "11" =>
                                bitmap_read_data <= bank_0_read_data(31 downto 24);
                            WHEN OTHERS =>
                                bitmap_read_data <= "00000000";
                        END CASE;
                    WHEN OTHERS =>
                        bitmap_read_data <= "00000000";
                END CASE;
            WHEN OTHERS =>
                bitmap_read_data <= "00000000";
        END CASE;
    END PROCESS;
    
    --Select affine map data from 2 possible banks, and also do 32 to 8 bit selection
    PROCESS(affine_map_read_address,bank_1_read_data,bank_2_read_data)
        VARIABLE affine_map_read_address_vec      : STD_LOGIC_VECTOR(13 DOWNTO 0);
    BEGIN
        affine_map_read_address_vec := std_logic_vector(to_unsigned(affine_map_read_address, 14));
        CASE affine_map_read_address_vec(13) IS
            WHEN '0' =>
                CASE affine_map_read_address_vec(1 downto 0) IS
                    WHEN "00" =>
                        affine_map_read_data <= bank_1_read_data(7 downto 0);
                    WHEN "01" =>
                        affine_map_read_data <= bank_1_read_data(15 downto 8);
                    WHEN "10" =>
                        affine_map_read_data <= bank_1_read_data(23 downto 16);
                    WHEN "11" =>
                        affine_map_read_data <= bank_1_read_data(31 downto 24);
                    WHEN OTHERS =>
                        affine_map_read_data <= "00000000";
                END CASE;
            WHEN '1' =>
                CASE affine_map_read_address_vec(1 downto 0) IS
                    WHEN "00" =>
                        affine_map_read_data <= bank_2_read_data(7 downto 0);
                    WHEN "01" =>
                        affine_map_read_data <= bank_2_read_data(15 downto 8);
                    WHEN "10" =>
                        affine_map_read_data <= bank_2_read_data(23 downto 16);
                    WHEN "11" =>
                        affine_map_read_data <= bank_2_read_data(31 downto 24);
                    WHEN OTHERS =>
                        affine_map_read_data <= "00000000";
                END CASE;
            WHEN OTHERS =>
                affine_map_read_data <= "00000000";
        END CASE;
    END PROCESS;
    
    --select affine graphics data from 2 possible banks
    PROCESS(affine_gfx_read_address,bank_3_read_data,bank_4_read_data)
        VARIABLE affine_gfx_read_address_vec      : STD_LOGIC_VECTOR(13 DOWNTO 0);
    BEGIN
        affine_gfx_read_address_vec := std_logic_vector(to_unsigned(affine_gfx_read_address, 14));
        CASE affine_gfx_read_address_vec(13) IS
            WHEN '0' =>
                affine_gfx_read_data <= bank_3_read_data;
            WHEN '1' =>
                affine_gfx_read_data <= bank_4_read_data;
            WHEN OTHERS =>
                affine_gfx_read_data <= "00000000";
        END CASE;
    END PROCESS;
    
    --Select bank 0 address from text, bitmap, or sprite engines
    PROCESS(bank0AddressSelectInt,bitmap_read_address,text_map_read_address)  
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE sprite_gfx_read_address_subaddr  : integer range 0 to 2047;
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 2047;
    BEGIN
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 2)));
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        sprite_gfx_read_address_subaddr := to_integer(unsigned(sprite_gfx_read_address_vec(12 downto 2)));
        
        CASE bank0AddressSelectInt IS
            WHEN 0 => --Text map
                bank_0_read_address <= text_map_read_address;
            WHEN 1 => --Bitmap
                bank_0_read_address <= bitmap_read_address_subaddr;
            WHEN 2 => --Sprite
                bank_0_read_address <= sprite_gfx_read_address_subaddr;
            --WHEN OTHERS =>
            --    bank_0_read_address <= text_map_read_address;
        END CASE;
    END PROCESS;
    
    --Select bank 1 address from tile A, affine, or bitmap engines
    PROCESS(bank1AddressSelectInt,tile_map_1_read_address,bitmap_read_address,affine_map_read_address)
    
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr    : integer range 0 to 2047;
        VARIABLE affine_map_read_address_vec      : STD_LOGIC_VECTOR(13 DOWNTO 0);
        VARIABLE affine_map_read_address_subaddr  : integer range 0 to 8192;
    BEGIN
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 2)));
        affine_map_read_address_vec := std_logic_vector(to_unsigned(affine_map_read_address, 14));
        affine_map_read_address_subaddr := to_integer(unsigned(affine_map_read_address_vec(12 downto 2)));
        
        CASE bank1AddressSelectInt IS
            WHEN 0 => --Tile A map
                bank_1_read_address <= tile_map_1_read_address;
            WHEN 1 => --Affine Map
                bank_1_read_address <= affine_map_read_address_subaddr;
            WHEN 2 => --Bitmap
                bank_1_read_address <= bitmap_read_address_subaddr;
            --WHEN OTHERS =>
            --    bank_1_read_address <= tile_map_1_read_address;
        END CASE;
    END PROCESS;
    
    --Select bank 2 address from tile B, affine, bitmap, or sprite engines
    PROCESS(bank2AddressSelectInt,tile_map_2_read_address,bitmap_read_address,affine_map_read_address,sprite_gfx_read_address)

        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 2047;
        VARIABLE affine_map_read_address_vec      : STD_LOGIC_VECTOR(13 DOWNTO 0);
        VARIABLE affine_map_read_address_subaddr  : integer range 0 to 8192;
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE sprite_gfx_read_address_subaddr  : integer range 0 to 2047;
    BEGIN
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 2)));
        affine_map_read_address_vec := std_logic_vector(to_unsigned(affine_map_read_address, 14));
        affine_map_read_address_subaddr := to_integer(unsigned(affine_map_read_address_vec(12 downto 2)));
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        sprite_gfx_read_address_subaddr := to_integer(unsigned(sprite_gfx_read_address_vec(12 downto 2)));
        
        CASE bank2AddressSelectInt IS
            WHEN 0 => --Tile B map
                bank_2_read_address <= tile_map_2_read_address;
            WHEN 1 => --Affine Map
                bank_2_read_address <= affine_map_read_address_subaddr;
            WHEN 2 => --Bitmap
                bank_2_read_address <= bitmap_read_address_subaddr;
            WHEN 3 => --Sprite
                bank_2_read_address <= sprite_gfx_read_address_subaddr;
            --WHEN OTHERS =>
            --    bank_2_read_address <= tile_map_2_read_address;
        END CASE;
    END PROCESS;
    
    --Select bank 3 address from tile A, affine, or bitmap engines
    PROCESS(bank3AddressSelectInt,tile_gfx_1_read_address,bitmap_read_address,affine_gfx_read_address)

        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 8192;
        VARIABLE affine_gfx_read_address_vec      : STD_LOGIC_VECTOR(13 DOWNTO 0);
        VARIABLE affine_gfx_read_address_subaddr  : integer range 0 to 8192;
    BEGIN
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 0)));
        affine_gfx_read_address_vec := std_logic_vector(to_unsigned(affine_gfx_read_address, 14));
        affine_gfx_read_address_subaddr := to_integer(unsigned(affine_gfx_read_address_vec(12 downto 0)));
        
        CASE bank3AddressSelectInt IS
            WHEN 0 => --Tile A graphics,
                bank_3_read_address <= tile_gfx_1_read_address;
            WHEN 1 => --Affine graphics
                bank_3_read_address <= affine_gfx_read_address_subaddr;
            WHEN 2 => --Bitmap
                bank_3_read_address <= bitmap_read_address_subaddr;
            --WHEN OTHERS =>
            --    bank_3_read_address <= tile_gfx_1_read_address;
        END CASE;
    END PROCESS;
    
    --Select bank 4 address from tile B, affine, bitmap, or sprite engines
    PROCESS(bank4AddressSelectInt,tile_gfx_2_read_address,bitmap_read_address,affine_gfx_read_address)
    
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 8192;
        VARIABLE affine_gfx_read_address_vec      : STD_LOGIC_VECTOR(13 DOWNTO 0);
        VARIABLE affine_gfx_read_address_subaddr  : integer range 0 to 8192;
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE sprite_gfx_read_address_subaddr  : integer range 0 to 8192;
    BEGIN
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 0)));
        affine_gfx_read_address_vec := std_logic_vector(to_unsigned(affine_gfx_read_address, 14));
        affine_gfx_read_address_subaddr := to_integer(unsigned(affine_gfx_read_address_vec(12 downto 0)));
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        sprite_gfx_read_address_subaddr := to_integer(unsigned(sprite_gfx_read_address_vec(12 downto 0)));
        
        CASE bank4AddressSelectInt IS
            WHEN 0 => --Tile B graphics,
                bank_4_read_address <= tile_gfx_2_read_address;
            WHEN 1 => --Affine graphics
                bank_4_read_address <= affine_gfx_read_address_subaddr;
            WHEN 2 => --Bitmap
                bank_4_read_address <= bitmap_read_address_subaddr;
            WHEN 3 => --Sprite
                bank_4_read_address <= sprite_gfx_read_address_subaddr;
            --WHEN OTHERS =>
            --    bank_4_read_address <= tile_gfx_2_read_address;
        END CASE;
    END PROCESS;
    
    --Select bank 5 address from sprite or bitmap engines
    PROCESS(bank5AddressSelectInt,sprite_gfx_read_address,bitmap_read_address)
    
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE sprite_gfx_read_address_subaddr  : integer range 0 to 8192;
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 8192;
    BEGIN
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        sprite_gfx_read_address_subaddr := to_integer(unsigned(sprite_gfx_read_address_vec(12 downto 0)));
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 0)));
        
        CASE bank5AddressSelectInt IS
            WHEN 0 => --Sprite graphics
                bank_5_read_address <= sprite_gfx_read_address_subaddr;
            WHEN 1 => --Bitmap
                bank_5_read_address <= bitmap_read_address_subaddr;
            --WHEN OTHERS =>
            --    bank_5_read_address <= sprite_gfx_read_address_subaddr;
        END CASE;
    END PROCESS;
    
    --Select bank 6 address from sprite, bitmap, or tile B engines
    PROCESS(bank6AddressSelectInt,sprite_gfx_read_address,bitmap_read_address,tile_map_2_read_address)
    
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE sprite_gfx_read_address_subaddr  : integer range 0 to 2047;
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 2047;
    BEGIN
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        sprite_gfx_read_address_subaddr := to_integer(unsigned(sprite_gfx_read_address_vec(12 downto 2)));
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 2)));
        
        CASE bank6AddressSelectInt IS
            WHEN 0 => --Sprite graphics
                bank_6_read_address <= sprite_gfx_read_address_subaddr;
            WHEN 1 => --Bitmap
                bank_6_read_address <= bitmap_read_address_subaddr;
            WHEN 2 => --Tile map 2
                bank_6_read_address <= tile_map_2_read_address;
            --WHEN OTHERS =>
            --    bank_6_read_address <= sprite_gfx_read_address_subaddr;
        END CASE;
    END PROCESS;
    
    --Select bank 7 address from sprite, bitmap, or tile B engines
    PROCESS(bank7AddressSelectInt,sprite_gfx_read_address,bitmap_read_address,tile_gfx_2_read_address)
    
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE sprite_gfx_read_address_subaddr  : integer range 0 to 8192;
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 8192;
    BEGIN
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        sprite_gfx_read_address_subaddr := to_integer(unsigned(sprite_gfx_read_address_vec(12 downto 0)));
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 0)));
        
        CASE bank7AddressSelectInt IS
            WHEN 0 => --Sprite graphics
                bank_7_read_address <= sprite_gfx_read_address_subaddr;
            WHEN 1 => --Bitmap
                bank_7_read_address <= bitmap_read_address_subaddr;
            WHEN 2 => --Tile Graphics 2
                bank_7_read_address <= tile_gfx_2_read_address;
            --WHEN OTHERS =>
            --    bank_7_read_address <= sprite_gfx_read_address_subaddr;
        END CASE;
    END PROCESS;
    
    --Select bank 8 address from sprite, bitmap, or tile A engines
    PROCESS(bank8AddressSelectInt,sprite_gfx_read_address,bitmap_read_address,tile_map_1_read_address)
    
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE sprite_gfx_read_address_subaddr  : integer range 0 to 2047;
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 2047;
    BEGIN
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        sprite_gfx_read_address_subaddr := to_integer(unsigned(sprite_gfx_read_address_vec(12 downto 2)));
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 2)));
        
        CASE bank8AddressSelectInt IS
            WHEN 0 => --Sprite graphics
                bank_8_read_address <= sprite_gfx_read_address_subaddr;
            WHEN 1 => --Bitmap
                bank_8_read_address <= bitmap_read_address_subaddr;
            WHEN 2 => --Tile map 1
                bank_8_read_address <= tile_map_1_read_address;
            --WHEN OTHERS =>
            --    bank_8_read_address <= sprite_gfx_read_address_subaddr;
        END CASE;
    END PROCESS;
    
    --Select bank 9 address from sprite, bitmap, or tile A engines
    PROCESS(bank9AddressSelectInt,sprite_gfx_read_address,bitmap_read_address,tile_gfx_1_read_address)
    
        VARIABLE sprite_gfx_read_address_vec      : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE sprite_gfx_read_address_subaddr  : integer range 0 to 8192;
        VARIABLE bitmap_read_address_vec          : STD_LOGIC_VECTOR(16 DOWNTO 0);
        VARIABLE bitmap_read_address_subaddr      : integer range 0 to 8192;
    BEGIN
        sprite_gfx_read_address_vec := std_logic_vector(to_unsigned(sprite_gfx_read_address, 16));
        sprite_gfx_read_address_subaddr := to_integer(unsigned(sprite_gfx_read_address_vec(12 downto 0)));
        bitmap_read_address_vec := std_logic_vector(to_unsigned(bitmap_read_address, 17));
        bitmap_read_address_subaddr := to_integer(unsigned(bitmap_read_address_vec(12 downto 0)));
        
        CASE bank9AddressSelectInt IS
            WHEN 0 => --Sprite graphics
                bank_9_read_address <= sprite_gfx_read_address_subaddr;
            WHEN 1 => --Bitmap
                bank_9_read_address <= bitmap_read_address_subaddr;
            WHEN 2 => --Tile Graphics 1
                bank_9_read_address <= tile_gfx_1_read_address;
            --WHEN OTHERS =>
            --    bank_9_read_address <= sprite_gfx_read_address_subaddr;
        END CASE;
    END PROCESS;
    
END behavior;