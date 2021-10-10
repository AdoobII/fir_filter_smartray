GHDL=ghdl
GHDLFLAGS= --std=08 --ieee=synopsys
GHDLRUNFLAGS= --stop-time=
GTKWave=gtkwave
GTKWaveFLAGS= --rcvar 'fontname_signals Monospace 16' --rcvar 'fontname_waves Monospace 16'

# Default target : elaborate
all : elab

# view waveform
view : force
	$(GTKWave) ../VHDL/waveforms/top.vcd $(GTKWaveFLAGS)

view_zero_crossing : force
	$(GTKWave) ../VHDL/waveforms/zero_crossing.vcd $(GTKWaveFLAGS)

view_input_controller : force
	$(GTKWave) ../VHDL/waveforms/input_controller.vcd $(GTKWaveFLAGS)

# Elaborate target
elab : init
	$(GHDL) -c $(GHDLFLAGS) -e top
	$(GHDL) -c $(GHDLFLAGS) -e tb_top
	$(GHDL) -c $(GHDLFLAGS) -e zero_crossing
	$(GHDL) -c $(GHDLFLAGS) -e tb_zero_crossing
	$(GHDL) -c $(GHDLFLAGS) -e input_controller
	$(GHDL) -c $(GHDLFLAGS) -e tb_input_controller

# Run target
run : force
	$(GHDL) -r $(GHDLFLAGS) tb_top --vcd=../VHDL/waveforms/top.vcd $(GHDLRUNFLAGS)5us
	$(GHDL) -r $(GHDLFLAGS) tb_zero_crossing --vcd=../VHDL/waveforms/zero_crossing.vcd $(GHDLRUNFLAGS)200ns
	$(GHDL) -r $(GHDLFLAGS) tb_input_controller --vcd=../VHDL/waveforms/input_controller.vcd $(GHDLRUNFLAGS)500ns

# Targets to analyze libraries
init: force
	# /usr/local/lib/ghdl/std/v08/../../src/std/v08/textio.vhdl
	# /usr/local/lib/ghdl/std/v08/../../src/std/v08/textio-body.vhdl
	# /usr/local/lib/ghdl/ieee/v08/../../src/ieee2008/std_logic_1164.vhdl
	# /usr/local/lib/ghdl/ieee/v08/../../src/ieee2008/std_logic_1164-body.vhdl
	# /usr/local/lib/ghdl/ieee/v08/../../src/ieee2008/numeric_std.vhdl
	# /usr/local/lib/ghdl/ieee/v08/../../src/ieee2008/numeric_std-body.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/packages/mytypes.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/modules/mul.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/modules/add.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/modules/reg.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/modules/cmp.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/modules/delay_array.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/modules/peak_detector.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/modules/shift_right_op.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/modules/sub.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/control_modules/bitpadder8x16.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/control_modules/wait_and_count.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/control_modules/zero_crossing_controller.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/system/input_controller.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/system/filter.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/system/zero_crossing.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/system/TOP.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/testbenches/tb_top.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/testbenches/tb_zero_crossing.vhdl
	$(GHDL) -a $(GHDLFLAGS) ../VHDL/testbenches/tb_input_controller.vhdl

clean:
	mv *.o build_artifacts/
force: