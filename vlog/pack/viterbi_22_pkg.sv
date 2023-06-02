package viterbi_22_pkg;
	parameter integer number_of_state_units = 7;
	parameter integer number_of_branch_units = 31;
	parameter integer max_number_of_branch_connections = 7;
	parameter integer  bs_map [6:0][6:0]= '{{0, 0, 0, 30, 26, 18, 11}, {0, 0, 0, 29, 25, 17, 10}, {0, 0, 0, 22, 16, 7, 3}, {28, 24, 21, 15, 9, 6, 2}, {0, 0, 0, 27, 23, 14, 8}, {0, 0, 0, 20, 13, 5, 1}, {0, 0, 0, 19, 12, 4, 0}};
	parameter integer  number_of_branch_connections [6:0]= '{4, 4, 4, 7, 4, 4, 4};
	parameter integer  b_map [30:0]= '{6, 5, 3, 2, 6, 5, 3, 2, 4, 3, 1, 0, 6, 5, 4, 3, 2, 1, 0, 6, 5, 3, 2, 4, 3, 1, 0, 4, 3, 1, 0};
	parameter integer  sb_map [30:0]= '{6, 6, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0};
	parameter logic signed [1:0]  s_map [6:0][1:0] = '{{0, 1}, {-1, 1}, {1, 0}, {0, 0}, {-1, 0}, {1, -1}, {0, -1}};
	parameter logic signed [1:0]  bt_map [6:0][1:0]= '{{0, 1}, {-1, 1}, {1, 0}, {0, 0}, {-1, 0}, {1, -1}, {0, -1}};
	parameter [15:0] initial_energy_map [6:0] = '{9999, 9999, 9999, 0, 9999, 9999, 9999};

endpackage
