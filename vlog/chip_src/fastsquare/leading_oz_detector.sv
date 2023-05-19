module leading_oz_detector (
    input logic [7:0] value,
    input logic sign,
    output logic [3:0] leading_one_position,
    output logic [9:0] masked_value     // Position of bit above first 1
);

    always_comb begin : decoder
        casez (value)
            8'b1111_1111: begin
                if (sign) begin
                    leading_one_position = 4'b1000;
                    masked_value = 9'b00000_0000;
                end else begin
                    leading_one_position = 4'b0111;
                    masked_value = 9'b10000_0000;
                end
            end
            8'b1???????: begin
                leading_one_position = 4'b0111;
                masked_value = 9'b10000_0000;
            end
            8'b0111_1111: begin
                if (sign) begin
                    leading_one_position = 4'b0111;
                    masked_value = 9'b10000_0000;                 
                end else begin
                    leading_one_position = 4'b0110;
                    masked_value = 9'b01000_0000;
                end

            end
            8'b01??_????: begin
                leading_one_position = 4'b0110;
                masked_value = 9'b01000_0000;
            end
            8'b0011_1111: begin
                if (sign) begin
                    leading_one_position = 4'b0110;
                    masked_value = 9'b01000_0000;                   
                end else begin
                    leading_one_position = 4'b0101;
                    masked_value =  9'b00100_0000;
                end

            end
            8'b001?_????: begin
                leading_one_position = 4'b0101;
                masked_value =  9'b00100_0000;
            end
            8'b0001_1111: begin
                if (sign) begin
                    leading_one_position = 4'b0101;
                    masked_value = 9'b00100_0000;                
                end else begin
                    leading_one_position = 4'b0100;
                    masked_value =  9'b00010_0000;
                end

            end           
            8'b0001_????: begin
                leading_one_position = 4'b0100;
                masked_value =  9'b00010_0000;
            end
            8'b0000_1111: begin
                if (sign) begin
                    leading_one_position = 4'b0100;
                    masked_value = 9'b00010_0000;      
                end else begin
                    leading_one_position = 4'b0011;
                    masked_value =  9'b00001_0000;
                end

            end   
            8'b00001???: begin
                leading_one_position = 4'b0011;
                masked_value =  9'b00001_0000;
            end
            8'b0000_0111: begin
                if (sign) begin
                    leading_one_position = 4'b0011;
                    masked_value = 9'b00001_0000;              
                end else begin
                    leading_one_position = 4'b0010;
                    masked_value = 9'b00000_1000;
                end

            end
            8'b000001??: begin
                leading_one_position = 4'b0010;
                masked_value = 9'b00000_1000;
            end
            8'b0000_0011: begin
                if (sign) begin
                    leading_one_position = 4'b0010;
                    masked_value = 9'b00000_1000;              
                end else begin
                    leading_one_position = 4'b0001;
                    masked_value = 9'b00000_0100;
                end
            end         
            8'b0000_001?: begin
                leading_one_position = 4'b0001;
                masked_value = 9'b00000_0100;
            end
            8'b0000_0001: begin
                if (sign) begin
                    leading_one_position = 4'b0001;
                    masked_value = 9'b00000_0100;        
                end else begin
                    leading_one_position = 4'b0000;
                    masked_value = 9'b00000_0010;
                end
            end
            8'b0000_0000: begin
                if (sign) begin
                    leading_one_position = 4'b0000;
                    masked_value = 9'b00000_0010;
                end else begin 
                    leading_one_position = 4'b0000;
                    masked_value = 9'b00000_0000;
                end
            end
            default: begin
                leading_one_position = 4'b0000;
                masked_value =  0;     // This is catch the -1 case          
            end
        endcase
    end

endmodule
