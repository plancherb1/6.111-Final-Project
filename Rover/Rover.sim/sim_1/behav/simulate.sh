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
ExecStep $xv_path/bin/xsim motor_signal_stream_tb_behav -key {Behavioral:sim_1:Functional:motor_signal_stream_tb} -tclbatch motor_signal_stream_tb.tcl -log simulate.log
