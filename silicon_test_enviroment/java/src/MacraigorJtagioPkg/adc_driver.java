/**
 * File: JtagDriver.java
 * 
 * This document is a part of SAGE project.
 *
 * Copyright (c) 2014 Jing Pu
 *
 */
package MacraigorJtagioPkg;

import java.util.Scanner;
import java.util.Arrays;
import java.io.*;
import java.lang.reflect.Array;
import java.lang.Math;
import java.util.Date;
import java.util.Objects;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import java.util.concurrent.TimeUnit;

import com.fazecast.jSerialComm.*;

/**
 * Jtag Driver adopted from SAGEChip/verif/JTAGDriver.vp
 * 
 * @author jingpu
 *
 */

public class adc_driver extends MacraigorJtagio {
	/**
	 * Enum type for specifying the clock domain of registers.
	 * 
	 * @author jingpu
	 *
	 */
	public static enum ClockDomain {
		tc_domain, sc_domain
	}

	public static enum JtagState {
		TestLogicReset, RunTestIdle, PauseDR, PauseIR, ShiftDR, ShiftIR
	}

	public static enum JtagReg {
		IR, DR
	}
	
	@SuppressWarnings("unused")
	public static Integer[] samp_phys_map = {
			0, 4,  8, 12,
			1, 5,  9, 13,
			2, 6, 10, 14,
			3, 7, 11, 15
	};
	
	public static Integer[] off_map = {
			0, 4,  8, 12,
			1, 5,  9, 13,
			2, 6, 10, 14,
			3, 7, 11, 15
	};

