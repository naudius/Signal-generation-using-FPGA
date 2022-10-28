module 	UART2(
	//control signals 
	input  wire	     ipClk,
	input  wire		 ipReset,
	//transmitter
	input  wire[7:0]ipTxData,
	input  wire		 ipTxSend,
	output reg 	     opTxBusy,
	output reg       opTx,
	//receiver
	input  wire      ipRx,
	output reg [7:0]opRxData,
	output reg		 opRxValid
);


reg Reset;	                                //local reset
enum{TxIdle=0, Sending=1, TxDone=2} TxState; //transmitter states
always@(posedge ipClk) Reset <= ipReset;   //set local reset to input reset wire
	
reg [8:0] TxBdCount = 0; 				    //baud rate counter (434 clk cycles in 1 bd cycle
reg [7:0] TxData;                          //data to be transmitted
reg [2:0] TxCount;                         //counter for determining bit sent
//transmitter FSM
always@(posedge ipClk) begin
	//matchig baud and clk rate
	if(TxBdCount == 433)	TxBdCount <= 0;
 	else					TxBdCount <= TxBdCount +1;
	//check for reset
	if(Reset) begin
		opTxBusy <= 0;            //pull busy line low
		opTx     <= 1;            //pull transmit line high
		TxData   <= 8'bxxxx_xxxx; //data uninitialised
		TxCount  <= 3'bxxx;       //data index uninitialised
		TxState  <= TxIdle;		   //go to idle state
	//if not reset and at the 434 clk cycle (match bd rate)	
    end else if(TxBdCount == 0) begin
		case(TxState)		
			TxIdle: begin
				TxData  <= ipTxData;
				TxCount <= 0;
				if (ipTxSend == 1) begin
					opTxBusy  <= 1;
				    opTx    <= 0;
					TxState <= Sending;
				end
			end
			Sending: begin
				if (TxCount < 7) begin
					opTx    <= TxData[TxCount]; //sending LSB first at index 0;
					TxCount <= TxCount +1;
				end else begin
					opTx    <= TxData[TxCount];
					TxState <= TxDone;
				end
			end
			TxDone: begin
				opTx <= 1;
				if (~ipTxSend) begin
					TxData <= 8'bxxxx_xxxx;
					opTxBusy <= 0;
					TxState <= TxIdle;
				end
			end
			default: begin
				TxState <= TxIdle;
			end
		endcase
	end	
end	//end always block

//-----------------------------------------------------------------
enum{RxIdle=0, Receiving=1, RxDone=2} RxState; //transmitter states
//-----------------------------------------------------------------
reg [2:0]RxCount;
reg [8:0]RxBdCount = 0;
reg [7:0]RxData = 0;
//receiver FSM
always@(posedge ipClk) begin
	//matchig baud and clk rate
	if(RxBdCount == 433)	RxBdCount <= 0;
 	else					RxBdCount <= RxBdCount +1;
	
	if (Reset) begin
		opRxData <= 8'h00;
		opRxValid <= 0;
		RxData <= 8'h00;
		RxState <= RxIdle;
		
	end else if(RxBdCount == 0) begin
		case(RxState)		
			RxIdle: begin
				RxCount <= 0;
				opRxValid <= 0;
				RxData <= 8'hx;
				if (ipRx==0) begin
					RxState <= Receiving;
				end
			end
			Receiving: begin
				if (RxCount < 7) begin
					RxData[RxCount] <= ipRx;
					RxCount <= RxCount +1;
				end else begin
					RxData[RxCount] <= ipRx;
					RxState <= RxDone;
				end
			end
			RxDone: begin
				opRxData <= RxData;
				RxState <= RxIdle;
				opRxValid <= 1;
			end
			default: begin
				RxState <= RxIdle;
			end
		endcase
	end
end //end of always
endmodule
