#!/bin/sh -f
xv_path="/mit/6.111/xilinx-vivado/Vivado/2014.4"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 793f22b1114747069679d60d19d92c68 -m64 --debug typical --relax -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot motor_signal_stream_tb_behav xil_defaultlib.motor_signal_stream_tb xil_defaultlib.glbl -log elaborate.log
