library verilog;
use verilog.vl_types.all;
entity grid is
    generic(
        BLANK_COLOR     : integer := 0;
        GRID_COLOR      : integer := 16711680;
        VERTICAL_OFFSET : integer := 64;
        WIDTH           : integer := 4
    );
    port(
        x_value         : in     vl_logic_vector(11 downto 0);
        y_value         : in     vl_logic_vector(11 downto 0);
        pixel           : out    vl_logic_vector(23 downto 0)
    );
end grid;
