#!/usr/bin/env python

import os
os.environ['VUNIT_SIMULATOR'] = 'ghdl'

from vunit import VUnit

VU = VUnit.from_argv(compile_builtins=False)
VU.add_vhdl_builtins()

VU.enable_check_preprocessing()

lib = VU.add_library("lib")
lib.add_source_files(["*.vhd"])

# VU.set_compile_option('ghdl.a_flags',['--ieee=synopsys','-fexplicit'])
# VU.set_sim_option('ghdl.elab_flags',['--ieee=synopsys','-fexplicit'])
VU.set_sim_option('ghdl.sim_flags',[f'--vcd=sim_out.vcd'])

VU.main()
