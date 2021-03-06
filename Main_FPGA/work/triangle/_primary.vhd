library verilog;
use verilog.vl_types.all;
entity triangle is
    generic(
        WIDTH           : integer := 64;
        HEIGHT          : integer := 64;
        COLOR           : integer := 16777215;
        BLANK_COLOR     : integer := 0;
        INDICATOR_COLOR : integer := 65280
    );
    port(
        center_x        : in     vl_logic_vector(11 downto 0);
        x_value         : in     vl_logic_vector(11 downto 0);
        center_y        : in     vl_logic_vector(11 downto 0);
        y_value         : in     vl_logic_vector(11 downto 0);
        orientation     : in     vl_logic_vector(4 downto 0);
        clock           : in     vl_logic;
        pixel           : out    vl_logic_vector(23 downto 0)
    );
end triangle;