	@SuppressWarnings("unused")
	public static class TcAddressTable {
		static String en_v2t = "1000";
		static String en_slice = "1004";
		static String ALWS_ON = "1008";
		static String sel_clk_TDC = "100c";
		static String en_pm = "1010";
		static String en_v2t_clk_next = "1014";
		static String en_sw_test = "1018";
		static String en_gf = "101c";
		static String en_arb_pi = "1020";
		static String en_delay_pi = "1024";
		static String en_ext_Qperi = "1028";
		static String en_pm_pi = "102c";
		static String en_cal_pi = "1030";
		static String disable_state = "1034";
		static String en_clk_sw = "1038";
		static String en_meas_pi = "103c";
		static String sel_meas_pi = "1040";
		static String en_slice_rep = "1044";
		static String ALWS_ON_rep = "1048";
		static String sel_clk_TDC_rep = "104c";
		static String en_pm_rep = "1050";
		static String en_v2t_clk_next_rep = "1054";
		static String en_sw_test_rep = "1058";
		static String sel_pfd_in = "105c";
		static String sel_pfd_in_meas = "1060";
		static String en_pfd_inp_meas = "1064";
		static String en_pfd_inn_meas = "1068";
		static String sel_del_out = "106c";
		static String disable_ibuf_async = "1070";
		static String disable_ibuf_aux = "1074";
		static String disable_ibuf_test0 = "1078";
		static String disable_ibuf_test1 = "107c";
		static String en_inbuf = "1080";
		static String sel_inbuf_in = "1084";
		static String bypass_inbuf_div = "1088";
		static String inbuf_ndiv = "108c";
		static String en_inbuf_meas = "1090";
		static String en_biasgen = "1094";
		static String sel_del_out_pi = "1098";
		static String en_del_out_pi = "109c";
		static String pd_offset_ext = "10a0";
		static String i_val = "10a4";
		static String p_val = "10a8";
		static String en_ext_pi_ctl_cdr = "10ac";
		static String ext_pi_ctl_cdr = "10b0";
		static String en_ext_pfd_offset = "10b4";
		static String en_ext_pfd_offset_rep = "10b8";
		//static String en_ext_max_sel_mux = "10bc";
		static String en_pfd_cal = "10bc";
		static String en_pfd_cal_rep = "10c0";
		static String Navg_adc = "10c4";
		static String Nbin_adc = "10c8";
		static String DZ_hist_adc = "10cc";
		static String Navg_adc_rep = "10d0";
		static String Nbin_adc_rep = "10d4";
		static String DZ_hist_adc_rep = "10d8";
		static String Ndiv_clk_avg = "10dc";
		static String Ndiv_clk_cdr = "10e0";
		static String int_rstb = "10e4";
		static String sram_rstb = "10e8";
		static String cdr_rstb = "10ec";
		static String sel_outbuff = "10f0";
		static String sel_trigbuff = "10f4";
		static String en_outbuff = "10f8";
		static String en_trigbuff = "10fc";
		static String Ndiv_outbuff = "1100";
		static String Ndiv_trigbuff = "1104";
		static String bypass_out = "1108";
		static String bypass_trig = "110c";
		static String in_addr = "1110";
		static String[] ctl_v2tn = {"1200","1204","1208","120c","1210","1214","1218","121c","1220","1224","1228","122c","1230","1234","1238","123c"};
		static String[] ctl_v2tp = {"1300","1304","1308","130c","1310","1314","1318","131c","1320","1324","1328","132c","1330","1334","1338","133c"};
		static String[] init = {"1400","1404","1408","140c","1410","1414","1418","141c","1420","1424","1428","142c","1430","1434","1438","143c"};
		static String[] sel_pm_sign = {"1500","1504","1508","150c","1510","1514","1518","151c","1520","1524","1528","152c","1530","1534","1538","153c"};
		static String[] sel_pm_in = {"1600","1604","1608","160c","1610","1614","1618","161c","1620","1624","1628","162c","1630","1634","1638","163c"};
		static String[] ctl_dcdl_late = {"1700","1704","1708","170c","1710","1714","1718","171c","1720","1724","1728","172c","1730","1734","1738","173c"};
		static String[] ctl_dcdl_early = {"1800","1804","1808","180c","1810","1814","1818","181c","1820","1824","1828","182c","1830","1834","1838","183c"};
		static String[] ctl_dcdl_TDC = {"1900","1904","1908","190c","1910","1914","1918","191c","1920","1924","1928","192c","1930","1934","1938","193c"};
		static String[] ext_Qperi = {"1a00","1a04","1a08","1a0c"};
		static String[] sel_pm_sign_pi = {"1b00","1b04","1b08","1b0c"};
		static String[] del_inc = {"1c00","1c04","1c08","1c0c"};
		static String[] ctl_dcdl_slice = {"1d00","1d04","1d08","1d0c"};
		static String[] ctl_dcdl_sw = {"1e00","1e04","1e08","1e0c"};
		static String[] ctl_v2tn_rep = {"1f00","1f04"};
		static String[] ctl_v2tp_rep = {"2000","2004"};
		static String[] init_rep = {"2100","2104"};
		static String[] sel_pm_sign_rep = {"2200","2204"};
		static String[] sel_pm_in_rep = {"2300","2304"};
		static String[] ctl_dcdl_late_rep = {"2400","2404"};
		static String[] ctl_dcdl_early_rep = {"2500","2504"};
		static String[] ctl_dcdl_TDC_rep = {"2600","2604"};
		static String[] ctl_biasgen = {"2700","2704","2708","270c"};
		static String[] ext_pi_ctl_offset = {"2800","2804","2808","280c"};
		static String[] ext_pfd_offset = {"2900","2904","2908","290c","2910","2914","2918","291c","2920","2924","2928","292c","2930","2934","2938","293c"};
		static String[] ext_pfd_offset_rep = {"2a00","2a04"};
		static String[] ext_max_sel_mux = {"2b00","2b04","2b08","2b0c"};
	}
	@SuppressWarnings("unused")
	public static class ScAddressTable {
		static String cal_out_pi = "1000";
		static String addr = "1004";
		static String[] pm_out = {"1200","1204","1208","120c","1210","1214","1218","121c","1220","1224","1228","122c","1230","1234","1238","123c"};
		static String[] pm_out_pi = {"1300","1304","1308","130c"};
		static String[] Qperi = {"1400","1404","1408","140c"};
		static String[] max_sel_mux = {"1500","1504","1508","150c"};
		static String[] pm_out_rep = {"1600","1604"};
		static String[] adcout_avg = {"1700","1704","1708","170c","1710","1714","1718","171c","1720","1724","1728","172c","1730","1734","1738","173c"};
		static String[] adcout_sum = {"1800","1804","1808","180c","1810","1814","1818","181c","1820","1824","1828","182c","1830","1834","1838","183c"};
		static String[] adcout_hist_center = {"1900","1904","1908","190c","1910","1914","1918","191c","1920","1924","1928","192c","1930","1934","1938","193c"};
		static String[] adcout_hist_side = {"1a00","1a04","1a08","1a0c","1a10","1a14","1a18","1a1c","1a20","1a24","1a28","1a2c","1a30","1a34","1a38","1a3c"};
		static String[] pfd_offset = {"1b00","1b04","1b08","1b0c","1b10","1b14","1b18","1b1c","1b20","1b24","1b28","1b2c","1b30","1b34","1b38","1b3c"};
		static String[] adcout_avg_rep = {"1c00","1c04"};
		static String[] adcout_sum_rep = {"1d00","1d04"};
		static String[] adcout_hist_center_rep = {"1e00","1e04"};
		static String[] adcout_hist_side_rep = {"1f00","1f04"};
		static String[] pfd_offset_rep = {"2000","2004"};
		static String[] out_data = {"2100","2104","2108","210c","2110","2114","2118","211c","2120","2124","2128","212c","2130","2134","2138","213c","2140","2144"};
	}
	@SuppressWarnings("unused")
	private static class IRValue {
		static String extest = "00";
		static String idcode = "01";
		static String sample = "02";
		static String sc_cfg_data = "08";
		static String sc_cfg_inst = "09";
		static String sc_cfg_addr = "0A";
		static String tc_cfg_data = "0C";
		static String tc_cfg_inst = "0D";
		static String tc_cfg_addr = "0E";
		static String bypass = "FF";
	}

