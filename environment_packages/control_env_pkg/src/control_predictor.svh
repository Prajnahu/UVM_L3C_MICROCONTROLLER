//----------------------------------------------------------------------
// Created with uvmf_gen version 2026.1
//----------------------------------------------------------------------
// pragma uvmf custom header begin
// pragma uvmf custom header end
//----------------------------------------------------------------------
//
//----------------------------------------------------------------------
//
// DESCRIPTION: This analysis component contains analysis_exports for receiving
//   data and analysis_ports for sending data.
// 
//   This analysis component has the following analysis_exports that receive the 
//   listed transaction type.
//   
//   control_in_agent_ae receives transactions of type  control_in_transaction
//
//   This analysis component has the following analysis_ports that can broadcast 
//   the listed transaction type.
//
//  control_sb_ap broadcasts transactions of type control_out_transaction
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//

class control_predictor #(
  type CONFIG_T,
  type BASE_T = uvm_component
  )
 extends BASE_T;

  // Factory registration of this class
  `uvm_component_param_utils( control_predictor #(
                              CONFIG_T,
                              BASE_T
                              )
)


  // Instantiate a handle to the configuration of the environment in which this component resides
  CONFIG_T configuration;

  
  // Instantiate the analysis exports
  uvm_analysis_imp_control_in_agent_ae #(control_in_transaction, control_predictor #(
                              .CONFIG_T(CONFIG_T),
                              .BASE_T(BASE_T)
                              )
) control_in_agent_ae;

  
  // Instantiate the analysis ports
  uvm_analysis_port #(control_out_transaction) control_sb_ap;


  // Transaction variable for predicted values to be sent out control_sb_ap
  // Once a transaction is sent through an analysis_port, another transaction should
  // be constructed for the next predicted transaction. 
  typedef control_out_transaction control_sb_ap_output_transaction_t;
  control_sb_ap_output_transaction_t control_sb_ap_output_transaction;
  // Code for sending output transaction out through control_sb_ap
  // control_sb_ap.write(control_sb_ap_output_transaction);

  // Define transaction handles for debug visibility 
  control_in_transaction control_in_agent_ae_debug;


  // pragma uvmf custom class_item_additional begin
  int unsigned predicted_count;

  // controller_model() counts the reset cycle as its first call: on that
  // call has_been_reset is 0 and only enable_fetch is asserted. The control
  // monitors report from the first clock after reset, so that call is made
  // here, once, with the pipeline empty. Without it every prediction in the
  // pipeline fill lags the RTL by one clock.
  virtual function void prime_reset_cycle();
    bit       enable_updatePC, enable_fetch, enable_decode, enable_execute, enable_writeback;
    bit       bypass_alu_1, bypass_alu_2, bypass_mem_1, bypass_mem_2, br_taken;
    bit [1:0] mem_state;
    void'( lc3_prediction_pkg::controller_model( 1'b1, 1'b1, 16'h0000, 3'b000, 16'h0000, 16'h0000, 3'b000,
             enable_updatePC, enable_fetch, enable_decode, enable_execute, enable_writeback,
             bypass_alu_1, bypass_alu_2, bypass_mem_1, bypass_mem_2, mem_state, br_taken ) );
  endfunction
  // pragma uvmf custom class_item_additional end

  // FUNCTION: new
  function new(string name, uvm_component parent);
     super.new(name,parent);
  // pragma uvmf custom new begin
  // pragma uvmf custom new end
  endfunction

  // FUNCTION: build_phase
  virtual function void build_phase (uvm_phase phase);

    control_in_agent_ae = new("control_in_agent_ae", this);
    control_sb_ap =new("control_sb_ap", this );
  // pragma uvmf custom build_phase begin
  // pragma uvmf custom build_phase end
  endfunction

  // FUNCTION: write_control_in_agent_ae
  // Transactions received through control_in_agent_ae initiate the execution of this function.
  // This function performs prediction of DUT output values based on DUT input, configuration and state
  virtual function void write_control_in_agent_ae(control_in_transaction t);
    // pragma uvmf custom control_in_agent_ae_predictor begin
    control_in_agent_ae_debug = t;
    `uvm_info("PRED", {"Transaction Received through control_in_agent_ae: ",t.convert2string()}, UVM_FULL)
    control_sb_ap_output_transaction = control_sb_ap_output_transaction_t::type_id::create("control_sb_ap_output_transaction");
    predicted_count++;
    if ( predicted_count == 1 ) prime_reset_cycle();
    control_sb_ap_output_transaction.source = t.convert2string();
    if ( lc3_prediction_pkg::controller_model( t.complete_data, t.complete_instr, t.IR, t.psr, t.IR_Exec, t.IMem_dout, t.NZP, control_sb_ap_output_transaction.enable_updatePC, control_sb_ap_output_transaction.enable_fetch, control_sb_ap_output_transaction.enable_decode, control_sb_ap_output_transaction.enable_execute, control_sb_ap_output_transaction.enable_writeback, control_sb_ap_output_transaction.bypass_alu_1, control_sb_ap_output_transaction.bypass_alu_2, control_sb_ap_output_transaction.bypass_mem_1, control_sb_ap_output_transaction.bypass_mem_2, control_sb_ap_output_transaction.mem_state, control_sb_ap_output_transaction.br_taken ) != 0 ) begin
      `uvm_error( "PRED", $sformatf( "controller_model reported failure for %s", t.convert2string() ) )
    end
    control_sb_ap.write(control_sb_ap_output_transaction);
    // pragma uvmf custom control_in_agent_ae_predictor end
  endfunction


endclass 

// pragma uvmf custom external begin
// pragma uvmf custom external end

