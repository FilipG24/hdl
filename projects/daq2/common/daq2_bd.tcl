
source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

set RX_NUM_OF_LANES 4           ; # L
set RX_NUM_OF_CONVERTERS 2      ; # M
set RX_SAMPLES_PER_FRAME 1      ; # S
set RX_SAMPLE_WIDTH 16          ; # N/NP

set RX_SAMPLES_PER_CHANNEL [expr $RX_NUM_OF_LANES * 32 / ($RX_NUM_OF_CONVERTERS * $RX_SAMPLE_WIDTH)]

set adc_fifo_name axi_ad9680_fifo
set adc_data_width [expr $RX_SAMPLE_WIDTH * $RX_NUM_OF_CONVERTERS * $RX_SAMPLES_PER_CHANNEL]
set adc_dma_data_width 64

# adc peripherals

ad_ip_instance axi_adxcvr axi_ad9680_xcvr
ad_ip_parameter axi_ad9680_xcvr CONFIG.NUM_OF_LANES $RX_NUM_OF_LANES
ad_ip_parameter axi_ad9680_xcvr CONFIG.QPLL_ENABLE 0
ad_ip_parameter axi_ad9680_xcvr CONFIG.TX_OR_RX_N 0

adi_axi_jesd204_rx_create axi_ad9680_jesd $RX_NUM_OF_LANES


adi_tpl_jesd204_rx_create axi_ad9680_tpl $RX_NUM_OF_LANES \
                                         $RX_NUM_OF_CONVERTERS \
                                         $RX_SAMPLES_PER_FRAME \
                                         $RX_SAMPLE_WIDTH \

ad_ip_instance util_cpack2 axi_ad9680_cpack [list \
  NUM_OF_CHANNELS $RX_NUM_OF_CONVERTERS \
  SAMPLES_PER_CHANNEL $RX_SAMPLES_PER_CHANNEL \
  SAMPLE_DATA_WIDTH $RX_SAMPLE_WIDTH \
]

ad_ip_instance axi_dmac axi_ad9680_dma
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad9680_dma CONFIG.ID 0
ad_ip_parameter axi_ad9680_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_ad9680_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_ad9680_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_LENGTH_WIDTH 24
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad9680_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_DATA_WIDTH_SRC $adc_dma_data_width
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_DATA_WIDTH_DEST 64

ad_adcfifo_create $adc_fifo_name $adc_data_width $adc_dma_data_width $adc_fifo_address_width

# shared transceiver core

ad_ip_instance util_adxcvr util_daq2_xcvr
ad_ip_parameter util_daq2_xcvr CONFIG.RX_NUM_OF_LANES $RX_NUM_OF_LANES
ad_ip_parameter util_daq2_xcvr CONFIG.RX_OUT_DIV 1
ad_ip_parameter util_daq2_xcvr CONFIG.RX_DFE_LPM_CFG 0x0104
ad_ip_parameter util_daq2_xcvr CONFIG.RX_CDR_CFG 0x0B000023FF10400020

ad_connect  $sys_cpu_resetn util_daq2_xcvr/up_rstn
ad_connect  $sys_cpu_clk util_daq2_xcvr/up_clk

# reference clocks & resets

create_bd_port -dir I rx_ref_clk_0

ad_xcvrpll  rx_ref_clk_0 util_daq2_xcvr/cpll_ref_clk_*
ad_xcvrpll  axi_ad9680_xcvr/up_pll_rst util_daq2_xcvr/up_cpll_rst_*

# connections (adc)

ad_xcvrcon  util_daq2_xcvr axi_ad9680_xcvr axi_ad9680_jesd
ad_connect  util_daq2_xcvr/rx_out_clk_0 axi_ad9680_tpl/link_clk
ad_connect  axi_ad9680_jesd/rx_sof axi_ad9680_tpl/link_sof
ad_connect  axi_ad9680_jesd/rx_data_tdata axi_ad9680_tpl/link_data
ad_connect  axi_ad9680_jesd/rx_data_tvalid axi_ad9680_tpl/link_valid

