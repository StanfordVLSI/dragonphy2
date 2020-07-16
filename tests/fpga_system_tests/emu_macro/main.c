#include "gpio_funcs.h"
#include <stdio.h>
#include <string.h>
#include "sleep.h"

u32 sleep_time = 20;

void cycle() {
    // min usleep value is "5" when emu_clk_freq is 5 MHz
    usleep(sleep_time);
    set_tck(1);
    usleep(sleep_time);
    set_tck(0);
    usleep(sleep_time);
}

void do_init() {
   // emulator controls
   set_emu_rst(1);
   set_emu_ctrl_mode(0);
   set_emu_ctrl_data(0);
   set_emu_dec_thr(0);

   // noise controls
   set_jitter_rms_int(0);
   set_noise_rms_int(0);

   // JTAG-specific
   set_tdi(0);
   set_tck(0);
   set_tms(1);
   set_trst_n(0);

   // Other signals
   set_rstb(0);
}

void do_reset() {
    // initialize JTAG signals
    set_tdi(0);
    set_tck(0);
    set_tms(1);
    set_trst_n(0);
    cycle();

    // de-assert reset
    set_trst_n(1);
    cycle();

    // go to the IDLE state
    set_tms(1);
    cycle();
    for (u32 i=0; i<10; i++){
    	cycle();
    }

    set_tms(0);
    cycle();
}

void shift_ir (u32 inst_in, u32 length) {
    // Move to Select-DR-Scan state
    set_tms(1);
    cycle();

    // Move to Select-IR-Scan state
    set_tms(1);
    cycle();

    // Move to Capture IR state
    set_tms(0);
    cycle();

    // Move to Shift-IR state
    set_tms(0);
    cycle();

    // Remain in Shift-IR state and shift in inst_in.
    // Observe the TDO signal to read the x_inst_out
    for (u32 i=0; i<(length-1); i++){
        set_tdi((inst_in >> i) & 1);
        cycle();
    }

    // Shift in the last bit and switch to Exit1-IR state
    set_tdi((inst_in >> (length - 1)) & 1);
    set_tms(1);
    cycle();

    // Move to Update-IR state
    set_tms(1);
    cycle();

    // Move to Run-Test/Idle state
    set_tms(0);
    cycle();
    cycle();
}

u32 shift_dr (u32 data_in, u32 length) {
	// Move to Select-DR-Scan state
    set_tms(1);
    cycle();

    // Move to Capture-DR state
    set_tms(0);
    cycle();

    // Move to Shift-DR state
    set_tms(0);
    cycle();

    // Remain in Shift-DR state and shift in data_in.
	// Observe the TDO signal to read the data_out
    u32 retval = 0;
    for (u32 i=0; i<(length-1); i++){
        set_tdi((data_in >> i) & 1);
        retval |= (get_tdo() << i);
        cycle();
    }

    // Shift in the last bit and switch to Exit1-DR state
    set_tdi((data_in >> (length - 1)) & 1);
    retval |= (get_tdo() << (length-1));
    set_tms(1);
    cycle();

    // Move to Update-DR state
    set_tms(1);
    cycle();

    // Move to Run-Test/Idle state
    set_tms(0);
    cycle();
    cycle();

    // Return result
    return retval;
}

u32 read_id() {
    shift_ir(1, 5);
    return shift_dr(0, 32);
}

enum cmd_t {
    RESET,
    INIT,
    EXIT,
    ID,
    SIR,
    SDR,
    QSDR, // "quiet" SDR -- does not print anything
    SET_RSTB,
    SET_EMU_RST,
    SET_SLEEP,
    SET_TDI,
    SET_TCK,
    SET_TMS,
    SET_TRST_N,
    GET_TDO,
    SET_NOISE_RMS,
    SET_JITTER_RMS
} cmd;