	@SuppressWarnings("unused")
	public static class OpCode {
		static String nop = "00";
		static String read = "01";
		static String write = "02";
		static String ack ="03";
	}

	/* IMPORTANT JTAG controller parameters must match real hardware. */
	private int jtag_inst_width = 5;
	private int sc_data_width = 32;
	private int sc_addr_width = 14;
	private int sc_op_width = 2;
	private int tc_data_width = 32;
	private int tc_addr_width = 14;
	private int tc_op_width = 2;

	private JtagState endStateIR, endStateDR;

	/**
	 * Default constructor
	 */
	public adc_driver() {
		super();
		this.endStateIR = JtagState.RunTestIdle;
		this.endStateDR = JtagState.RunTestIdle;
	}

	/**
	 * @param sc_data_width
	 * @param sc_addr_width
	 * @param tc_data_width
	 * @param tc_addr_width
	 */
	public adc_driver(int sc_data_width, int sc_addr_width, int tc_data_width,
			int tc_addr_width) {
		super();
		this.sc_data_width = sc_data_width;
		this.sc_addr_width = sc_addr_width;
		this.tc_data_width = tc_data_width;
		this.tc_addr_width = tc_addr_width;
		this.endStateIR = JtagState.RunTestIdle;
		this.endStateDR = JtagState.RunTestIdle;
	}

	/****************************************************************************
	 * Top level tasks
	 ***************************************************************************/


	public int get_sc_data_width() {
		return sc_data_width;
	}

	public int get_sc_addr_width() {
		return sc_addr_width;
	}

	public int get_tc_data_width() {
		return tc_data_width;
	}

	public int get_tc_addr_width() {
		return tc_addr_width;
	}

	/**
	 * Resets the jtag state machine and registers
	 */
	public void reset() {
		this.SetTRST(true);
		this.SetTRST(false);
	}

	/**
	 * Reads IDCODE of the test access port (TAP) device
	 * 
	 * @return the hex string dump of IDCODE
	 */
	public String readID() {
		shiftReg(JtagReg.IR, jtag_inst_width, IRValue.idcode);
		return shiftReg(JtagReg.DR, 32, "00000000");
	}

	/**
	 * Use JTAG transactions to write a register value in the register file
	 * 
	 * @param cd
	 *            clock domain of the register, i.e. system clock (sc_domain),
	 *            or TCK (tc_domain)
	 * @param address
	 *            address of the register in hex string, and the length of the
	 *            string must match sc_addr_width/tc_addr_width
	 * @param data
	 *            data to write in hex string, and the length of the string must
	 *            match sc_data_width/tc_data_width
	 */
	
	public int[][] read_SRAM() {
		int[][] out_data = new int[1024][18];
		System.out.print("SRAM Download: <");
		for(int i=0; i<1024; i+=1) {
			writeReg(ClockDomain.tc_domain, TcAddressTable.in_addr, zeroPadHexString(Integer.toHexString(i),8));
			writeReg(ClockDomain.tc_domain, TcAddressTable.in_addr, zeroPadHexString(Integer.toHexString(i),8));
			for(int j=0; j<18; j+=1) {
				//jtag.readReg(ClockDomain.sc_domain, ScAddressTable.out_data[j]);
				out_data[i][j] = hexStringToBytes(readReg(ClockDomain.sc_domain, ScAddressTable.out_data[j]).substring(14,16))[0];
			}
			
			if(i % 32 == 0) {
				System.out.print("|");
			}
		}
		System.out.println(">");
		return out_data;
	}
	
