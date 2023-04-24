module leading_one_detector (
    input logic [8:0] value,
    output logic [3:0] leading_one_position,
    output logic [8:0] masked_value
);
    
    always_comb begin : decoder
        case(value)
            9'b1???????: begin 
                leading_one_position = 4'b1001;
                masked_value = value & 9'b011111111;
            end
            9'b01??????: begin 
                leading_one_position = 4'b1000;
                masked_value = value & 9'b001111111;
            end
            9'b001?????: begin 
                leading_one_position = 4'b0111;
                masked_value = value & 9'b000111111;
            end
            9'b0001????: begin 
                leading_one_position = 4'b0110;
                masked_value = value & 9'b000011111;
            end
            9'b00001???: begin 
                leading_one_position = 4'b0101;
                masked_value = value & 9'b000001111;
            end
            9'b000001??: begin 
                leading_one_position = 4'b0100;
                masked_value = value & 9'b000000111;
            end
            9'b0000001?: begin 
                leading_one_position = 4'b0011;
                masked_value = value & 9'b000000011;
            end
            9'b00000001: begin 
                leading_one_position = 4'b0010;
                masked_value = value & 9'b000000001;
            end
            default: begin 
                leading_one_position = 4'b0000;
                masked_value = value;
            end
        endcase
    end

endmodule