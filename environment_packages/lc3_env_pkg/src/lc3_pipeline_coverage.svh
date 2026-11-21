//----------------------------------------------------------------------
// lc3_pipeline_coverage
//
// Behaviour coverage sampled from what the passive agents observe in the
// LC3 pipeline (the instruction-stream coverage is in the imem agent).
//
// Each <stage>_out transaction is the response to the <stage>_in
// transaction reported one clock earlier (the same pairing the stage
// scoreboards use), so in and out transactions are paired in order.
//
//   branch_cg      : branch outcome for every BR condition x psr value, JMP,
//                    and the instruction decoded before the branch
//   bypass_cg      : every bypass path x producer x consumer
//   bypass_both_cg : both sources bypassed from the same producer
//   psr_cg         : psr value written by each kind of writer
//   alu_result_cg  : ALU result sign per op, overflow, all-zero/all-one operands
//   mem_seq_cg     : mem_state sequence of each memory access type
//   pointer_cg     : LDI/STI pointer values
//   pipeline_cg    : enable patterns (stalls and bubbles)
//----------------------------------------------------------------------
`uvm_analysis_imp_decl( _pcov_decode_in )
`uvm_analysis_imp_decl( _pcov_control_in )
`uvm_analysis_imp_decl( _pcov_control_out )
`uvm_analysis_imp_decl( _pcov_execute_in )
`uvm_analysis_imp_decl( _pcov_execute_out )
`uvm_analysis_imp_decl( _pcov_writeback_in )
`uvm_analysis_imp_decl( _pcov_writeback_out )
`uvm_analysis_imp_decl( _pcov_memaccess_in )
`uvm_analysis_imp_decl( _pcov_memaccess_out )

class lc3_pipeline_coverage extends uvm_component;

  `uvm_component_utils( lc3_pipeline_coverage )

  localparam bit [3:0] OP_BR = 4'd0, OP_ADD = 4'd1, OP_LD = 4'd2, OP_ST = 4'd3, OP_AND = 4'd5,
                       OP_LDR = 4'd6, OP_STR = 4'd7, OP_NOT = 4'd9, OP_LDI = 4'd10, OP_STI = 4'd11,
                       OP_JMP = 4'd12, OP_LEA = 4'd14;

  typedef enum { CLS_ALU, CLS_LOAD, CLS_LEA, CLS_STORE, CLS_CTRL, CLS_NONE } cls_e;
  typedef enum { PATH_ALU_1, PATH_ALU_2, PATH_MEM_1, PATH_MEM_2 } path_e;
  typedef enum { C_ADD, C_AND, C_NOT, C_LDR, C_STR, C_JMP, C_ST, C_STI, C_OTHER } cons_e;
  typedef enum { A_ADD, A_AND, A_NOT } alu_op_e;
  typedef enum { SIGN_ZERO, SIGN_POS, SIGN_NEG } sign_e;
  typedef enum { OVF_NONE, OVF_POS, OVF_NEG } ovf_e;
  typedef enum { CORNER_NONE, AND_ZERO, AND_ONES, NOT_ZERO, NOT_ONES } corner_e;
  typedef enum { PTR_OTHER, PTR_ZERO, PTR_ONES, PTR_NEAR_CODE } ptr_e;

  uvm_analysis_imp_pcov_decode_in     #( decode_in_transaction,     lc3_pipeline_coverage ) decode_in_export;
  uvm_analysis_imp_pcov_control_in    #( control_in_transaction,    lc3_pipeline_coverage ) control_in_export;
  uvm_analysis_imp_pcov_control_out   #( control_out_transaction,   lc3_pipeline_coverage ) control_out_export;
  uvm_analysis_imp_pcov_execute_in    #( execute_in_transaction,    lc3_pipeline_coverage ) execute_in_export;
  uvm_analysis_imp_pcov_execute_out   #( execute_out_transaction,   lc3_pipeline_coverage ) execute_out_export;
  uvm_analysis_imp_pcov_writeback_in  #( writeback_in_transaction,  lc3_pipeline_coverage ) writeback_in_export;
  uvm_analysis_imp_pcov_writeback_out #( writeback_out_transaction, lc3_pipeline_coverage ) writeback_out_export;
  uvm_analysis_imp_pcov_memaccess_in  #( memaccess_in_transaction,  lc3_pipeline_coverage ) memaccess_in_export;
  uvm_analysis_imp_pcov_memaccess_out #( memaccess_out_transaction, lc3_pipeline_coverage ) memaccess_out_export;

  control_in_transaction   control_in_q   [$];
  execute_in_transaction   execute_in_q   [$];
  writeback_in_transaction writeback_in_q [$];
  bit [1:0]                mem_state_q    [$];   // mem_state of each memaccess_in not yet paired
  bit [1:0]                prev_mem_state = 2'd3;
  bit [15:0]               last_decoded;
  bit                      have_decoded;
  cls_e                    branch_prev_q  [$];   // instruction decoded before each BR/JMP
  int unsigned             samples;

  // ---------------------------------------------------------------- covergroups
  covergroup branch_cg with function sample( bit is_jmp, bit [2:0] nzp, bit [2:0] psr, bit taken, cls_e prev );
    option.per_instance = 1;
    NZP : coverpoint nzp iff ( !is_jmp ) {
      option.weight = 0;
      type_option.weight = 0;
      bins n   = { 3'b100 };
      bins z   = { 3'b010 };
      bins p   = { 3'b001 };
      bins nz  = { 3'b110 };
      bins np  = { 3'b101 };
      bins zp  = { 3'b011 };
      bins nzp = { 3'b111 };
    }
    PSR : coverpoint psr iff ( !is_jmp ) {
      option.weight = 0;
      type_option.weight = 0;
      bins n = { 3'b100 };
      bins z = { 3'b010 };
      bins p = { 3'b001 };
    }
    BR_NZP_X_PSR : cross NZP, PSR;
    OUTCOME : coverpoint { is_jmp, taken } {
      bins br_taken     = { 2'b01 };
      bins br_not_taken = { 2'b00 };
      bins jmp_taken    = { 2'b11 };
      ignore_bins jmp_not_taken = { 2'b10 };
    }
    PREV : coverpoint prev iff ( !is_jmp ) {
      option.weight = 0;
      type_option.weight = 0;
      bins alu   = { CLS_ALU };
      bins load  = { CLS_LOAD };
      bins lea   = { CLS_LEA };
      bins store = { CLS_STORE };
      bins ctrl  = { CLS_CTRL };
    }
    TAKEN : coverpoint taken iff ( !is_jmp ) {
      option.weight = 0;
      type_option.weight = 0;
      bins not_taken = { 1'b0 };
      bins taken     = { 1'b1 };
    }
    PREV_X_OUTCOME : cross PREV, TAKEN;
  endgroup

  covergroup bypass_cg with function sample( path_e path, cls_e prod, cons_e cons );
    option.per_instance = 1;
    PATH : coverpoint path {
      option.weight = 0;
      type_option.weight = 0;
      bins alu_1 = { PATH_ALU_1 };
      bins alu_2 = { PATH_ALU_2 };
      bins mem_1 = { PATH_MEM_1 };
      bins mem_2 = { PATH_MEM_2 };
    }
    PRODUCER : coverpoint prod {
      option.weight = 0;
      type_option.weight = 0;
      bins alu  = { CLS_ALU };
      bins lea  = { CLS_LEA };
      bins load = { CLS_LOAD };
    }
    CONSUMER : coverpoint cons {
      option.weight = 0;
      type_option.weight = 0;
      bins add_ = { C_ADD };
      bins and_ = { C_AND };
      bins not_ = { C_NOT };
      bins ldr  = { C_LDR };
      bins str  = { C_STR };
      bins jmp  = { C_JMP };
      bins st   = { C_ST };
      bins sti  = { C_STI };
    }
    PATH_X_PROD_X_CONS : cross PATH, PRODUCER, CONSUMER {
      ignore_bins alu_path_from_load = binsof( PATH ) intersect { PATH_ALU_1, PATH_ALU_2 } &&
                                       binsof( PRODUCER ) intersect { CLS_LOAD };
      ignore_bins mem_path_from_alu  = binsof( PATH ) intersect { PATH_MEM_1, PATH_MEM_2 } &&
                                       binsof( PRODUCER ) intersect { CLS_ALU, CLS_LEA };
      ignore_bins sr1_path_store     = binsof( PATH ) intersect { PATH_ALU_1, PATH_MEM_1 } &&
                                       binsof( CONSUMER ) intersect { C_ST, C_STI };
      ignore_bins sr2_path_no_sr2    = binsof( PATH ) intersect { PATH_ALU_2, PATH_MEM_2 } &&
                                       binsof( CONSUMER ) intersect { C_NOT, C_LDR, C_JMP };
    }
  endgroup

  covergroup bypass_both_cg with function sample( bit alu_both, bit mem_both );
    option.per_instance = 1;
    BOTH : coverpoint { alu_both, mem_both } {
      wildcard bins alu_both = { 2'b1? };
      wildcard bins mem_both = { 2'b?1 };
    }
  endgroup

  covergroup psr_cg with function sample( bit [1:0] w_control, bit [2:0] psr );
    option.per_instance = 1;
    WRITER : coverpoint w_control {
      option.weight = 0;
      type_option.weight = 0;
      bins alu  = { 2'd0 };
      bins load = { 2'd1 };
      bins lea  = { 2'd2 };
    }
    PSR : coverpoint psr {
      option.weight = 0;
      type_option.weight = 0;
      bins n = { 3'b100 };
      bins z = { 3'b010 };
      bins p = { 3'b001 };
    }
    WRITER_X_PSR : cross WRITER, PSR;
  endgroup

  covergroup alu_result_cg with function sample( alu_op_e op, sign_e sgn, ovf_e ovf, corner_e corner );
    option.per_instance = 1;
    OP : coverpoint op {
      option.weight = 0;
      type_option.weight = 0;
      bins add_ = { A_ADD };
      bins and_ = { A_AND };
      bins not_ = { A_NOT };
    }
    SIGN : coverpoint sgn {
      option.weight = 0;
      type_option.weight = 0;
      bins zero = { SIGN_ZERO };
      bins pos  = { SIGN_POS };
      bins neg  = { SIGN_NEG };
    }
    OP_X_SIGN : cross OP, SIGN;
    OVERFLOW : coverpoint ovf {
      bins pos_overflow = { OVF_POS };
      bins neg_overflow = { OVF_NEG };
    }
    CORNER : coverpoint corner {
      bins and_zero = { AND_ZERO };
      bins and_ones = { AND_ONES };
      bins not_zero = { NOT_ZERO };
      bins not_ones = { NOT_ONES };
    }
  endgroup

  covergroup mem_seq_cg with function sample( bit [1:0] mem_state );
    option.per_instance = 1;
    MEM_SEQ : coverpoint mem_state {
      bins ld_ldr = ( 3 => 0 => 3 );
      bins st_str = ( 3 => 2 => 3 );
      bins ldi    = ( 3 => 1 => 0 => 3 );
      bins sti    = ( 3 => 1 => 2 => 3 );
    }
  endgroup

  covergroup pointer_cg with function sample( bit is_sti, ptr_e ptr );
    option.per_instance = 1;
    OP : coverpoint is_sti {
      option.weight = 0;
      type_option.weight = 0;
      bins ldi = { 1'b0 };
      bins sti = { 1'b1 };
    }
    POINTER : coverpoint ptr {
      option.weight = 0;
      type_option.weight = 0;
      bins zero      = { PTR_ZERO };
      bins ones      = { PTR_ONES };
      bins near_code = { PTR_NEAR_CODE };
    }
    OP_X_POINTER : cross OP, POINTER;
  endgroup

  // enable_updatePC, enable_fetch, enable_decode, enable_execute, enable_writeback
  covergroup pipeline_cg with function sample( bit [4:0] en );
    option.per_instance = 1;
    ENABLES : coverpoint en {
      bins all_stalled         = { 5'b00000 };
      bins fetch_restart       = { 5'b10000 };
      bins fetch_decode        = { 5'b11000 };
      bins fill_to_decode      = { 5'b11100 };
      bins fill_to_execute     = { 5'b11110 };
      bins all_running         = { 5'b11111 };
      bins decode_only         = { 5'b00100 };
      bins execute_only        = { 5'b00010 };
      bins execute_writeback   = { 5'b00011 };
      bins decode_execute      = { 5'b00110 };
      bins decode_to_writeback = { 5'b00111 };
    }
  endgroup

  // ---------------------------------------------------------------- construction
  function new( string name = "", uvm_component parent = null );
    super.new( name, parent );
    branch_cg      = new;
    bypass_cg      = new;
    bypass_both_cg = new;
    psr_cg         = new;
    alu_result_cg  = new;
    mem_seq_cg     = new;
    pointer_cg     = new;
    pipeline_cg    = new;
  endfunction : new

  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    decode_in_export     = new( "decode_in_export",     this );
    control_in_export    = new( "control_in_export",    this );
    control_out_export   = new( "control_out_export",   this );
    execute_in_export    = new( "execute_in_export",    this );
    execute_out_export   = new( "execute_out_export",   this );
    writeback_in_export  = new( "writeback_in_export",  this );
    writeback_out_export = new( "writeback_out_export", this );
    memaccess_in_export  = new( "memaccess_in_export",  this );
    memaccess_out_export = new( "memaccess_out_export", this );
    branch_cg.set_inst_name     ( "branch_cg" );
    bypass_cg.set_inst_name     ( "bypass_cg" );
    bypass_both_cg.set_inst_name( "bypass_both_cg" );
    psr_cg.set_inst_name        ( "psr_cg" );
    alu_result_cg.set_inst_name ( "alu_result_cg" );
    mem_seq_cg.set_inst_name    ( "mem_seq_cg" );
    pointer_cg.set_inst_name    ( "pointer_cg" );
    pipeline_cg.set_inst_name   ( "pipeline_cg" );
  endfunction : build_phase

  // ---------------------------------------------------------------- helpers
  function cls_e instr_class( bit [15:0] i );
    case ( i[15:12] )
      OP_ADD, OP_AND, OP_NOT : return CLS_ALU;
      OP_LD, OP_LDR, OP_LDI  : return CLS_LOAD;
      OP_LEA                 : return CLS_LEA;
      OP_ST, OP_STR, OP_STI  : return CLS_STORE;
      OP_BR, OP_JMP          : return CLS_CTRL;
      default                : return CLS_NONE;
    endcase
  endfunction

  function cons_e consumer( bit [15:0] i );
    case ( i[15:12] )
      OP_ADD  : return C_ADD;
      OP_AND  : return C_AND;
      OP_NOT  : return C_NOT;
      OP_LDR  : return C_LDR;
      OP_STR  : return C_STR;
      OP_JMP  : return C_JMP;
      OP_ST   : return C_ST;
      OP_STI  : return C_STI;
      default : return C_OTHER;
    endcase
  endfunction

  function sign_e sign_of( bit [15:0] v );
    return ( v == 16'h0000 ) ? SIGN_ZERO : v[15] ? SIGN_NEG : SIGN_POS;
  endfunction

  // ---------------------------------------------------------------- decode: instruction before each branch
  virtual function void write_pcov_decode_in( decode_in_transaction t );
    if ( t.dout[15:12] inside { OP_BR, OP_JMP } ) branch_prev_q.push_back( have_decoded ? instr_class( last_decoded ) : CLS_NONE );
    last_decoded = t.dout;
    have_decoded = 1'b1;
  endfunction

  // ---------------------------------------------------------------- control: branches, bypasses, enables
  virtual function void write_pcov_control_in( control_in_transaction t );
    control_in_q.push_back( t );
  endfunction

  virtual function void write_pcov_control_out( control_out_transaction o );
    control_in_transaction i;
    cls_e prev;
    if ( control_in_q.size() == 0 ) return;
    i = control_in_q.pop_front();
    samples++;
    pipeline_cg.sample( { o.enable_updatePC, o.enable_fetch, o.enable_decode, o.enable_execute, o.enable_writeback } );
    // a branch or jump resolves in the one cycle its NZP reaches the controller
    if ( i.NZP != 3'b000 && i.IR_Exec[15:12] inside { OP_BR, OP_JMP } ) begin
      prev = ( branch_prev_q.size() != 0 ) ? branch_prev_q.pop_front() : CLS_NONE;
      branch_cg.sample( i.IR_Exec[15:12] == OP_JMP, i.NZP, i.psr, o.br_taken, prev );
    end
    if ( o.bypass_alu_1 ) bypass_cg.sample( PATH_ALU_1, instr_class( i.IR_Exec ), consumer( i.IR ) );
    if ( o.bypass_alu_2 ) bypass_cg.sample( PATH_ALU_2, instr_class( i.IR_Exec ), consumer( i.IR ) );
    if ( o.bypass_mem_1 ) bypass_cg.sample( PATH_MEM_1, instr_class( i.IR_Exec ), consumer( i.IR ) );
    if ( o.bypass_mem_2 ) bypass_cg.sample( PATH_MEM_2, instr_class( i.IR_Exec ), consumer( i.IR ) );
    if ( ( o.bypass_alu_1 && o.bypass_alu_2 ) || ( o.bypass_mem_1 && o.bypass_mem_2 ) )
      bypass_both_cg.sample( o.bypass_alu_1 && o.bypass_alu_2, o.bypass_mem_1 && o.bypass_mem_2 );
  endfunction

  // ---------------------------------------------------------------- execute: ALU results
  virtual function void write_pcov_execute_in( execute_in_transaction t );
    execute_in_q.push_back( t );
  endfunction

  virtual function void write_pcov_execute_out( execute_out_transaction o );
    execute_in_transaction i;
    alu_op_e   op;
    ovf_e      ovf;
    corner_e   corner;
    bit [15:0] a, b, r;
    bit        no_bypass_1, no_bypass_2;
    if ( execute_in_q.size() == 0 ) return;
    i = execute_in_q.pop_front();
    if ( !i.enable_execute || !( i.IR[15:12] inside { OP_ADD, OP_AND, OP_NOT } ) ) return;
    op = ( i.IR[15:12] == OP_ADD ) ? A_ADD : ( i.IR[15:12] == OP_AND ) ? A_AND : A_NOT;
    no_bypass_1 = !( i.bypass_alu_1 || i.bypass_mem_1 );
    no_bypass_2 = !( i.bypass_alu_2 || i.bypass_mem_2 );
    ovf = OVF_NONE;
    // overflow is judged from the register-file operands, so only when no
    // bypass replaces them
    if ( op == A_ADD && no_bypass_1 && ( i.IR[5] || no_bypass_2 ) ) begin
      a = i.VSR1;
      b = i.IR[5] ? { { 11{ i.IR[4] } }, i.IR[4:0] } : i.VSR2;
      r = a + b;
      if ( !a[15] && !b[15] &&  r[15] ) ovf = OVF_POS;
      if (  a[15] &&  b[15] && !r[15] ) ovf = OVF_NEG;
    end
    corner = CORNER_NONE;
    if ( op != A_ADD && no_bypass_1 ) begin
      if ( i.VSR1 == 16'h0000 ) corner = ( op == A_AND ) ? AND_ZERO : NOT_ZERO;
      if ( i.VSR1 == 16'hFFFF ) corner = ( op == A_AND ) ? AND_ONES : NOT_ONES;
    end
    alu_result_cg.sample( op, sign_of( o.aluout ), ovf, corner );
  endfunction

  // ---------------------------------------------------------------- writeback: psr per writer
  virtual function void write_pcov_writeback_in( writeback_in_transaction t );
    writeback_in_q.push_back( t );
  endfunction

  virtual function void write_pcov_writeback_out( writeback_out_transaction o );
    writeback_in_transaction i;
    if ( writeback_in_q.size() == 0 ) return;
    i = writeback_in_q.pop_front();
    if ( i.enable_writeback && i.W_Control <= 2 ) psr_cg.sample( i.W_Control, o.psr );
  endfunction

  // ---------------------------------------------------------------- memory access: state sequences, pointers
  virtual function void write_pcov_memaccess_in( memaccess_in_transaction t );
    mem_seq_cg.sample( t.mem_state );
    mem_state_q.push_back( t.mem_state );
  endfunction

  virtual function void write_pcov_memaccess_out( memaccess_out_transaction o );
    bit [1:0] state;
    ptr_e     ptr;
    if ( mem_state_q.size() == 0 ) return;
    state = mem_state_q.pop_front();
    // the cycle after the pointer read of LDI/STI addresses data memory
    // with the pointer
    if ( prev_mem_state == 2'd1 && state inside { 2'd0, 2'd2 } ) begin
      ptr = ( o.DMem_addr == 16'h0000 ) ? PTR_ZERO :
            ( o.DMem_addr == 16'hFFFF ) ? PTR_ONES :
            ( o.DMem_addr inside { [16'h3000:16'h30FF] } ) ? PTR_NEAR_CODE : PTR_OTHER;
      pointer_cg.sample( state == 2'd2, ptr );
    end
    prev_mem_state = state;
  endfunction

  // ---------------------------------------------------------------- report
  function real get_total_coverage();
    return ( branch_cg.get_inst_coverage() + bypass_cg.get_inst_coverage() + bypass_both_cg.get_inst_coverage()
           + psr_cg.get_inst_coverage() + alu_result_cg.get_inst_coverage() + mem_seq_cg.get_inst_coverage()
           + pointer_cg.get_inst_coverage() + pipeline_cg.get_inst_coverage() ) / 8.0;
  endfunction

  virtual function void report_phase( uvm_phase phase );
    `uvm_info( "PIPELINE_COVERAGE",
               $sformatf( "cycles:%0d  branch_cg:%0.2f%%  bypass_cg:%0.2f%%  bypass_both_cg:%0.2f%%  psr_cg:%0.2f%%  alu_result_cg:%0.2f%%  mem_seq_cg:%0.2f%%  pointer_cg:%0.2f%%  pipeline_cg:%0.2f%%",
                          samples, branch_cg.get_inst_coverage(), bypass_cg.get_inst_coverage(),
                          bypass_both_cg.get_inst_coverage(), psr_cg.get_inst_coverage(),
                          alu_result_cg.get_inst_coverage(), mem_seq_cg.get_inst_coverage(),
                          pointer_cg.get_inst_coverage(), pipeline_cg.get_inst_coverage() ), UVM_LOW )
    `uvm_info( "PIPELINE_COVERAGE", $sformatf( "BEHAVIOUR COVERAGE (this test): %0.2f%%", get_total_coverage() ), UVM_LOW )
  endfunction

endclass : lc3_pipeline_coverage
