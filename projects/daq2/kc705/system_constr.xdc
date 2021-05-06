
# daq2

set_property  -dict {PACKAGE_PIN  E8} [get_ports rx_ref_clk_p]                                      ; ## B20  FMC_HPC_GBTCLK1_M2C_P
set_property  -dict {PACKAGE_PIN  E7} [get_ports rx_ref_clk_n]                                      ; ## B21  FMC_HPC_GBTCLK1_M2C_N
set_property  -dict {PACKAGE_PIN  A8} [get_ports rx_data_p[0]]                                      ; ## A10  FMC_HPC_DP3_M2C_P
set_property  -dict {PACKAGE_PIN  A7} [get_ports rx_data_n[0]]                                      ; ## A11  FMC_HPC_DP3_M2C_N
set_property  -dict {PACKAGE_PIN  E4} [get_ports rx_data_p[1]]                                      ; ## C06  FMC_HPC_DP0_M2C_P
set_property  -dict {PACKAGE_PIN  E3} [get_ports rx_data_n[1]]                                      ; ## C07  FMC_HPC_DP0_M2C_N
set_property  -dict {PACKAGE_PIN  B6} [get_ports rx_data_p[2]]                                      ; ## A06  FMC_HPC_DP2_M2C_P
set_property  -dict {PACKAGE_PIN  B5} [get_ports rx_data_n[2]]                                      ; ## A07  FMC_HPC_DP2_M2C_N
set_property  -dict {PACKAGE_PIN  D6} [get_ports rx_data_p[3]]                                      ; ## A02  FMC_HPC_DP1_M2C_P
set_property  -dict {PACKAGE_PIN  D5} [get_ports rx_data_n[3]]                                      ; ## A03  FMC_HPC_DP1_M2C_N
set_property  -dict {PACKAGE_PIN  D26 IOSTANDARD LVDS_25} [get_ports rx_sync_p]                     ; ## D08  FMC_HPC_LA01_CC_P
set_property  -dict {PACKAGE_PIN  C26 IOSTANDARD LVDS_25} [get_ports rx_sync_n]                     ; ## D09  FMC_HPC_LA01_CC_N
set_property  -dict {PACKAGE_PIN  H26 IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_sysref_p]    ; ## G09  FMC_HPC_LA03_P
set_property  -dict {PACKAGE_PIN  H27 IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports rx_sysref_n]    ; ## G10  FMC_HPC_LA03_N

set_property  -dict {PACKAGE_PIN  G29 IOSTANDARD LVCMOS25} [get_ports spi_csn_clk]                  ; ## D11  FMC_HPC_LA05_P
set_property  -dict {PACKAGE_PIN  A30 IOSTANDARD LVCMOS25} [get_ports spi_csn_adc]                  ; ## D15  FMC_HPC_LA09_N
set_property  -dict {PACKAGE_PIN  F30 IOSTANDARD LVCMOS25} [get_ports spi_clk]                      ; ## D12  FMC_HPC_LA05_N
set_property  -dict {PACKAGE_PIN  B30 IOSTANDARD LVCMOS25} [get_ports spi_sdio]                     ; ## D14  FMC_HPC_LA09_P
set_property  -dict {PACKAGE_PIN  E30 IOSTANDARD LVCMOS25} [get_ports spi_dir]                      ; ## G13  FMC_HPC_LA08_N

set_property  -dict {PACKAGE_PIN  E29 IOSTANDARD LVCMOS25} [get_ports clkd_sync]                    ; ## G12  FMC_HPC_LA08_P
set_property  -dict {PACKAGE_PIN  H30 IOSTANDARD LVCMOS25} [get_ports adc_pd]                       ; ## C10  FMC_HPC_LA06_P

set_property  -dict {PACKAGE_PIN  A25 IOSTANDARD LVCMOS25} [get_ports clkd_status[0]]               ; ## D17  FMC_HPC_LA13_P
set_property  -dict {PACKAGE_PIN  A26 IOSTANDARD LVCMOS25} [get_ports clkd_status[1]]               ; ## D18  FMC_HPC_LA13_N
set_property  -dict {PACKAGE_PIN  G27 IOSTANDARD LVCMOS25} [get_ports adc_fda]                      ; ## H16  FMC_HPC_LA11_P
set_property  -dict {PACKAGE_PIN  F27 IOSTANDARD LVCMOS25} [get_ports adc_fdb]                      ; ## H17  FMC_HPC_LA11_N

set_property  -dict {PACKAGE_PIN  E28 IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports trig_p]         ; ## H13  FMC_HPC_LA07_P
set_property  -dict {PACKAGE_PIN  D28 IOSTANDARD LVDS_25 DIFF_TERM TRUE} [get_ports trig_n]         ; ## H14  FMC_HPC_LA07_N

# clocks

create_clock -name rx_ref_clk   -period  2.00 [get_ports rx_ref_clk_p]
create_clock -name rx_div_clk   -period  4.00 [get_pins i_system_wrapper/system_i/util_daq2_xcvr/inst/i_xch_0/i_gtxe2_channel/RXOUTCLK]

