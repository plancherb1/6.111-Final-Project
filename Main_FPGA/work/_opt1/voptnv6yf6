library verilog;
use verilog.vl_types.all;
entity blob is
    generic(
        WIDTH           : integer := 64;
        HEIGHT          : integer := 64;
        COLOR           : integer := 16777215;
        BLANK_COLOR     : integer := 0
    );
    port(
        x               : in     vl_logic_vector(11 downto 0);
        x_value         : in     vl_logic_vector(11 downto 0);
        y               : in     vl_logic_vector(11 downto 0);
        y_value         : in     vl_logic_vector(11 downto 0);
        pixel           : out    vl_logic_vector(23 downto 0)
    );
end blob;
