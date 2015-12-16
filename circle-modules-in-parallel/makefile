# Generic make file for working with quartus and software.
# Place this in project root.
#
# Will recompile if any verilog changes.
# Will reassemble with any changed to C file.
# Will always reprogram.
#
# Edit "project" to be the name of project from archive
# edit the paths to be the right paths.
#


project=challenge
software_path=software/
verilog_path=./

verilog=$(wildcard $(verilog_path)*.v) $(project).v $(wildcard verilog/*.v)
software=$(wildcard $(software_path)*.c)

binary=$(software_path)main.elf


all: $(project).sof $(binary)
	cd $(software_path) && $(MAKE) -i
	nios2-configure-sof $(project).sof
	nios2-download $(binary) --go

%.map.rpt:  $(verilog)
	cd $(software_path) && $(MAKE) -i
	quartus_map $(project)

%.fit.rpt: $(project).map.rpt
	quartus_fit $(project)

%.sof: $(project).fit.rpt
	quartus_asm $(project)

%.mif: $(software) 
	cd $(software_path) && $(MAKE) -i
	quartus_cdb $(project) -update_mif
	quartus_asm $(project)

clean:
	rm -rf $(project).map.rpt $(project).fit.rpt $(project).sof
	cd $(software_path) && $(MAKE) clean

cleansf:
	cd $(software_path) && $(MAKE) clean

# specifically ignore all verilog
$(binary):
	cd $(software_path) && $(MAKE) -i
software:
	cd $(software_path) && $(MAKE) -i

program:
	cd $(software_path) && $(MAKE) -i
	nios2-configure-sof $(project).sof

download:
	cd $(software_path) && $(MAKE) -i
	nios2-download $(binary) --go

reset:
	pkill -9 jtagd
	jtagd --user-start

