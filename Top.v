module 	Top(
	input  wire	     ipClk,
	input  wire		 ipnReset,
	//UART
	input  wire		 ipUART_Rx,
	output wire  	 opUART_Tx,
	output wire[7:0]opSendStatus,
	//DAC
	output wire   	 opDAC_SCK,
	output wire		 opDAC_CS,
	output wire 	 opDAC_SDI
);

reg tester=0;
assign opSendStatus[0] = ~tester;
//DAC
//----------------------------------------------------------------------------------------------------------------//
reg [1:0]     DAC_control = 2'b00; //01 - Start; 10 - Pause ; 00 - Stop 
reg [7:0] 	   DAC_Freq = 108;

DAC DAC_Inst(
  .ipClk  		( ipClk 		),
  .ipControl	( DAC_control	),
  .ipReset		( ~ipnReset		),
  .ipFreq		( DAC_Freq ),
  .opSCK		( opDAC_SCK		),
  .opCS    		( opDAC_CS 		),
  .opSDI		( opDAC_SDI 	)
);


//UART
//------------------------------------------------------------------------------------------------------------//

reg  [7:0]	UART_TxData;
reg       	UART_TxSend;
wire      	UART_TxBusy;	
wire [7:0]	UART_RxData;
wire      	UART_RxValid;

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


//Implementation
//-------------------------------------------------------------------------------------------------------//
always@(posedge ipClk) begin
	if (ipUART_Rx == 0)
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

endmodule
