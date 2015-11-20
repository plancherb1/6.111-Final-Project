library verilog;
use verilog.vl_types.all;
entity grid is
    generic(
        BLANK_COLOR     : integer := 0;
        GRID_COLOR      : integer := 16711680;
        LEFT_BORDER     : integer := -128;
        RIGHT_BORDER    : integer := 128;
        TOP_BORDER      : integer := 640;
        BOTTOM_BORDER   : integer := 128;
        LINE_WIDTH      : integer := 1
    );
    port(
        x_value         : in     vl_logic_vector(11 downto 0);
        y_value         : in     vl_logic_vector(11 downto 0);
        pixel           : out    vl_logic_vector(23 downto 0)
    );
end grid;
