`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECE 3829
// Engineer: Leo Borsari
// 
// Create Date: 02/08/2025 06:08:27 PM
// Design Name: Lab 2 Top module
// Module Name: top_module
// Project Name: ECE 3829 Lab 2
// Target Devices: Basys 3 Board
// Tool Versions: 2021.1
// Description: Top module for lab 2.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module(
    input clk, //100MHz clock
    input btnC,
    input btnD,
    input [2:0] sw, //switch bus
    output wire [6:0] seg, //disp segments
    output wire [3:0] an, //disp anodes
    
    //vga cable outputs
    output wire [3:0] vgaRed, 
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire Hsync,
    output wire Vsync
);

    //values to disp to displays
    reg [3:0] A = 4'd9;
    reg [3:0] B = 4'd1;
    reg [3:0] C = 4'd4;
    reg [3:0] D = 4'd6;

    wire clk_25M; //clock wire
    wire lock; //lock for reset

    wire [10:0] hcount;
    wire [10:0] vcount;
    wire [11:0] color_out;
    wire blank;
    wire active;
    
    //debounced inputs
    wire btnC_dbncd; 
    wire btnD_dbncd;
    wire [2:0] sw_dbncd;

    assign active = !blank; //tell when screen is active
    
    //Piecewise VGA control from wire
    assign vgaRed[3:0] = color_out[11:8];
    assign vgaGreen[3:0] = color_out[7:4];
    assign vgaBlue[3:0] = color_out[3:0];

//Clock MMCM to 25MHz
    clk_wiz_25MHz clk_MMCM
    (
        //Clock in ports
        .clk_in1(clk), // input clk_in1
        .reset(btnC), // input reset
        // Clock out ports
        .clk_out25MHz(clk_25M), // output clk_out25MHz
        .locked(lock) // output locked
    );

    //Segment display controller
    seven_seg S1(
        .clk_25M(clk_25M),
        .reset_n(lock),
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .segment(seg),
        .anode(an)
    );

//VGA Select module
    vga_display_select V1(
        .clk_25M(clk_25M),
        .block_down(btnD_dbncd),
        .x(hcount),
        .y(vcount),
        .active(active),
        .sel(sw_dbncd[2:0]),
        .color(color_out)
    );

//VGA Controller
    vga_controller_640_60 V2(
        .rst(~lock),
        .pixel_clk(clk_25M),
        .HS(Hsync),
        .VS(Vsync),
        .hcount(hcount),
        .vcount(vcount),
        .blank(blank)
    );
    
//Debouncers    
    debouncer D0( //btnC
        .clk_25M(clk_25M),
        .reset_n(lock),
        .in(btnC),
        .out(btnC_dbncd)
    );
    
    debouncer D1( //btnD
        .clk_25M(clk_25M),
        .reset_n(lock),
        .in(btnD),
        .out(btnD_dbncd)
    );
    
    debouncer D2( //sw[2]
        .clk_25M(clk_25M),
        .reset_n(lock),
        .in(sw[2]),
        .out(sw_dbncd[2])
    );
    
    debouncer D3( //sw[1]
        .clk_25M(clk_25M),
        .reset_n(lock),
        .in(sw[1]),
        .out(sw_dbncd[1])
    );
    
    debouncer D4( //sw[0]
        .clk_25M(clk_25M),
        .reset_n(lock),
        .in(sw[0]),
        .out(sw_dbncd[0])
    );


endmodule
