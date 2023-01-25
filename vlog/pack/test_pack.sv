package test_pack;

	localparam real full_rate = 16e9;

	// Improve array read capabilities
    class array_io #(type T = logic [7:0], int length = 16);
        static task fread_array(integer fid, output T arr [length-1:0]);
            $fscanf(fid, "{");
            for(int ii = 0; ii < length; ii += 1) begin
                $fscanf(fid, "%d", arr[ii]);
            end
            $fscanf(fid, "}\n");
        endtask

        static task fwrite_array(integer fid, input T arr [length-1:0]);
            $fwrite(fid, "{");
            for(int ii = 0; ii < length-1; ii += 1) begin
                $fwrite(fid, "%d ", arr[ii]);
            end
		    $fwrite(fid, "%d", arr[length-1]);
            $fwrite(fid, "}\n");
        endtask

		static task write_array(input T arr [length-1:0]);
            $write( "{");
            for(int ii = 0; ii < length-1; ii += 1) begin
                $write("%d ", arr[ii]);
            end
		    $write("%d", arr[length-1]);
            $write( "}\n");
        endtask
    endclass : array_io

endpackage