	public int[] read_SRAM_column(int col) {
		int[] out_data = new int[1024];
		System.out.print("SRAM Download: <");
		for(int i=0; i<1024; i+=1) {
			writeReg(ClockDomain.tc_domain, TcAddressTable.in_addr, zeroPadHexString(Integer.toHexString(i),8));
			//writeReg(ClockDomain.tc_domain, TcAddressTable.in_addr, zeroPadHexString(Integer.toHexString(i),8));
			out_data[i] = hexStringToBytes(readReg(ClockDomain.sc_domain, ScAddressTable.out_data[col]).substring(14,16))[0];
			if(i % 32 == 0) {
				System.out.print("|");
			}
		}
		System.out.println(">");
		return out_data;
	}
	
	public void write_SRAM_CSV(int[][] out_data, String filename, String filepath) throws IOException {
		FileWriter outFile = new FileWriter(filepath + filename);
		BufferedWriter writer = new BufferedWriter(outFile);
		
		String outStr = "";
		for(int i=0; i<1024; i+=1) {
			outStr += Integer.toString(i) + ",";
			for(int j=0; j<16; j+=1) {
					outStr += out_data[i][j] + ",";
			}
			outStr += "\n";
		}
		
		
		System.out.println("Saving SRAM Contents to CSV file");
		System.out.println("File Name: " + filename);
		writer.write(outStr);
		writer.close();
		
		System.out.println("File Path: " + filepath);
	}
	