int main() {
    // character buffering
    u32 idx = 0;
    char rcv;
    char buf [32];
    
    // command processing;
    u32 arg1;
    u32 arg2;
    u32 nargs = 0;

    if (init_GPIO() != 0) {
        xil_printf("GPIO Initialization Failed\r\n");
        return XST_FAILURE;
    }

    do_init();
    do_reset();
    
    while (1) {
        rcv = inbyte();
        if ((rcv == ' ') || (rcv == '\t') || (rcv == '\r') || (rcv == '\n')) {
            // whitespace
            if (idx > 0) {
                buf[idx++] = '\0';
                if (nargs == 0) {
                    if (strcmp(buf, "RESET") == 0) {
                        cmd = RESET;
                        do_reset();
                        nargs = 0;
                    } else if (strcmp(buf, "INIT") == 0) {
                        cmd = INIT;
                        do_init();
                        nargs = 0;
                    } else if (strcmp(buf, "EXIT") == 0) {
                        cmd = EXIT;
                        return 0;
                    } else if (strcmp(buf, "ID") == 0) {
                        cmd = ID;
                        xil_printf("%lu\r\n", read_id());
                        nargs = 0;
                    } else if (strcmp(buf, "SIR") == 0) {
                        cmd = SIR;
                        nargs++;
                    } else if (strcmp(buf, "SDR") == 0) {
                        cmd = SDR;
                        nargs++;
                    } else if (strcmp(buf, "QSDR") == 0) {
                        cmd = QSDR;
                        nargs++;
                    } else if (strcmp(buf, "SET_RSTB") == 0) {
                        cmd = SET_RSTB;
                        nargs++;
                    } else if (strcmp(buf, "SET_EMU_RST") == 0) {
                        cmd = SET_EMU_RST;
                        nargs++;
                    } else if (strcmp(buf, "SET_SLEEP") == 0) {
                        cmd = SET_SLEEP;
                        nargs++;
                    } else if (strcmp(buf, "SET_TDI") == 0) {
                        cmd = SET_TDI;
                        nargs++;
                    } else if (strcmp(buf, "SET_TCK") == 0) {
                        cmd = SET_TCK;
                        nargs++;
                    } else if (strcmp(buf, "SET_TMS") == 0) {
                        cmd = SET_TMS;
                        nargs++;
                    } else if (strcmp(buf, "SET_TRST_N") == 0) {
                        cmd = SET_TRST_N;
                        nargs++;
                    } else if (strcmp(buf, "SET_NOISE_RMS") == 0) {
                        cmd = SET_NOISE_RMS;
                        nargs++;
                    } else if (strcmp(buf, "SET_JITTER_RMS") == 0) {
                        cmd = SET_JITTER_RMS;
                        nargs++;
                    } else if (strcmp(buf, "GET_TDO") == 0) {
                        cmd = GET_TDO;
                        xil_printf("%lu\r\n", get_tdo());
                        nargs = 0;
                    } else {
	                    xil_printf("ERROR: Unknown command\r\n");
		            }
                } else if (nargs == 1) {
                    sscanf(buf, "%lu", &arg1);
                    if (cmd == SET_RSTB) {
                        set_rstb(arg1);
                        nargs=0;
                    } else if (cmd == SET_EMU_RST) {
                        set_emu_rst(arg1);
                        nargs=0;
                    } else if (cmd == SET_TDI) {
                        set_tdi(arg1);
                        nargs=0;
                    } else if (cmd == SET_TCK) {
                        set_tck(arg1);
                        nargs=0;
                    } else if (cmd == SET_TMS) {
                        set_tms(arg1);
                        nargs=0;
                    } else if (cmd == SET_TRST_N) {
                        set_trst_n(arg1);
                        nargs=0;
                    } else if (cmd == SET_NOISE_RMS) {
                        set_noise_rms(arg1);
                        nargs=0;
                    } else if (cmd == SET_JITTER_RMS) {
                        set_jitter_rms(arg1);
                        nargs=0;
                    } else if (cmd == SET_SLEEP) {
                        sleep_time = arg1;
                        nargs=0;
                    } else {
                        nargs++;
                    }
                } else if (nargs == 2) {
                    sscanf(buf, "%lu", &arg2);
                    if (cmd == SIR) {
                        shift_ir(arg1, arg2);
                    } else if (cmd == SDR) {
                        xil_printf("%lu\r\n", shift_dr(arg1, arg2));
                    } else if (cmd == QSDR) {
                        shift_dr(arg1, arg2);
                    }
                    nargs = 0;
                }  
            }
            idx = 0;
        } else {
            // load next character
            buf[idx++] = rcv;
        }
    }

    return 0;
}
