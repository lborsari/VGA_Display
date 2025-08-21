`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE 3829
// Engineer: Leo Borsari
// 
// Create Date: 02/10/2025 11:46:21 PM
// Design Name: Debouncer Module
// Module Name: debouncer
// Project Name: ECE 3829 Lab 2
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Debouncer for mechanical parts.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debouncer(
    input in, //input signal
    output reg out, //output signal
    input clk_25M, //input 25Mhz clock
    input reset_n //active low reset
);

    localparam
    //terminal count for 10msec period
    C_COUNT_MAX = 250_000 - 1; //25_000_000 * 0.01 for period

    reg [17:0] count = 18'b0;
    reg temp_in = 1'b0; //temporary in variable to check if input values changing during count

    always @ (posedge clk_25M or negedge reset_n) begin
        if(!reset_n) begin //set all equal to 0
            count <= 18'b0;
            out <= 1'b0;
            temp_in <= 1'b0;
        end
        else begin
            if(count == C_COUNT_MAX) begin //if timer reached, set out to in and reset count
                count <= 18'b0;
                out <= in;
                temp_in <= in;
            end
            else if(temp_in != in) begin //if input is changing, reset count
                count <= 18'b0;
                temp_in <= in;
            end
            else begin //otherwise increase the count and set temp_in to in
                count <= count + 18'b1;
                temp_in <= in;
            end
        end
    end


endmodule
