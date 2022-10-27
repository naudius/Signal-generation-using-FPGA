module 	Top(
	input  wire	     ipClk,
	input  wire		 ipnReset,
	//UART
	input  wire		 ipUART_Rx,
	output wire  	 opUART_Tx,
	output wire[7:0]opSendStatus,
	//DAC
	output wire 	 opLDAC,
	output wire   	 opDAC_SCK,
	output wire		 opDAC_CS,
	output wire 	 opDAC_SDI
);

//DAC
//----------------------------------------------------------------------------------------------------------------//

reg [9:0] Sine = 10'b0;
reg [1:0]     DAC_control = 2'b00; //01 - Start; 10 - Pause ; 00 - Stop 
wire 		   DAC_Sync;

DAC DAC_Inst(
  .ipClk  		( ipClk 		),
  .ipData		( Sine		),
  .ipControl	( DAC_control	),
  .ipReset		( ~ipnReset		),
  
  .opLDAC		( opLDAC ),
  .opSync		( DAC_Sync		),
  .opSCK		( opDAC_SCK		),
  .opCS    		( opDAC_CS 		),
  .opSDI		( opDAC_SDI 	)
);


//UART
//------------------------------------------------------------------------------------------------------------//
//UART Tx
reg  [7:0]	UART_TxData;
reg       	UART_TxSend;
wire      	UART_TxBusy;	
//UART Rx
wire [7:0]	UART_RxData;
wire      	UART_RxValid;
//debug LED's
assign 		opSendStatus[3] = ~opLDAC;
assign      opSendStatus[7] = ~DAC_Sync;
assign      opSendStatus[0] = ~opDAC_CS;

//UART instantiation
UART2 UART_Inst(
  .ipClk    ( ipClk   ),
  .ipReset  (~ipnReset),
  .ipTxData (  UART_TxData),
  .ipTxSend (  UART_TxSend),
  .opTxBusy (  UART_TxBusy),
  .opTx     (  opUART_Tx  ),
  .ipRx     (  ipUART_Rx	),
  .opRxData (  UART_RxData ),
  .opRxValid(  UART_RxValid)
);


//UART Implementation
//-------------------------------------------------------------------------------------------------------//
always@(posedge ipClk) begin
	case(UART_RxData) inside
		 "s": begin
			 DAC_control <= 2'b01;
		 end
		 "e": begin
			 DAC_control <= 2'b10;
		 end
		 default : DAC_control <= 2'b10;
		 
	endcase
end

always@(posedge DAC_Sync) begin
	Sine <= Sine+1;
end 
	
endmodule
