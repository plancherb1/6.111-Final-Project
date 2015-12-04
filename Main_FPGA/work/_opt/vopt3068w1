library verilog;
use verilog.vl_types.all;
entity polar_to_cartesian is
    generic(
        POS             : integer := 1;
        NEG             : integer := -1;
        ZERO            : integer := 0
    );
    port(
        r_theta         : in     vl_logic_vector(11 downto 0);
        x_value         : out    vl_logic_vector(8 downto 0);
        y_value         : out    vl_logic_vector(8 downto 0)
    );
end polar_to_cartesian;
