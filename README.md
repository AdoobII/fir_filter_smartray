# fir_filter_smartray

get the OSS fpga-toolchain from [this repo](https://github.com/YosysHQ/oss-cad-suite-build)

## Installation on Ubuntu

1. Download the Linux archive for x86_64 from [the releases page](https://github.com/YosysHQ/oss-cad-suite-build/releases/latest).
2. Extract the archive to a location of your choice (e.g `tar xvzf oss-cad-suite-linux-x64-20211007.tgz -C /path/to/extraction/dir`)
3. After exctraction to go the directory and add the binaries to the PATH `export PATH="/path/to/extraction/dir/oss-cad-suite/bin:$PATH"`
4. Alternatively you can set a vitual environment by sourcing the shell file as `source /path/to/extraction/dir/environment`

## Typical VHDL design flow
# Make
1. `cd build`
2. `make elab`
3. `make run`
4. `make view`

# Simulation
1. Start by writing a module and its testbench.
2. Analyze the module using GHDL `ghdl -a --ieee=synopsys --std=08 /path/to/vhdl_file.vhdl /path/to/testbench.vhdl`.
3. Elaborate the testbench's Entity `ghdl -a --ieee=synopsys --std=08 tb_testbench` (NOTE: don't try to elaborate the testbench file, elaborate the testbench Entity, ghdl keeps track of objects using *.cf files in the main directory).
4. Run the simulation `ghdl -a --ieee=synopsys --std=08 tb_testbench --vcd=/PATH/TO/WAVEFORMS/FILES/testbench.vcd --stop-time=1us` (NOTE:Insert the path to the waveforms folder where you wish to save the vcd file, I usually name the vcd file after the entity I am simulating).
5. View the VCD file using GTKWave `gtkwave /PATH/TO/WAVEFORMS/FILES/testbench.vcd --rcvar 'fontname_signals Monospace 16' --rcvar 'fontname_waves Monospace 16'` (NOTE: I use monospace fonts at 16 because the default fonts and sizes are really small and annoying to read).

# Synthesis
For synthesis I use yosys, if you added the OSS binaries to your PATH or you are running the environment then follow the following steps:
1. Start yosys `yosys`
2. Elaborate the module using GHDL inside yosys `ghdl --ieee=synopsys --std=08 /path/to/vhdl/module/file.vhdl -e`
3. Run the `proc` command to convert all process to digital elements (multiplexers, flip-flops and latches.).
4. Run the `opt` command to perform optimizations and cleanups on the generated netlist.
5. Afterwards you can run the `stat` command to view stats about the synthezised design. (This process isn't recursive in nature and might produce incorrect results if you didn't elaborate the other modules in case you are trying to synthesize a hierarchical design).
6. Alternitively you can run `yosys -p "ghdl --ieee=synopsys --std=08 /path/to/vhdl/module/file.vhdl -e; proc; opt; stat"`.
