library verilog;
use verilog.vl_types.all;
entity alpha_blend is
    generic(
        ALPHA_M         : integer := 2;
        ALPHA_N         : integer := 4;
        ALPHA_N_LOG_2   : integer := 2
    );
    port(
        pixel_1         : in     vl_logic_vector(23 downto 0);
        pixel_2         : in     vl_logic_vector(23 downto 0);
        overlap_pixel   : out    vl_logic_vector(23 downto 0)
    );
end alpha_blend;
