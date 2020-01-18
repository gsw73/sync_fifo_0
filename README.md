# sync_fifo_0
Synchronous FIFO interfacing with flop-based, zero-delay read latency memory.
This is a simple synchronous FIFO design written in SystemVerilog.  The file design.sv is the top-level design file
that uses a back-tick include to incorporate other design files.  Likewise, the testbench.sv file includes other
related files required for sim.  (The back-tick include structure is dictated by the simulation environment used.)

The test bench sends random data into the FIFO and checks the data that is popped out.  One can tweak the test bench
to stress empty or full conditions and change random assertion of push/pop signals.

Note that FIFO is designed such that user may assert pop conitnuously.  Data should only be sampled by user when
both pop and vld signals are asserted.

You can run the simulation and look at waveforms at https://edaplayground.com.

View the wavedrom*.json timing diagram by copying the JSON file contents to https://wavedrom.com.

