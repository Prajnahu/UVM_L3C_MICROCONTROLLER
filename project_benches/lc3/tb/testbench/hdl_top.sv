//----------------------------------------------------------------------
// Created with uvmf_gen version 2026.1
//----------------------------------------------------------------------
// pragma uvmf custom header begin
// pragma uvmf custom header end
//----------------------------------------------------------------------
//----------------------------------------------------------------------                     
//               
// Description: This top level module instantiates all synthesizable
//    static content.  This and tb_top.sv are the two top level modules
//    of the simulation.  
//
//    This module instantiates the following:
//        DUT: The Design Under Test
//        Interfaces:  Signal bundles that contain signals connected to DUT
//        Driver BFM's: BFM's that actively drive interface signals
//        Monitor BFM's: BFM's that passively monitor interface signals
//
//----------------------------------------------------------------------

//----------------------------------------------------------------------
//

module hdl_top;

import lc3_parameters_pkg::*;
import uvmf_base_pkg_hdl::*;

  // pragma attribute hdl_top partition_module_xrtl                                            
// pragma uvmf custom clock_generator begin
  bit clk;
  // Instantiate a clk driver 
  // tbx clkgen
  initial begin
    clk = 0;
    #0ns;
    forever begin
      #5ns;
      clk = ~clk;
    end
  end
// pragma uvmf custom clock_generator end

// pragma uvmf custom reset_generator begin
  bit rst;
  // Instantiate a rst driver
  // tbx clkgen
  initial begin
    rst = 1; 
    #47ns;
    rst =  0; 
  end
