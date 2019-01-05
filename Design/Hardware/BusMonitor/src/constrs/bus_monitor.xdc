set_property PACKAGE_PIN Y9 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
set_property PACKAGE_PIN R16 [get_ports RST]
set_property IOSTANDARD LVCMOS18 [get_ports RST]
set_property PACKAGE_PIN F22 [get_ports EN]
set_property IOSTANDARD LVCMOS18 [get_ports EN]
set_property PACKAGE_PIN W8 [get_ports UART_RX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_RX]

set_property OFFCHIP_TERM NONE [get_ports RECFG[1]]
set_property OFFCHIP_TERM NONE [get_ports RECFG[0]]
set_property PACKAGE_PIN T22 [get_ports {RECFG[0]}]
set_property PACKAGE_PIN T21 [get_ports {RECFG[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RECFG[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {RECFG[0]}]