ad_connect  util_daq2_xcvr/rx_out_clk_0 axi_ad9680_cpack/clk
ad_connect  axi_ad9680_jesd_rstgen/peripheral_reset axi_ad9680_cpack/reset

ad_connect  axi_ad9680_tpl/adc_valid_0 axi_ad9680_cpack/fifo_wr_en
for {set i 0} {$i < $RX_NUM_OF_CONVERTERS} {incr i} {
  ad_connect  axi_ad9680_tpl/adc_enable_$i axi_ad9680_cpack/enable_$i
  ad_connect  axi_ad9680_tpl/adc_data_$i axi_ad9680_cpack/fifo_wr_data_$i
}
ad_connect  axi_ad9680_tpl/adc_dovf axi_ad9680_cpack/fifo_wr_overflow

ad_connect  util_daq2_xcvr/rx_out_clk_0 axi_ad9680_fifo/adc_clk
ad_connect  axi_ad9680_jesd_rstgen/peripheral_reset axi_ad9680_fifo/adc_rst

ad_connect  axi_ad9680_cpack/packed_fifo_wr_en axi_ad9680_fifo/adc_wr
ad_connect  axi_ad9680_cpack/packed_fifo_wr_data axi_ad9680_fifo/adc_wdata
ad_connect  axi_ad9680_cpack/packed_fifo_wr_overflow axi_ad9680_fifo/adc_wovf

ad_connect  $sys_cpu_clk axi_ad9680_fifo/dma_clk
ad_connect  $sys_cpu_clk axi_ad9680_dma/s_axis_aclk
ad_connect  $sys_cpu_resetn axi_ad9680_dma/m_dest_axi_aresetn
ad_connect  axi_ad9680_fifo/dma_wr axi_ad9680_dma/s_axis_valid
ad_connect  axi_ad9680_fifo/dma_wdata axi_ad9680_dma/s_axis_data
ad_connect  axi_ad9680_fifo/dma_wready axi_ad9680_dma/s_axis_ready
ad_connect  axi_ad9680_fifo/dma_xfer_req axi_ad9680_dma/s_axis_xfer_req

# interconnect (cpu)

ad_cpu_interconnect 0x44A50000 axi_ad9680_xcvr
ad_cpu_interconnect 0x44A10000 axi_ad9680_tpl
ad_cpu_interconnect 0x44AA0000 axi_ad9680_jesd
ad_cpu_interconnect 0x7c400000 axi_ad9680_dma

# gt uses hp3, and 100MHz clock for both DRP and AXI4

ad_mem_hp3_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP3
ad_mem_hp3_interconnect $sys_cpu_clk axi_ad9680_xcvr/m_axi

# interconnect (mem/dac)

ad_mem_hp2_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP2
ad_mem_hp2_interconnect $sys_cpu_clk axi_ad9680_dma/m_dest_axi

# interrupts

ad_cpu_interrupt ps-11 mb-14 axi_ad9680_jesd/irq
ad_cpu_interrupt ps-13 mb-12 axi_ad9680_dma/irq

ad_connect util_daq2_xcvr/qpll_ref_clk_0 GND
ad_connect util_daq2_xcvr/tx_clk_0 GND
ad_connect util_daq2_xcvr/tx_clk_1 GND
ad_connect util_daq2_xcvr/tx_clk_2 GND
ad_connect util_daq2_xcvr/tx_clk_3 GND
ad_connect util_daq2_xcvr/qpll_ref_clk_4 GND
ad_connect util_daq2_xcvr/tx_clk_4 GND
ad_connect util_daq2_xcvr/tx_clk_5 GND
ad_connect util_daq2_xcvr/tx_clk_6 GND
ad_connect util_daq2_xcvr/tx_clk_7 GND
