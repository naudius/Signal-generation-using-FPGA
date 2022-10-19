module 	Top(
	input  wire	     ipClk,
	input  wire		 ipnReset,
	input  wire     ipUART_Rx,
	output wire  	 opUART_Tx,
	output wire[7:0]opSendStatus 
);

reg  [7:0]UART_TxData;
reg       UART_TxSend;
wire      UART_TxBusy;	

wire [7:0]UART_RxData;
wire      UART_RxValid;


assign opSendStatus = ~UART_RxData;

UART2 UART_Inst(
  .ipClk    ( ipClk   ),
  .ipReset  (~ipnReset),

  .ipTxData (  UART_TxData),
  .ipTxSend (  UART_TxSend),
  .opTxBusy (  UART_TxBusy),
  .opTx     (  opUART_Tx  ),

  .ipRx     (ipUART_Rx     ),
  .opRxData (  UART_RxData ),
  .opRxValid(  UART_RxValid)
);

always@(posedge ipClk) begin
	if (~UART_TxSend && ~UART_TxBusy) begin
		case(UART_RxData) inside
			8'h0D    : UART_TxData <= 8'h0A; // Change enter to linefeed
			"0"      : UART_TxData <= 8'h0D; // Change 0 to carriage return
		    ["A":"Z"]: UART_TxData <= 8'h61;
			["a":"z"]: UART_TxData <= 8'h41;
			default  : UART_TxData <= UART_RxData;
		endcase
		UART_TxSend <= UART_RxValid;
	end else if (UART_TxSend && UART_TxBusy) begin
		UART_TxSend <= 0;
	end
end
endmodule