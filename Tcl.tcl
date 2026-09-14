set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

remove_all_instance_assignments -name *

set_location_assignment PIN_K10 -to SPK_KX
set_location_assignment PIN_E15 -to CLK50MHZ
set_location_assignment PIN_R9 -to HIGH
set_location_assignment PIN_T10 -to LED[0]
set_location_assignment PIN_R9 -to LED[1]
set_location_assignment PIN_T9 -to LED[2]
set_location_assignment PIN_K8 -to LED[3]
set_location_assignment PIN_D15 -to HIGH