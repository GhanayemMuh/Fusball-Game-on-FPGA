set_global_assignment -entity "clock_divider_31p5" -library "lib_clock_divider_31p5" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clock_divider_31p5" -library "lib_clock_divider_31p5" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "clock_divider_31p5" -library "lib_clock_divider_31p5" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clock_divider_31p5" -name SPD_FILE [file join $::quartus(sip_path) "clock_divider_31p5.spd"]

set_global_assignment -library "lib_clock_divider_31p5" -name MISC_FILE [file join $::quartus(sip_path) "clock_divider_31p5_sim/clock_divider_31p5.vo"]
