//----------------------------------------------------------------------
// Created with uvmf_gen version 2026.1
//----------------------------------------------------------------------
// pragma uvmf custom header begin
// pragma uvmf custom header end
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//                                          
// DESCRIPTION: This environment contains all agents, predictors and
// scoreboards required for the block level design.
//
//----------------------------------------------------------------------
//----------------------------------------------------------------------
//

class lc3_environment  extends uvmf_environment_base #(
    .CONFIG_T( lc3_env_configuration 
  ));
  `uvm_component_utils( lc3_environment )

  typedef fetch_environment fetch_env_t;
  fetch_env_t fetch_env;
   
  typedef decode_environment decode_env_t;
  decode_env_t decode_env;
   
  typedef execute_environment execute_env_t;
  execute_env_t execute_env;
   
  typedef writeback_environment writeback_env_t;
  writeback_env_t writeback_env;
   
  typedef memaccess_environment memaccess_env_t;
  memaccess_env_t memaccess_env;
   
  typedef control_environment control_env_t;
  control_env_t control_env;
   




  typedef imem_agent  imem_agent_t;
  imem_agent_t imem_agent;

  typedef dmem_agent  dmem_agent_t;
  dmem_agent_t dmem_agent;




  typedef lc3_predictor #(
                .CONFIG_T(CONFIG_T)
                )
 lc3_pred_t;
  lc3_pred_t lc3_pred;

  typedef lc3_stream_scoreboard #(.T(decode_in_transaction))  lc3_sb_t;
  lc3_sb_t lc3_sb;



  typedef uvmf_virtual_sequencer_base #(.CONFIG_T(lc3_env_configuration)) lc3_vsqr_t;
  lc3_vsqr_t vsqr;

  // pragma uvmf custom class_item_additional begin
  // DUT-behaviour coverage sampled from the passive stage agents
  lc3_pipeline_coverage pipeline_cov;
  // pragma uvmf custom class_item_additional end
 
// ****************************************************************************
// FUNCTION : new()
// This function is the standard SystemVerilog constructor.
//
  function new( string name = "", uvm_component parent = null );
    super.new( name, parent );
  endfunction

// ****************************************************************************
// FUNCTION: build_phase()
// This function builds all components within this environment.
//
  virtual function void build_phase(uvm_phase phase);
// pragma uvmf custom build_phase_pre_super begin
// pragma uvmf custom build_phase_pre_super end
    super.build_phase(phase);
    fetch_env = fetch_env_t::type_id::create("fetch_env",this);
    fetch_env.set_config(configuration.fetch_env_config);
    decode_env = decode_env_t::type_id::create("decode_env",this);
    decode_env.set_config(configuration.decode_env_config);
    execute_env = execute_env_t::type_id::create("execute_env",this);
    execute_env.set_config(configuration.execute_env_config);
    writeback_env = writeback_env_t::type_id::create("writeback_env",this);
    writeback_env.set_config(configuration.writeback_env_config);
    memaccess_env = memaccess_env_t::type_id::create("memaccess_env",this);
    memaccess_env.set_config(configuration.memaccess_env_config);
    control_env = control_env_t::type_id::create("control_env",this);
    control_env.set_config(configuration.control_env_config);
    imem_agent = imem_agent_t::type_id::create("imem_agent",this);
    imem_agent.set_config(configuration.imem_agent_config);
    dmem_agent = dmem_agent_t::type_id::create("dmem_agent",this);
    dmem_agent.set_config(configuration.dmem_agent_config);
    lc3_pred = lc3_pred_t::type_id::create("lc3_pred",this);
    lc3_pred.configuration = configuration;
    lc3_sb = lc3_sb_t::type_id::create("lc3_sb",this);

    vsqr = lc3_vsqr_t::type_id::create("vsqr", this);
    vsqr.set_config(configuration);
    configuration.set_vsqr(vsqr);

    // pragma uvmf custom build_phase begin
    pipeline_cov = lc3_pipeline_coverage::type_id::create( "pipeline_cov", this );
    // pragma uvmf custom build_phase end
  endfunction

// ****************************************************************************
// FUNCTION: connect_phase()
// This function makes all connections within this environment.  Connections
// typically inclue agent to predictor, predictor to scoreboard and scoreboard
// to agent.
//
  virtual function void connect_phase(uvm_phase phase);
// pragma uvmf custom connect_phase_pre_super begin
// pragma uvmf custom connect_phase_pre_super end
    super.connect_phase(phase);
    imem_agent.monitored_ap.connect(lc3_pred.imem_agent_ae);
    lc3_pred.lc3_sb_ap.connect(lc3_sb.expected_analysis_export);
    decode_env.decode_in_ap.connect(lc3_sb.actual_analysis_export);
    // pragma uvmf custom reg_model_connect_phase begin
    decode_env.decode_in_agent.monitored_ap.connect      ( pipeline_cov.decode_in_export );
    control_env.control_in_agent.monitored_ap.connect    ( pipeline_cov.control_in_export );
    control_env.control_out_agent.monitored_ap.connect   ( pipeline_cov.control_out_export );
    execute_env.execute_in_agent.monitored_ap.connect    ( pipeline_cov.execute_in_export );
    execute_env.execute_out_agent.monitored_ap.connect   ( pipeline_cov.execute_out_export );
    writeback_env.writeback_in_agent.monitored_ap.connect( pipeline_cov.writeback_in_export );
    writeback_env.writeback_out_agent.monitored_ap.connect( pipeline_cov.writeback_out_export );
    memaccess_env.memaccess_in_agent.monitored_ap.connect( pipeline_cov.memaccess_in_export );
    memaccess_env.memaccess_out_agent.monitored_ap.connect( pipeline_cov.memaccess_out_export );
    // pragma uvmf custom reg_model_connect_phase end
  endfunction

// ****************************************************************************
// FUNCTION: end_of_simulation_phase()
// This function is executed just prior to executing run_phase.  This function
// was added to the environment to sample environment configuration settings
// just before the simulation exits time 0.  The configuration structure is 
// randomized in the build phase before the environment structure is constructed.
// Configuration variables can be customized after randomization in the build_phase
// of the extended test.
// If a sequence modifies values in the configuration structure then the sequence is
// responsible for sampling the covergroup in the configuration if required.
//
  virtual function void start_of_simulation_phase(uvm_phase phase);
     configuration.lc3_configuration_cg.sample();
  endfunction

endclass

// pragma uvmf custom external begin
// pragma uvmf custom external end