// pragma uvmf custom reset_generator end

  // pragma uvmf custom module_item_additional begin
  // pragma uvmf custom module_item_additional end

  // Instantiate the signal bundle, monitor bfm and driver bfm for each interface.
  // The signal bundle, _if, contains signals to be connected to the DUT.
  // The monitor, monitor_bfm, observes the bus, _if, and captures transactions.
  // The driver, driver_bfm, drives transactions onto the bus, _if.
  fetch_in_if  fetch_env_fetch_in_agent_bus(
     // pragma uvmf custom fetch_env_fetch_in_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom fetch_env_fetch_in_agent_bus_connections end
     );
  fetch_out_if  fetch_env_fetch_out_agent_bus(
     // pragma uvmf custom fetch_env_fetch_out_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom fetch_env_fetch_out_agent_bus_connections end
     );
  decode_in_if  decode_env_decode_in_agent_bus(
     // pragma uvmf custom decode_env_decode_in_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom decode_env_decode_in_agent_bus_connections end
     );
  decode_out_if  decode_env_decode_out_agent_bus(
     // pragma uvmf custom decode_env_decode_out_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom decode_env_decode_out_agent_bus_connections end
     );
  execute_in_if  execute_env_execute_in_agent_bus(
     // pragma uvmf custom execute_env_execute_in_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom execute_env_execute_in_agent_bus_connections end
     );
  execute_out_if  execute_env_execute_out_agent_bus(
     // pragma uvmf custom execute_env_execute_out_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom execute_env_execute_out_agent_bus_connections end
     );
  writeback_in_if  writeback_env_writeback_in_agent_bus(
     // pragma uvmf custom writeback_env_writeback_in_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom writeback_env_writeback_in_agent_bus_connections end
     );
  writeback_out_if  writeback_env_writeback_out_agent_bus(
     // pragma uvmf custom writeback_env_writeback_out_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom writeback_env_writeback_out_agent_bus_connections end
     );
  memaccess_in_if  memaccess_env_memaccess_in_agent_bus(
     // pragma uvmf custom memaccess_env_memaccess_in_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom memaccess_env_memaccess_in_agent_bus_connections end
     );
  memaccess_out_if  memaccess_env_memaccess_out_agent_bus(
     // pragma uvmf custom memaccess_env_memaccess_out_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom memaccess_env_memaccess_out_agent_bus_connections end
     );
  control_in_if  control_env_control_in_agent_bus(
     // pragma uvmf custom control_env_control_in_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom control_env_control_in_agent_bus_connections end
     );
  control_out_if  control_env_control_out_agent_bus(
     // pragma uvmf custom control_env_control_out_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom control_env_control_out_agent_bus_connections end
     );
  imem_if  imem_agent_bus(
     // pragma uvmf custom imem_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom imem_agent_bus_connections end
     );
  dmem_if  dmem_agent_bus(
     // pragma uvmf custom dmem_agent_bus_connections begin
     .clock(clk), .reset(rst)
     // pragma uvmf custom dmem_agent_bus_connections end
     );
  fetch_in_monitor_bfm  fetch_env_fetch_in_agent_mon_bfm(fetch_env_fetch_in_agent_bus);
  fetch_out_monitor_bfm  fetch_env_fetch_out_agent_mon_bfm(fetch_env_fetch_out_agent_bus);
  decode_in_monitor_bfm  decode_env_decode_in_agent_mon_bfm(decode_env_decode_in_agent_bus);
  decode_out_monitor_bfm  decode_env_decode_out_agent_mon_bfm(decode_env_decode_out_agent_bus);
  execute_in_monitor_bfm  execute_env_execute_in_agent_mon_bfm(execute_env_execute_in_agent_bus);
  execute_out_monitor_bfm  execute_env_execute_out_agent_mon_bfm(execute_env_execute_out_agent_bus);
  writeback_in_monitor_bfm  writeback_env_writeback_in_agent_mon_bfm(writeback_env_writeback_in_agent_bus);
  writeback_out_monitor_bfm  writeback_env_writeback_out_agent_mon_bfm(writeback_env_writeback_out_agent_bus);
  memaccess_in_monitor_bfm  memaccess_env_memaccess_in_agent_mon_bfm(memaccess_env_memaccess_in_agent_bus);
  memaccess_out_monitor_bfm  memaccess_env_memaccess_out_agent_mon_bfm(memaccess_env_memaccess_out_agent_bus);
  control_in_monitor_bfm  control_env_control_in_agent_mon_bfm(control_env_control_in_agent_bus);
  control_out_monitor_bfm  control_env_control_out_agent_mon_bfm(control_env_control_out_agent_bus);
  imem_monitor_bfm  imem_agent_mon_bfm(imem_agent_bus);
  dmem_monitor_bfm  dmem_agent_mon_bfm(dmem_agent_bus);
  imem_driver_bfm  imem_agent_drv_bfm(imem_agent_bus);
  dmem_driver_bfm  dmem_agent_drv_bfm(dmem_agent_bus);

  // pragma uvmf custom dut_instantiation begin
  LC3 dut (
    .clock          ( clk                           ),
    .reset          ( rst                           ),
    .pc             ( imem_agent_bus.pc             ),
    .instrmem_rd    ( imem_agent_bus.instrmem_rd    ),
    .Instr_dout     ( imem_agent_bus.Instr_dout     ),
    .complete_instr ( imem_agent_bus.complete_instr ),
    .Data_addr      ( dmem_agent_bus.Data_addr      ),
    .Data_din       ( dmem_agent_bus.Data_din       ),
    .Data_dout      ( dmem_agent_bus.Data_dout      ),
    .Data_rd        ( dmem_agent_bus.Data_rd        ),
    .complete_data  ( dmem_agent_bus.complete_data  )
  );

  // The stage interfaces are passive: they observe the LC3's internal
  // pipeline signals through hierarchical references.
  assign fetch_env_fetch_in_agent_bus.enable_updatePC = dut.enable_updatePC;
  assign fetch_env_fetch_in_agent_bus.enable_fetch = dut.enable_fetch;
  assign fetch_env_fetch_in_agent_bus.br_taken = dut.br_taken;
  assign fetch_env_fetch_in_agent_bus.taddr = dut.pcout;
  assign fetch_env_fetch_out_agent_bus.pc = dut.pc;
  assign fetch_env_fetch_out_agent_bus.npc = dut.npc_out_fetch;
  assign fetch_env_fetch_out_agent_bus.instrmem_rd = dut.instrmem_rd;
  assign decode_env_decode_in_agent_bus.dout = dut.Instr_dout;
  assign decode_env_decode_in_agent_bus.npc_in = dut.npc_out_fetch;
  assign decode_env_decode_out_agent_bus.IR = dut.IR;
  assign decode_env_decode_out_agent_bus.npc_out = dut.npc_out_dec;
  assign decode_env_decode_out_agent_bus.E_Control = dut.E_Control;
  assign decode_env_decode_out_agent_bus.W_Control = dut.W_Control;
  assign decode_env_decode_out_agent_bus.Mem_Control = dut.Mem_Control;
  assign decode_env_decode_in_agent_bus.enable_decode = dut.enable_decode;
  assign decode_env_decode_out_agent_bus.enable_decode = dut.enable_decode;
  assign execute_env_execute_in_agent_bus.E_Control = dut.E_Control;
  assign execute_env_execute_in_agent_bus.bypass_alu_1 = dut.bypass_alu_1;
  assign execute_env_execute_in_agent_bus.bypass_alu_2 = dut.bypass_alu_2;
  assign execute_env_execute_in_agent_bus.bypass_mem_1 = dut.bypass_mem_1;
  assign execute_env_execute_in_agent_bus.bypass_mem_2 = dut.bypass_mem_2;
  assign execute_env_execute_in_agent_bus.enable_execute = dut.enable_execute;
  assign execute_env_execute_in_agent_bus.IR = dut.IR;
  assign execute_env_execute_in_agent_bus.npc_in = dut.npc_out_dec;
  assign execute_env_execute_in_agent_bus.Mem_Control_in = dut.Mem_Control;
  assign execute_env_execute_in_agent_bus.W_Control_in = dut.W_Control;
  assign execute_env_execute_in_agent_bus.Mem_Bypass_Val = dut.memout;
  assign execute_env_execute_in_agent_bus.VSR1 = dut.VSR1;
  assign execute_env_execute_in_agent_bus.VSR2 = dut.VSR2;
  assign execute_env_execute_out_agent_bus.aluout = dut.aluout;
  assign execute_env_execute_out_agent_bus.W_Control_out = dut.W_Control_out;
  assign execute_env_execute_out_agent_bus.Mem_Control_out = dut.Mem_Control_out;
  assign execute_env_execute_out_agent_bus.M_Data = dut.M_Data;
  assign execute_env_execute_out_agent_bus.dr = dut.dr;
  assign execute_env_execute_out_agent_bus.sr1 = dut.sr1;
  assign execute_env_execute_out_agent_bus.sr2 = dut.sr2;
  assign execute_env_execute_out_agent_bus.IR_Exec = dut.IR_Exec;
  assign execute_env_execute_out_agent_bus.NZP = dut.NZP;
  assign execute_env_execute_out_agent_bus.pcout = dut.pcout;
  assign writeback_env_writeback_in_agent_bus.aluout = dut.aluout;
  assign writeback_env_writeback_in_agent_bus.W_Control = dut.W_Control_out;
  assign writeback_env_writeback_in_agent_bus.npc = dut.npc_out_dec;
  assign writeback_env_writeback_in_agent_bus.pcout = dut.pcout;
  assign writeback_env_writeback_in_agent_bus.memout = dut.memout;
  assign writeback_env_writeback_in_agent_bus.enable_writeback = dut.enable_writeback;
  assign writeback_env_writeback_in_agent_bus.sr1 = dut.sr1;
  assign writeback_env_writeback_in_agent_bus.sr2 = dut.sr2;
  assign writeback_env_writeback_in_agent_bus.dr = dut.dr;
  assign writeback_env_writeback_out_agent_bus.vsr1 = dut.VSR1;
  assign writeback_env_writeback_out_agent_bus.vsr2 = dut.VSR2;
  assign writeback_env_writeback_out_agent_bus.psr = dut.psr;
  assign memaccess_env_memaccess_in_agent_bus.M_Data = dut.M_Data;
  assign memaccess_env_memaccess_in_agent_bus.M_Addr = dut.pcout;
  assign memaccess_env_memaccess_in_agent_bus.M_Control = dut.Mem_Control_out;
  assign memaccess_env_memaccess_in_agent_bus.mem_state = dut.mem_state;
  assign memaccess_env_memaccess_in_agent_bus.DMem_dout = dut.Data_dout;
  assign memaccess_env_memaccess_out_agent_bus.DMem_addr = dut.Data_addr;
  assign memaccess_env_memaccess_out_agent_bus.DMem_din = dut.Data_din;
  assign memaccess_env_memaccess_out_agent_bus.memout = dut.memout;
  assign memaccess_env_memaccess_out_agent_bus.DMem_rd = dut.Data_rd;
  assign control_env_control_in_agent_bus.complete_data = dut.complete_data;
  assign control_env_control_in_agent_bus.complete_instr = dut.complete_instr;
  assign control_env_control_in_agent_bus.IR = dut.IR;
  assign control_env_control_in_agent_bus.psr = dut.psr;
  assign control_env_control_in_agent_bus.IR_Exec = dut.IR_Exec;
  assign control_env_control_in_agent_bus.IMem_dout = dut.Instr_dout;
  assign control_env_control_in_agent_bus.NZP = dut.NZP;
  assign control_env_control_out_agent_bus.enable_updatePC = dut.enable_updatePC;
  assign control_env_control_out_agent_bus.enable_fetch = dut.enable_fetch;
  assign control_env_control_out_agent_bus.enable_decode = dut.enable_decode;
  assign control_env_control_out_agent_bus.enable_execute = dut.enable_execute;
  assign control_env_control_out_agent_bus.enable_writeback = dut.enable_writeback;
  assign control_env_control_out_agent_bus.bypass_alu_1 = dut.bypass_alu_1;
  assign control_env_control_out_agent_bus.bypass_alu_2 = dut.bypass_alu_2;
  assign control_env_control_out_agent_bus.bypass_mem_1 = dut.bypass_mem_1;
  assign control_env_control_out_agent_bus.bypass_mem_2 = dut.bypass_mem_2;
  assign control_env_control_out_agent_bus.mem_state = dut.mem_state;
  assign control_env_control_out_agent_bus.br_taken = dut.br_taken;
  // pragma uvmf custom dut_instantiation end

  initial begin      // tbx vif_binding_block 
    import uvm_pkg::uvm_config_db;
    // The monitor_bfm and driver_bfm for each interface is placed into the uvm_config_db.
    // They are placed into the uvm_config_db using the string names defined in the parameters package.
    // The string names are passed to the agent configurations by test_top through the top level configuration.
    // They are retrieved by the agents configuration class for use by the agent.
    uvm_config_db #( virtual fetch_in_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , fetch_env_fetch_in_agent_BFM , fetch_env_fetch_in_agent_mon_bfm ); 
    uvm_config_db #( virtual fetch_out_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , fetch_env_fetch_out_agent_BFM , fetch_env_fetch_out_agent_mon_bfm ); 
    uvm_config_db #( virtual decode_in_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , decode_env_decode_in_agent_BFM , decode_env_decode_in_agent_mon_bfm ); 
    uvm_config_db #( virtual decode_out_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , decode_env_decode_out_agent_BFM , decode_env_decode_out_agent_mon_bfm ); 
    uvm_config_db #( virtual execute_in_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , execute_env_execute_in_agent_BFM , execute_env_execute_in_agent_mon_bfm ); 
    uvm_config_db #( virtual execute_out_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , execute_env_execute_out_agent_BFM , execute_env_execute_out_agent_mon_bfm ); 
    uvm_config_db #( virtual writeback_in_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , writeback_env_writeback_in_agent_BFM , writeback_env_writeback_in_agent_mon_bfm ); 
    uvm_config_db #( virtual writeback_out_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , writeback_env_writeback_out_agent_BFM , writeback_env_writeback_out_agent_mon_bfm ); 
    uvm_config_db #( virtual memaccess_in_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , memaccess_env_memaccess_in_agent_BFM , memaccess_env_memaccess_in_agent_mon_bfm ); 
    uvm_config_db #( virtual memaccess_out_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , memaccess_env_memaccess_out_agent_BFM , memaccess_env_memaccess_out_agent_mon_bfm ); 
    uvm_config_db #( virtual control_in_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , control_env_control_in_agent_BFM , control_env_control_in_agent_mon_bfm ); 
    uvm_config_db #( virtual control_out_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , control_env_control_out_agent_BFM , control_env_control_out_agent_mon_bfm ); 
    uvm_config_db #( virtual imem_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , imem_agent_BFM , imem_agent_mon_bfm ); 
    uvm_config_db #( virtual dmem_monitor_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , dmem_agent_BFM , dmem_agent_mon_bfm ); 
    uvm_config_db #( virtual imem_driver_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , imem_agent_BFM , imem_agent_drv_bfm  );
    uvm_config_db #( virtual dmem_driver_bfm  )::set( null , UVMF_VIRTUAL_INTERFACES , dmem_agent_BFM , dmem_agent_drv_bfm  );
  end

endmodule

// pragma uvmf custom external begin
// pragma uvmf custom external end

