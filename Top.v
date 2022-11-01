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


//DAC
//----------------------------------------------------------------------------------------------------------------//
reg [1:0]     DAC_control = 2'b00; //01 - Saw; 11 - Tri ; 00 - Stop 
reg [7:0] 	   DAC_StartFreq = 0;
reg [7:0] 	   DAC_EndFreq = 0;
reg [7:0]     DAC_Step = 0;

DAC DAC_Inst(
  .ipClk  		( ipClk 		),
  .ipControl	( DAC_control	),
  .ipReset			( ~ipnReset		),
  .ipStartFreq	  	( DAC_StartFreq ),
  .ipEndFreq    (DAC_EndFreq),
  .ipStep       (DAC_Step),
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
enum{Stop=0, Command=1, StartFreq=2, EndFreq=3, Step=4} PacketState;

reg[7:0] command_Packet = 8'b11111111;
reg[7:0] start_Frequency = 0; 
reg[7:0] end_Frequency = 0;
reg[7:0] step = 0;
reg[7:0] test = 0;

assign opSendStatus = ~test;

always@(posedge ipClk) begin
	case (PacketState) 
		Stop : begin
			case (command_Packet) 
				8'b11111110 : begin
					DAC_StartFreq <= start_Frequency;
					DAC_EndFreq <= end_Frequency;
					DAC_Step <= step;
					DAC_control <= 2'b11;
				end
				8'b00000000 : begin
					DAC_StartFreq <= start_Frequency;
					DAC_EndFreq <= end_Frequency;
					DAC_Step <= step;
					DAC_control <= 2'b01;
				end
				8'b11111101 : begin
					DAC_control <= 2'b00;
				end
			endcase
			if (UART_RxData == 8'b11111111) begin
				PacketState <= Command;
				command_Packet <= 8'b11111111;
				start_Frequency <= 0;
				end_Frequency <= 0;
		    end
		end
		Command : begin
			if (UART_RxData != 8'b11111111) begin
				command_Packet <= UART_RxData;
				PacketState <= StartFreq;
			end
        end
		StartFreq : begin
			if (command_Packet == 8'b11111101) begin
				PacketState <= Stop;
			end else if (UART_RxData != command_Packet) begin
				start_Frequency <= UART_RxData;
				PacketState <= EndFreq;
			end
        end
		EndFreq : begin
			if (UART_RxData != start_Frequency) begin
				end_Frequency <= UART_RxData;
				PacketState <= Step;
			end
        end
		Step : begin
			if (UART_RxData != end_Frequency) begin
				step <= UART_RxData;
				PacketState <= Stop;
			end
		end
		default : PacketState <= Stop;
	endcase
end

endmodule
