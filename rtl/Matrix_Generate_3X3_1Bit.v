module Matrix_Generate_3X3_1Bit 
#
(
    parameter [9:0] IMG_HDISP = 10'd640,
    parameter [9:0] IMG_VDISP = 10'd480
)
(
    input   wire                    sys_clk        ,
    input   wire                    sys_rst_n      ,

    input   wire                    per_frame_vsync     ,                   
    input   wire                    per_frame_href      , 
    input   wire                    per_frame_clken     ,
    input   wire                    per_img_Bit         , 

    output  wire                    matrix_frame_vsync  ,
    output  wire                    matrix_frame_href   ,
    output  wire                    matrix_frame_clken  ,
    output  reg                     matrix_p11          ,
    output  reg                     matrix_p12          ,
    output  reg                     matrix_p13          ,
    output  reg                     matrix_p21          ,
    output  reg                     matrix_p22          ,
    output  reg                     matrix_p23          ,
    output  reg                     matrix_p31          ,
    output  reg                     matrix_p32          ,
    output  reg                     matrix_p33          
);

//wire defination
wire  row1_data;
wire  row2_data;

//reg   defination
reg    row3_data;
reg	[1:0]	per_frame_vsync_r;
reg	[1:0]	per_frame_href_r;	
reg	[1:0]	per_frame_clken_r;

//********************************************************************************************//
//*********************************main code**************************************************//
//********************************************************************************************//

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if (sys_rst_n == 1'b0)
        row3_data <= 8'd0;
    else
        begin
            if (per_frame_clken)
                row3_data  <= per_img_Bit ;
            else
                row3_data  <= row3_data ; 
        end
end

Line_Shift_RAM_1Bit
/* #(
    .RAM_Length 	(IMG_HDISP)
) */
Line_Shift_RAM_1Bit_inst
(
    .clock          (sys_clk),
    .clken          (per_frame_clken),
    .aclr           (1'b0),
	
	.shiftout		()			,
    .shiftin        (row3_data) ,
    .taps0x         (row2_data) ,
    .taps1x         (row1_data)
);

//lag 2 clocks signal sync  
always@(posedge sys_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		begin
		per_frame_vsync_r <= 0;
		per_frame_href_r <= 0;
		per_frame_clken_r <= 0;
		end
	else
		begin
		per_frame_vsync_r 	<= 	{per_frame_vsync_r[0], 	per_frame_vsync};
		per_frame_href_r 	<= 	{per_frame_href_r[0], 	per_frame_href};
		per_frame_clken_r 	<= 	{per_frame_clken_r[0], 	per_frame_clken};
		end
end

//Give up the 1th and 2th row edge data caculate for simple process
//Give up the 1th and 2th point of 1 line for simple process
wire	read_frame_href		=	per_frame_href_r[0];	//RAM read href sync signal
wire	read_frame_clken	=	per_frame_clken_r[0];	//RAM read enable
assign	matrix_frame_vsync 	= 	per_frame_vsync_r[1];
assign	matrix_frame_href 	= 	per_frame_href_r[1];
assign	matrix_frame_clken 	= 	per_frame_clken_r[1];

always@(posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
    begin
        {matrix_p11, matrix_p12, matrix_p13} <= 3'b000;
        {matrix_p21, matrix_p22, matrix_p23} <= 3'b000;
        {matrix_p31, matrix_p32, matrix_p33} <= 3'b000;
    end 
    else if (read_frame_href == 1'b1) 
    begin
        if (read_frame_clken == 1'b1) 
        begin
            {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, row1_data };
            {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, row2_data };
            {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, row3_data };
        end
        else
        begin
            {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p11, matrix_p12, matrix_p13};
            {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p21, matrix_p22, matrix_p23};
            {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p31, matrix_p32, matrix_p33};
        end
    end
    else
    begin
        {matrix_p11, matrix_p12, matrix_p13} <= 3'b000;
        {matrix_p21, matrix_p22, matrix_p23} <= 3'b000;
        {matrix_p31, matrix_p32, matrix_p33} <= 3'b000;
    end

endmodule