	public void writeReg(ClockDomain cd, String address, String data) {
		writeReg(cd, address, data, OpCode.write);
	}
	public void writeReg(ClockDomain cd, String address, String data, String opcode) {
		if (cd == ClockDomain.sc_domain) {
			// writes address and data
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_addr);
			shiftReg(JtagReg.DR, sc_addr_width, address);
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_data);
			shiftReg(JtagReg.DR, sc_data_width, data);
			// sends op
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_inst);
			shiftReg(JtagReg.DR, sc_op_width, opcode);
		} else if (cd == ClockDomain.tc_domain) {
			// writes address and data
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_addr);
			shiftReg(JtagReg.DR, tc_addr_width, address);


			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_data);
			shiftReg(JtagReg.DR, tc_data_width, data);
			
			// sends op

			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_inst);
			shiftReg(JtagReg.DR, tc_op_width, opcode);
			
			
		}
	}

	/**
	 * 
	 * Use JTAG transactions to read a register value in the register file
	 * 
	 * @param cd
	 *            clock domain of the register, i.e. system clock (sc_domain),
	 *            or TCK (tc_domain)
	 * @param address
	 *            address of the register in hex string, and the length of the
	 *            string must match sc_addr_width/tc_addr_width
	 * @return register value in hex string, and the length of the string is
	 *         sc_data_width/tc_data_width
	 */
	public String readReg(ClockDomain cd, String address) {
		return readReg(cd, address, OpCode.read);
	}
	
	public String readReg(ClockDomain cd, String address, String opcode) {
		byte[] data_out = null;
		if (cd == ClockDomain.sc_domain) {
			int arrayLen = (sc_data_width + 3) /4 ; // bitlenth/4, rounded up
			data_out = new byte[arrayLen];
			byte[] dummy = new byte[arrayLen];
			// writes address
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_addr);
			shiftReg(JtagReg.DR, sc_addr_width, address);
			//System.out.println(Arrays.toString(hexStringToBytes(address)));

			// sends op
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_inst);
			shiftReg(JtagReg.DR, sc_op_width, opcode);
			//System.out.println(Arrays.toString(hexStringToBytes(opcode)));
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.sc_cfg_data);
			shiftReg(JtagReg.DR, sc_data_width, dummy, data_out);
			//System.out.println(Arrays.toString(data_out));

		} else if (cd == ClockDomain.tc_domain) {
			int arrayLen = (tc_data_width + 3) / 4; // bitlenth/4, rounded up
			data_out = new byte[arrayLen];
			byte[] dummy = new byte[arrayLen];
			// writes address and data
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_addr);
			shiftReg(JtagReg.DR, tc_addr_width, address);
			// sends op
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_inst);
			shiftReg(JtagReg.DR, tc_op_width, opcode);
			// read data
			shiftReg(JtagReg.IR, jtag_inst_width, IRValue.tc_cfg_data);
			shiftReg(JtagReg.DR, tc_data_width, dummy, data_out);
		}
		return bytesToHexString(data_out);
	}
	
	/****************************************************************************
	 * Very low level tasks to manipulate the jtag state machine
	 ***************************************************************************/

	public boolean shiftReg(JtagReg reg, int length_in_bits, byte tdi_data[],
			byte tdo_data[]) {
		byte[] tdo_to_compare = tdo_data.clone();		
		
		
		this.ScanIO(reg.name(), length_in_bits, tdi_data, tdo_data,
				getJtagEndState(reg).name());
		return Arrays.equals(tdo_data, tdo_to_compare);
	}
	
	public boolean shiftReg(JtagReg reg, int length_in_bits, String tdi_data,
			String tdo_data) {
		return shiftReg(reg, length_in_bits, hexStringToBytes(tdo_data),
				hexStringToBytes(tdi_data));
	}

	public String shiftReg(JtagReg reg, int length_in_bits, String tdi_data) {
		byte[] tdi_array = hexStringToBytes(tdi_data);
		byte[] tdo_array = new byte[tdi_array.length];
		shiftReg(reg, length_in_bits, tdi_array, tdo_array);
		return bytesToHexString(tdo_array);
	}

	public JtagState getJtagEndState(JtagReg reg) {
		JtagState state;
		switch (reg) {
		case DR:
			state = endStateDR;
		case IR:
			state = endStateIR;
		default:
			state = JtagState.RunTestIdle;
		}
		return state;
	}

	public void setJtagEndState(JtagReg reg, JtagState state) {
		switch(reg){
		case DR:
			endStateDR = state;
		case IR:
			endStateIR = state;
		}
	}
	
	protected static int find_minimum(int[] values) {
		
		int min_val = 129;
		int abs_val = 0;
		int len_val = Array.getLength(values);

		for(int ii=0; ii < len_val; ii+=1) {
			abs_val = Math.abs(values[ii]);
			if(min_val >= abs_val) {
				min_val = abs_val; 
			} 
		}
		return min_val;
	}

	protected static String zeroPadHexString(String hexString, int maxLen) {
		if(hexString.length() < maxLen)
			hexString = new String(new char[maxLen-hexString.length()]).replace("\0", "0") + hexString;
		else if (hexString.length() > maxLen)
			hexString = hexString.substring(0, maxLen);
		return hexString;
	}
	
	public static class psoc_interface {
		private SerialPort psocPort;
		private int baudRate;
		private String commId;
		
		public psoc_interface(String commId, int baudRate) throws InterruptedException {
			this.psocPort = SerialPort.getCommPort(commId);
			this.psocPort.setBaudRate(baudRate);
			this.commId = commId;
			this.baudRate = baudRate;
			this.psocPort.openPort();
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("2".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("0".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("1".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("0".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("2".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.closePort();
		}
		
		public void acquireSamples() throws InterruptedException {
			this.psocPort.openPort();
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("2".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("0".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("1".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("0".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.writeBytes("2".getBytes(), 1);
			TimeUnit.MILLISECONDS.sleep(100);
			this.psocPort.closePort();
		}
	}
	
	/**
	 * Convert a string representation of a hex dump to a byte array
	 * http://stackoverflow.com/questions/140131
	 * 
	 * Modified the stackoverflow solution such that the HEX number of LSB is in
	 * the first element of the byte array. ("46504301" -> {1, 76, 80, 70})
	 * 
	 * @param s
	 * @return
	 */
	protected static byte[] hexStringToBytes(String s) {
		int len = s.length();
		int arrayLen = len / 2;
		byte[] data = new byte[arrayLen];
		for (int i = 0; i < len; i += 2)
			data[arrayLen - i / 2 - 1] = (byte) ((Character.digit(s.charAt(i),
					16) << 4) + Character.digit(s.charAt(i + 1), 16));
		return data;
	}

	final protected static char[] hexArray = "0123456789ABCDEF".toCharArray();

	/**
	 * Convert a string representation of a hex dump to a byte array
	 * http://stackoverflow.com/questions/9655181
	 * 
	 * Modified the stackoverflow solution such that the HEX number of LSB is in
	 * the first element of the byte array. ( {1, 76, 80, 70} -> "46504301")
	 * 
	 * @param bytes
	 * @return
	 */
	protected static String bytesToHexString(byte[] bytes) {
		char[] hexChars = new char[bytes.length * 2];
		for (int j = 0; j < bytes.length; j++) {
			int v = bytes[bytes.length - j - 1] & 0xFF;
			hexChars[j * 2] = hexArray[v >>> 4];
			hexChars[j * 2 + 1] = hexArray[v & 0x0F];
		}
		return new String(hexChars);
	}


	public static void main(String[] args) throws IOException, InterruptedException {
		// runs an test on CGRA
		//System.out.println("runs an test on CGRA");
		adc_driver jtag = new adc_driver();
		psoc_interface psoc = new psoc_interface("COM7", 115200);
		
		// read IDCODE
		System.out.println("Connecting to JTAG and Reading ID");
		jtag.InitializeController("USB", "USB0", 1);
		jtag.reset();
	
		System.out.println("JTAG ID: " + jtag.readID());
		
		System.out.println("Configuring DUT");
		jtag.writeReg(ClockDomain.tc_domain, "1000", "00000001");
		jtag.writeReg(ClockDomain.tc_domain, "10b4",  "00000001");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.sel_inbuf_in, "00000001");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.bypass_inbuf_div, "00000001");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.inbuf_ndiv, "00000007");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.disable_ibuf_aux, "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_slice, "0000FFFF");
		
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pi_ctl_offset[0], zeroPadHexString(Integer.toHexString(0),8));
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pi_ctl_offset[1], zeroPadHexString(Integer.toHexString(136),8));
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pi_ctl_offset[2], zeroPadHexString(Integer.toHexString(286),8));
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pi_ctl_offset[3], zeroPadHexString(Integer.toHexString(462),8));
		
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_inbuf, "00000001");
		jtag.writeReg(ClockDomain.tc_domain, "10e8", "00000001");
		jtag.writeReg(ClockDomain.tc_domain, "1098", "00000000");
		jtag.writeReg(ClockDomain.tc_domain, "109c", "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.cdr_rstb, "00000001");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.disable_ibuf_async, "00000001");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_ext_pfd_offset, "FFFF");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_inbuf_meas, "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_biasgen, "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_trigbuff, "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.bypass_trig, "00000001");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.Ndiv_trigbuff, zeroPadHexString(Integer.toHexString(4),8));
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.sel_trigbuff, "00000008");
		jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.Ndiv_clk_cdr, "00000003");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_outbuff, "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.sel_outbuff, "00000002"); //zeroPadHexString(Integer.toHexString(1), 8)
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.bypass_out, "00000001");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.Ndiv_outbuff, zeroPadHexString(Integer.toHexString(4),8));
		jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.en_arb_pi, "00000001");
		jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.en_ext_Qperi, "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.int_rstb, "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.int_rstb, "00000001");
		
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pi_ctl_cdr, "00000000");
		jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.en_meas_pi, "00000000");

		jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.ext_Qperi[0], "00000011");
		jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.ext_Qperi[1], "00000011");
		jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.ext_Qperi[2], "00000011");
		jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.ext_Qperi[3], "00000011");

		Integer[] gain_adjust = { 
								    0,0,0,0,
									0,0,0,0,
									0,0,0,0,
									0,0,0,0
		};

		/*
		Integer[] offsets = {
			26,    25,    23,    24,
			27,    26,    24,    27,
			27,    26,    23,    24,
			27,    27,    26,    27
		};*/
		
		/*
		//240Mhz
		
		Integer[] offsets     = {
									27,27,23,23,
									28,27,21,27,
									26,29,27,28,
									28,28,29,26
		};*/
		
		//11MHz
		/*
		Integer[] offsets     = {
		 							1,-3,-2,0,
									1,2,1,2,
									1,0,2,2,
									2,0,2,1
		};*/
		
		//Integer[] offsets = {-4,   1,    0,    -2,    0, 0, -4, -3, -4, -5, -1, -1, -6, 0, 4, 4};	
		
		
		//int[] ideal_tdc_dcdl = {10, 2, 2, 13, 24, 2, 26, 22, 30, 11, 24, 28, 16, 10, 11, 23};
		//int[] ideal_tdc_dcdl = {24, 14, 27, 26, 4, 13, 27, 22, 24, 13, 7, 5, 13, 13, 24, 2};
		
		//int[] ideal_tdc_dcdl = {21,    15,    30,    13,     3,     5,    10,     3,     4,    21,     5,    25,    22,     5, 4, 4};
		//int[] ideal_tdc_dcdl = {   4,  12,   12,  7 ,    4,    4,    10,     7,     5,     2, 1 ,   10,     8,     8,     1,    10};
		//int[] ideal_tdc_dcdl = {21,    12,    12,   3,    10,     6,    23,     1,    21,     1,    25,     6,     3,    10, 21,    22};
		int[] ideal_tdc_dcdl = {8, 10, 4, 8, 8, 9, 7, 27, 27, 28, 5, 9, 27, 8, 7, 9};
		for(int i=0; i<16; i+=1) {
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ctl_v2tp[samp_phys_map[i]], zeroPadHexString(Integer.toHexString(7+gain_adjust[i]),8));
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ctl_v2tn[samp_phys_map[i]], zeroPadHexString(Integer.toHexString(7+gain_adjust[i]),8));
			//jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pfd_offset[i],zeroPadHexString(Integer.toHexString(5+offsets[i]),8));
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pfd_offset[i],zeroPadHexString(Integer.toHexString(0),8));
			jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.ctl_dcdl_TDC[samp_phys_map[i]], zeroPadHexString(Integer.toHexString(ideal_tdc_dcdl[i]-1),8));
			//jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.ctl_dcdl_TDC[samp_phys_map[i]], zeroPadHexString(Integer.toHexString(0),8));
		}
		
		//Offset Loop Below
		//Some kind of bug? You have to burn an acq cycle
		int[][] data;
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000000");
		for(int k=0; k<16; k+=1) {
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pfd_offset[k],zeroPadHexString(Integer.toHexString(0),8));
		}
		TimeUnit.MILLISECONDS.sleep(500);
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000001");
		jtag.readReg(ClockDomain.tc_domain, TcAddressTable.en_v2t);
		
		TimeUnit.MILLISECONDS.sleep(500);
		psoc.acquireSamples();
		TimeUnit.MILLISECONDS.sleep(500);
		data = jtag.read_SRAM();
		
		TimeUnit.MILLISECONDS.sleep(500);
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000001");
		jtag.readReg(ClockDomain.tc_domain, TcAddressTable.en_v2t);
		
		int new_offset = 0;
		int[] offsets = new int[16];
		String offset_hex;
		
		//Collect Samples, Calculate Offset
		for(int ii=0; ii<16; ii+=1) {
			offsets[ii] = 129;
		}
		
		int num_of_offset_cal = 5;
		
		for(int ll=0; ll<num_of_offset_cal; ll+=1) {
			TimeUnit.MILLISECONDS.sleep(500);
			psoc.acquireSamples();
			TimeUnit.MILLISECONDS.sleep(500);
        	data = jtag.read_SRAM();
        	
			for(int ii=0; ii<16; ii+=1) {
				int [] data_col = new int[1024];
				for(int jj=0; jj<1024; jj+=1) {
					data_col[jj] = data[jj][ii];
				}
				new_offset = find_minimum(data_col);
				if(new_offset < offsets[ii]) {
					offsets[ii] = new_offset;
				}
				offset_hex = zeroPadHexString(Integer.toHexString(offsets[ii]),8);
				System.out.print(offset_hex + " ");

			}
			System.out.println();
		}
		
		System.out.print("Written Offsets: ");
		for(int ii=0; ii<16; ii+=1) {
			offset_hex = zeroPadHexString(Integer.toHexString(offsets[ii]),8);
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pfd_offset[ii], offset_hex);
			System.out.print(offset_hex + " ");
		}
		System.out.println();

		System.out.print("Offsets: ");
		for(int ii=0; ii<16; ii+=1) {
			jtag.readReg(ClockDomain.tc_domain, TcAddressTable.ext_pfd_offset[ii]).substring(14,16);
			offset_hex = jtag.readReg(ClockDomain.tc_domain, TcAddressTable.ext_pfd_offset[ii]).substring(14,16);
			System.out.print(offset_hex + " ");
		}
		System.out.println();
		//Offset Loop Above
		
		
		
		
		//Single Channel Below
		/*
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000000");
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000001");
		
		TimeUnit.MILLISECONDS.sleep(100);;
		System.out.println(jtag.readReg(ClockDomain.tc_domain, TcAddressTable.en_v2t));
		
		TimeUnit.MILLISECONDS.sleep(100);
		System.out.println("Acquiring Samples");
		psoc.acquireSamples();
		TimeUnit.MILLISECONDS.sleep(1000);
		
		int[][] out_data = jtag.read_SRAM();
		
		int[] offsets = new int[16];
		for(int ii=0; ii<16; ii+=1) {
			int [] data_col = new int[1024];
			for(int jj=0; jj<1024; jj+=1) {
				data_col[jj] = out_data[jj][ii];
			}
			offsets[ii] = find_minimum(data_col);
		}
		
		String offset_hex = "";
		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000000");
		for(int ii=0; ii<16; ii+=1) {
			offset_hex = zeroPadHexString(Integer.toHexString(offsets[ii]),8);
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.ext_pfd_offset[ii], offset_hex);
		}

		System.out.print("Offsets: ");
		for(int ii=0; ii<16; ii+=1) {
			offset_hex = jtag.readReg(ClockDomain.tc_domain, TcAddressTable.ext_pfd_offset[ii]).substring(14,16);
			System.out.print(offset_hex + " ");
		}
		System.out.println();

		jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000001");
		System.out.println(jtag.readReg(ClockDomain.tc_domain, TcAddressTable.en_v2t));

		TimeUnit.MILLISECONDS.sleep(100);
		System.out.println("Acquiring Samples");
		psoc.acquireSamples();
		TimeUnit.MILLISECONDS.sleep(1000);
		
		out_data = jtag.read_SRAM();
		
		Date today = Calendar.getInstance().getTime();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-hhmmss");
		String postfix_date = formatter.format(today);
		
		String filepath="C:\\Users\\VLSIGroup-HAL9000\\Desktop\\Open Source HSL Test Chip #1\\test\\data2\\" ;
		File file = new File(filepath);
		file.mkdir();
		
		
		String filename="adc_" + postfix_date  + ".csv";
		jtag.write_SRAM_CSV(out_data, filename, filepath);
		*/ 
		//Single Channel Above
		

		
		//TDC Sweep Below
		System.out.println("Rotating TDCs");
		int[][][] mat_data = new int[16][1024][32];
		for(int i=0; i<2; i+=1) {
			System.out.println("Iteration: " + i);
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000000");
			for(int k=0; k<16; k+=1) {
				jtag.writeReg(ClockDomain.tc_domain,  TcAddressTable.ctl_dcdl_TDC[samp_phys_map[k]], zeroPadHexString(Integer.toHexString(i),8));
			}
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000001");
			jtag.readReg(ClockDomain.tc_domain, TcAddressTable.en_v2t);
			
			TimeUnit.MILLISECONDS.sleep(500);
			psoc.acquireSamples();
			TimeUnit.MILLISECONDS.sleep(500);
        	data = jtag.read_SRAM();
        	
			jtag.writeReg(ClockDomain.tc_domain, TcAddressTable.en_v2t, "00000000");
			
	        for(int k=0; k<16; k+=1) {
				for(int j=0; j<1024; j+=1) {
					mat_data[k][j][i] = data[j][k];	
				}
	        }
		}
		
		Date today = Calendar.getInstance().getTime();
		SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-hhmmss");
		String postfix_date = formatter.format(today);
		
		String filepath="C:\\Users\\VLSIGroup-HAL9000\\Desktop\\Open Source HSL Test Chip #1\\test\\data\\tdc_" + postfix_date + "\\" ;
		File file = new File(filepath);
		file.mkdir();
		
		
		for(int k =0; k<16; k+=1) {
			String filename="tdc_dcdl_" + k + ".csv";
			FileWriter outFile = new FileWriter(filepath + filename);
			BufferedWriter writer = new BufferedWriter(outFile);
			
			String outStr = "";
			for(int i=0; i<1024; i+=1) {
				outStr += Integer.toString(i) + ",";
				for(int j=0; j<32; j+=1) {
						outStr += mat_data[k][i][j] + ",";
				}
				outStr += "\n";
			}
			
			System.out.println("Saving SRAM Contents to CSV file");
			System.out.println("File Name: " + filename);
			writer.write(outStr);
			writer.close();
		}
		System.out.println("File Path: " + filepath);
		//TDC Sweep Below

		
		// Kill the controller...
		jtag.CloseController();
	
	}
}
