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
//   imem_agent_ae receives transactions of type  imem_transaction
//
//   This analysis component has the following analysis_ports that can broadcast 
//   the listed transaction type.
//
//  lc3_sb_ap broadcasts transactions of type decode_in_transaction
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//

class lc3_predictor #(
  type CONFIG_T,
  type BASE_T = uvm_component
  )
 extends BASE_T;

  // Factory registration of this class
  `uvm_component_param_utils( lc3_predictor #(
                              CONFIG_T,
                              BASE_T
                              )
)


  // Instantiate a handle to the configuration of the environment in which this component resides
  CONFIG_T configuration;

  
  // Instantiate the analysis exports
  uvm_analysis_imp_imem_agent_ae #(imem_transaction, lc3_predictor #(
                              .CONFIG_T(CONFIG_T),
                              .BASE_T(BASE_T)
                              )
) imem_agent_ae;

  
  // Instantiate the analysis ports
  uvm_analysis_port #(decode_in_transaction) lc3_sb_ap;


  // Transaction variable for predicted values to be sent out lc3_sb_ap
  // Once a transaction is sent through an analysis_port, another transaction should
  // be constructed for the next predicted transaction. 
  typedef decode_in_transaction lc3_sb_ap_output_transaction_t;
  lc3_sb_ap_output_transaction_t lc3_sb_ap_output_transaction;
  // Code for sending output transaction out through lc3_sb_ap
  // lc3_sb_ap.write(lc3_sb_ap_output_transaction);

  // Define transaction handles for debug visibility 
  imem_transaction imem_agent_ae_debug;


  // pragma uvmf custom class_item_additional begin
  // pragma uvmf custom class_item_additional end

  // FUNCTION: new
  function new(string name, uvm_component parent);
     super.new(name,parent);
  // pragma uvmf custom new begin
  // pragma uvmf custom new end
  endfunction

  // FUNCTION: build_phase
  virtual function void build_phase (uvm_phase phase);

    imem_agent_ae = new("imem_agent_ae", this);
    lc3_sb_ap =new("lc3_sb_ap", this );
  // pragma uvmf custom build_phase begin
  // pragma uvmf custom build_phase end
  endfunction

  // FUNCTION: write_imem_agent_ae
  // Transactions received through imem_agent_ae initiate the execution of this function.
  // This function performs prediction of DUT output values based on DUT input, configuration and state
  virtual function void write_imem_agent_ae(imem_transaction t);
    // pragma uvmf custom imem_agent_ae_predictor begin
    // Every instruction the instruction memory delivers must reach the
    // decode stage, in order.
    imem_agent_ae_debug = t;
    lc3_sb_ap_output_transaction = lc3_sb_ap_output_transaction_t::type_id::create("lc3_sb_ap_output_transaction");
    lc3_sb_ap_output_transaction.dout = { t.opcode, t.operands };
    lc3_sb_ap.write(lc3_sb_ap_output_transaction);
    // pragma uvmf custom imem_agent_ae_predictor end
  endfunction


endclass 

// pragma uvmf custom external begin
// pragma uvmf custom external end

