package MacraigorJtagioPkg;


/**
 * <p>Title: MacraigorJtagioPkg</p>
 *
 * <p>Description: MacraigorJtagio JNI routines</p>
 *
 * <p>Copyright: Copyright (c) 2006</p>
 *
 * <p>Company: Macraigor Systems LLC</p>
 *
 * @author James MacGregor
 * @version 1.0
 */


public class MacraigorJtagio
{
  public MacraigorJtagio()
  {
    return;
  } // CONSTRUCTOR

  public native boolean ResetTap(boolean assert_trst, String jtag_state); //$SUP-AUN$

  // Reset the target's TAP by issuing five TCKs with TMS=1 (optionally
  // asserting TRST for the duration). Move to the specified stable state.
  // Parameters:
  //   assert_trst [true/false] true  : assert TRST for the duration
  //                            false : do not asert TRST
  //   jtag_state ["TestLogicReset","RunTestIdle","PauseDR","PauseIR",
  //               "ShiftDR","ShiftIR"] - JTAG state CPU will be placed in
  // Returns : true - command succeeded
  //           false - invalid parameter call ErrorText() for
  //                   more details

  public native boolean InitializeController(String device_type, //$SUP-AUN$
                                           String device_address,
                                           int     speed);

 // Initialize JTAG controller. Given device type, base address (port)
 // speed in Hz and license code based on the MachineID (Raven/Wiggler only)
 // Parameters:
 //    device ["WIGGLER"/"RAVEN"/"USB"/"WIFIDEMON-USB"] - string with device name
 //       speed - jtag speed
 //    address - based on device type :
 //       WIGGLER/RAVEN     : "LPT1" - "LPT4"
 //       USB/WIFIDEMON-USB : "USB0" - "USB15"
 //    JTAG_speed [1 - 8] - indicates JTAG clock rate
 // Returns : true - command succeeded
 //           false - invalid parameter call ErrorText() for
 //                   more details

 public native void CloseController();

 //  Closes connection to the JTAG controller


 public native String GetMachineID();

 // Returns string in the format "xxxxxx" where each 'x' is a hexidecimal
 // digit. Wigglers and Ravens require a license code based on MachineID
 // (the host system's MAC address). This call fetches this value so
 // it can be transfered Macraigor and a license generated for this machine.


 public native String GetVersion();

 // Returns software/hardware component version numbers in the format
 // "<JtagSoftwareVersion>.<JtagHdwVersion>" where each is two hex digits

 public native void ConfigDriver(int flags);

 // Configures details of the JtagIO operation. Each bit in flags is a
 // configuration flag
 // Parameters:
 //       flags - configuration bit flags
 //                A zero means - default
 //                FLAGS (bit number)
 //        0  -  0: first byte out/in is array[0]
 //              1: first byte out/in is array[n]
 //        1  -  0: place bytes in array in order
 //              1: swap bytes for Intel like word
 //        2  -  0: scan in stuffs '0' into target
 //              1: scan in stuffs '1' into target
 //        3  -  0: default TMS state transitions
 //              1: ARM TMS state transitions
 //        5  -  0: default TMS
 //              1: TMS for BROADCOM SIBYTE


 public native boolean SetScanChainData(int jtag_device_count,
                                       int ir_length_in_bits[]);

 // This method informs jtagio about the current system under test.
 // Parameters:
 //       jtag_device_count [1 - 500] number of devices in jtag_device_list
 //       ir_length_in_bits [1 - ...] - array of the numbers of bits in each
 //                       device's JTAG INSTRUCTION_REGISTER. Each JTAG device
 //                       supports 2 parallel scan chain types DATA and
 //                       INSTRUCTION.  The command scanned into the
 //                       INSTRUCTION_REGISTER scan chan determines the length
 //                       of the DATA_REGISTER scan chain.
 // Returns : true - command succeeded
 //           false - invalid parameter call ErrorText() for
 //                   more details


 public native void ResetController();

 // resets jtag controller to default values

 public native boolean Initialized();

 // returns TRUE if JtagIO has been intialized, FALSE if not

 public native boolean InError();

 // returns TRUE if pervious JTAGIO operation has resulted in an
 // error condition. The in error state can be cleared by calling
 // InitializeController() or ResetController()


 public native boolean SetDevice(int device_index);

 // Specifies which jtag device is currently selected.
 // device_index - [0 - ...] the device's position in the list of devices
 //                on the scan chain, 0 = the device closest to TD0
 //               (ie TDI - ... - 2 - 1 - 0 - TDO)
 // Returns : true - command succeeded
 //           false - invalid parameter call ErrorText() for
 //                   more details


 public native int CurrentDevice();

 // Returns the current device index. The device with an index of zero
 // is the device closest to TDI.
 // Returns : [0 ...] current device index


 public native String CurrentDeviceType();

 //  Returns a string containing the current device type.
 //  The device with an index of zero is the device closest to TDI.
 //  Returns : device ["WIGGLER"/"RAVEN"/"USB"/"WIFIDEMON-USB"] - string
 //  with device name


 public native String GetValidDeviceList();

  //  Returns a string containing the names of all the Macraigor JTAG
  //  devices that work on this HOST PC sperated by a space either
  //  "USB WIGGLER RAVEN" or a subset of this list


public native int NumberOfDevicesInScanChain();

 // Returns the number of devices in the scan chain


 public native boolean GetDeviceInfo(int jtag_device_parameters[]);

 // Returns scan chain information for the current jtag device
 // in an array.
 // Parameters:
 //   jtag_device_parameters[5] - array of ints that will contain the following
 //        after the call completes :
 //          jtag_device_parameters[0] - ir_length_in_bits
 //                                [1] - bits_from_dr_start
 //                                [2] - bits_to_dr_end
 //                                [3] - bits_from_ir_start
 //                                [4] - bits_to_ir_end


 public native void SetTRST(boolean assert_TRST);

 // Sets JTAG TRST line
 //  Parameters:
 //     assert [true/false] - value assigned to JTAG chip TRST line



 public native void SetSpeed(int speed);

 // sets jtag clock speed
 // Parameters:
 //     speed [1 - 8] - jtag speed value 1 = fastest 8 - slowest


 public native int GetSpeed();

 // returns current jtag clock speed



 public native void WriteOutputs(int value);

 // write caller supplied value to parallel I/O port
 // Parameters:
 //     value [0 - 0xFF] - value that will appear on output lines


 public native int ReadInputs();

 // return inputs read from parallel I/O port
 // Returns [0 - 0xF] - value read from lower 4 parallel I/O input lines


 public native void DiscreteIO(int value);

 // output  caller specified value to DISCRETEIO port
 // Parameters:
 //    value [0 - 0xFF] - value that will appear on DISCRETEIO port lines


 public native void WritePin(boolean assert_pin, int pin_number);

 // assert or deassert the specified pin, doesn't matter if pin is active high
 // or active low. Does The Right Thing(tm)
 // Parameters:
 //   assert [true/false] - value to set specified output pin to
 //    pin_e [0 - 5] - JTAG pin to be written

 public native void ReleaseToOS();

 // release to the operating system during long subroutine calls. Returns
 // after 1 system clock tick


 public native void OSDelay(int delay_in_milliseconds);

 // release to the operating system for delay_in_milliseconds
 // milliseconds before returning
 // Parameters:
 //   delay_in_milliseconds [0 - 0xFFFF] number of milliseconds to wait before
 //                                      returning

 public native short UsbDeviceCount();

  // Returns the number of Macraigor USB devices USBDemons/USBSprites
  //  the device driver sees on USB bus.
  //  NOTE: This method is only active in when connected to a USB device
  //        otherwize it will return 0
  // Returns : number of Macraigor devices on USB bus


  public native void UsbLed(boolean led_on);

   // Controls the state of the LED on the current USBDemon/USBSprite.
   // NOTE: This method is only active in when connected to a USB device
   // Parameters:
   //   led_on [true/false] true : turn on LED, false : turn off LED


  public native String UsbDeviceSerialNumber(int usb_device_number);
  public native long   UsbDeviceSiliconId(int usb_device_number);
  public native String UsbDeviceHardwareFlags(int usb_device_number);
  public native String UsbDeviceEepromFlags(int usb_device_number);


   // These 4 methods return parameters of a caller specified USB device
   // UsbDevice:
   //  SerialNumber  - returns 15 character USB2 device serial number string
   //  SiliconId     - returns 64 bit silicon id
   //  HardwareFlags - returns string containing one or more of the following
   //        each separated by a space (" ") :
   //           "USB1",
   //           "USB2",
   //           "Sprite",
   //           "Wiggler"
   //           "HighSpeed",
   //           "Hub2.0"
   //  EepromFlags - returns string containing one or more of the following
   //        each separated by a space (" ") :
   //           "FlashProgrammer",
   //           "FlashAccess"",
   //           "TargetAccess",
   //           "JSCAN",
   //           "JtagCommander",
   //           "HighSpeed",
   //           "Sprite"
   //           "BufferedScan"
   //           "Coldfire"


  public native boolean UsbGetScanBitmap(byte scan_bitmap[]);

   // Returns via usb_scan_bitmap_ptr usb device identifier of
   // the specified USB device
   // NOTE: This method is only active in when connected to a USB device
   //       It will return the following from a non-jtag device :
   //       contents of scan_bitmap[] = 0
   // Parameters:
   //    scan_bitmap[51] - array of scan bitmap bytes which will be
   //               filled in the this function.
   // Returns : true - command succeeded
   //           false - invalid parameter call ErrorText() for
   //                   more details

   public native boolean UsbLicense(int usb_device_number,
                                 int license1,
                                 int license2,
                                 int license3,
                                 int license4);

 // Sends a license code to the specified USB2 device. This license, is
 // validated and if accepted sets a eeprom flag in the device
 // NOTE: This method is only active in when connected to a USB2 device
 // Parameters:
 //    usb_device_number [0-15] usb device index
 //    license1 - first 32 bits of license code
 //    license2 - second 32 bits of license code
 //    license3 - third 32 bits of license code
 //    license4 - forth 32 bits of license codee
 // Returns : true - command succeeded, license programmed into device
 //           false - invalid license/device call ErrorText() for
 //                   more details


  public native boolean StateMove(String jtag_state);

 // Issue TMS and TCK transitions to move the target's TAP
 // controller from its current state (as specified by a previous
 // state modifying function) to the specified state.
 // Parameters:
 //    jtag_state ["TestLogicReset","RunTestIdle","PauseDR","PauseIR",
 //                "ShiftDR","ShiftIR"] - JTAG state CPU will be placed in
 // Returns : true - command succeeded
 //           false - invalid parameter call ErrorText() for
 //                   more details


 public native boolean StateJump(String jtag_state);

 // Update the current state maintained by TAP controller, but do
 // not issue TMS or TCK transitions. Used when target's selected
 // TAP is changed (e.g. through ExtraBreaker interaction).
 // Parameters:
 //     jtag_state ["TestLogicReset","RunTestIdle","PauseDR","PauseIR",
 //                 "ShiftDR","ShiftIR"] - JTAG state CPU will be placed in
 // Returns : true - command succeeded
 //           false - invalid parameter call ErrorText() for
 //                   more details


 public native boolean ScanIO(String jtag_register,
                               int length_in_bits,
                               byte out_data[],
                               byte in_data[],
                               String jtag_state);

 // Move the TAP controller to the shift state specified by register
 // (instruction_register or data_register), clock test data pointed
 //  out_data[] out (to target's TDI pin), read data clocked in (from
 // target's TDO pin) and store in in_data[], and
 // move the TAP controller to the state specifyed by state.
 // Parameters:
 //   jtag_regiser ["IR"/"DR"] - target register
 //   length_in_bits [1 - ...] - number of bits in scan chain contained in
 //           in_data and out_data
 //   out_data - array of bytes containing the scan chain to be
 //             output via jtag
 //   in_data - array of bytes which will contain the scan chain
 //             to be input via jtag
 //    jtag_state ["TestLogicReset","RunTestIdle","PauseDR","PauseIR",
 //             "ShiftDR","ShiftIR"] - JTAG state CPU will be placed
 //             in at the end of the scan operation
 // Returns : true - command succeeded
 //           false - invalid parameter call ErrorText() for
 //                   more details


 public native boolean ScanOut( String jtag_register,
                                 int 	length_in_bits,
                                 byte   out_data[],
                                 String jtag_state);

 // "Output only" variant of scan_io. Data arriving on TDO is discarded.
 // Parameters:
 //       jtag_regiser ["IR"/"DR"] - target register
 //       length_in_bits [1 - ...] - number of bits in scan chain contained in
 //               out_data
 //       out_data - array of bytes containing the scan chain to be
 //                  output via jtag to TDI
 //       jtag_state ["TestLogicReset","RunTestIdle","PauseDR","PauseIR",
 //                    "ShiftDR","ShiftIR"] - JTAG state CPU will be placed
 //                     in at the end of the scan operation
 // Returns : true - command succeeded
 //           false - invalid parameter call ErrorText() for
 //                   more details


 public native boolean ScanIn(String	jtag_register,
                               int 	length_in_bits,
                               byte	in_data[],
                               String	jtag_state);

 // "Input only" variant of ScanIO. Data placed on TDI is fixed high by
 // default, this can by changed by ConfigDriver() flag.
 // Parameters:
 //       jtag_regiser ["IR"/"DR"] - target register
 //       length_in_bits [1 - ...] - number of bits in scan chain contained in
 //               in_data
 //       in_data - array of bytes which will contain the scan chain
 //                 to be input via jtag from TDO
 //       jtag_state ["TestLogicReset","RunTestIdle","PauseDR","PauseIR",
 //                    "ShiftDR","ShiftIR"] - JTAG state CPU will be placed
 //                     in at the end of the scan operation
 // Returns : true - command succeeded
 //           false - invalid parameter call ErrorText() for
 //                   more details


 public native boolean ScanInPartial(String jtag_register,
                        int total_scan_length,
                        int first_bit_to_read,
                        int length_to_read,
                        byte out_data[],
                        byte in_data[],
                        boolean  finish,
                        String  jtag_state);

  // Faster version of scanIO. Only retrieves a subset of the total scan chain.
  // Parameters:
  //       jtag register ["IR"/"DR"] - destination shift register (IR = JTAG
  //            Instruction register, DR = JTAG Data Register
  //        length_in_bits [1 - ...] - number of bits in scan chain contained in
  //                in_data and out_data
  //        first_bit_to_read - bit number of the first bit to be read. Bits
  //                            before this are discarded.
  //        length_to_read - length in bits of the data to be read. Bits
  //                            after this length are discarded
  //        out_data - array of bytes containing the scan chain to be
  //                output via jtag
  //        in_data - array of bytes which will contain the scan chain
  //                to be input via jtag
  //        finish - Boolean indicating whether or not the rest of the scan
  //                 chain after first_bit_to_read + length_to_read should be
  //                 clocked out.
  //        jtag_state ["TestLogicReset","RunTestIdle","PauseDR","PauseIR",
  //                     "ShiftDR","ShiftIR"] - JTAG state CPU will be placed
  //                      in at the end of the scan operation
  // Returns : true - command succeeded
  //           false - invalid parameter call ErrorText() for
  //                   more details


  public native boolean ScanOnly(int  length_in_bits,
                            byte out_data[],
                            byte in_data[] );

 // "Scan only" variant of scan_io. Machine state is unchanged, data
 //  is simply clocked in/out.
 // Parameters:
 //    length_in_bits [1 - ...] - number of bits in scan chain contained in
 //            in_data and to be written to out_data
 //    out_data - array of bytes containing the scan chain to be
 //            output via jtag	OR NULL if no data to be scanned out
 //    in_data - array of bytes which will contain the scan chain
 //            to be input via jtag


 public native boolean CutScanChain( byte  origional_scan_chain[],
                                  int   start_bit,
                                  int   number_of_bits,
                                  byte  new_scan_chain[]);

  // Copies substring from one jtag bit string into another jtag bit stream
  // Parameters:
  //   origional_scan_chain - scan chain to be cut from
  //   start_bit - which bit in the overall scan chain starts the
  //        subchain to be copied
  //   number_of_bits - number of bits to be copied
  //   new_scan_chain - pointer to buffer which will contain the subset of the
  //           scan chain cut from origional_scan_chain
  // Returns : true - command succeeded
  //           false - invalid parameter call ErrorText() for
  //                   more details


  public native boolean PasteScanChain(byte  origional_scan_chain[],
                                   byte  add_this_scan_chain[],
                                   int   add_this_length_in_bits,
                                   int   start_bit);

  // Inserts substring into jtag bit stream. It overwrites the current
  // contents of origional_scan_chain at the specified bit positions
  // Parameters:
  //    origional_scan_chain - scan chain to be modified
  //    add_this_scan_chain  - contains bits to be put in origional_scan_chain
  //    start_bit - the index (0 based) of the first bit in origional_scan_chain
  //         to be overwritten by the contents of add_this_scan_chain
  //    number_of_bits - number of bits to be copied
  // Returns : true - command succeeded
  //           false - invalid parameter call ErrorText() for
  //                   more details


  public native int IRScanLengthInBits();

   // Returns Length of IR jtag scan chain in bits


  public native int BuildIRScanChain(int   device_index,
                                     int   instruction,
                                     byte  ir_scan_chain[]);

   // Builds an IR scan chain by first filling all device instruction
   // registers with the appropriate bypass command and then overwriting the
   // jtag device specified by the current device's instruction register with
   // the caller specified instruction. The newly built chain is written into
   // ir_scan_chain[]
   // Parameters:
   //   device_index - [0 - ...] the device's position in the list of devices
   //           on the scan chain, 0 = the device closest to TDI
   //   instruction - jtag op code to be written into the device's jtag
   //            instruction register
   //   ir_scan_chain - array which will contain the new IR scan chain
   // Returns : new_ir_chain_length_in_bits - the number of bits in the newly
   //                                         created IR scan chain

   public native boolean CutIRScanChain(int	device_index,
                                     byte	origional_ir_scan_chain[],
                                     int	start_at_bit,
                                     int	copy_this_many_bits,
                                     byte	new_scan_chain[]);

    // Removes the CPU(specified by device_index)'s scan data bits from the
    // origional_ir_scan_chain. This function assumes that origional_ir_
    // scan_chain[] contains all the IR scan bits scanned in via JTAG
    // start_at_bit is offset by the number of bypass bits that preceed the
    // start of this device's IR scan chain. The resulting subchain is written
    // into new_scan_chain[].
    // Parameters:
    //   device_index - [0 - ...] the device's position in the list of devices
    //       on the scan chain, 0 = the device closest to TDI
    //   origional_ir_scan_chain[]	- full length scan chain containing both
    //       this cpu's IR scan bits and the IR scan bits of other cpus in the
    //       IR scan chain
    //   start_at_bit - [0 - ...] first bit in this CPU's IR scan chain to
    //       copy into new_scan_chain
    //   copy_this_many_bits	- [ - ...] number of bits to copy
    //   new_scan_chain - pointer to array into which the specified subset of
    //            origional_ir_scan_chain will be written


    public native int DRBypassLengthInBits(int device_index);

     // Returns the bypass bits in the DR scan chain, assuming that the
     //  device_index CPU is not in bypass mode
     // Parameters:
     //     device_index - [0 - ...] the device's position in the list of devices
     //             on the scan chain, 0 = the device closest to TDO
     //             (ie TDI - ... - 2 - 1 - 0 - TDO)
     // Returns : DR bypass bit length (without device_index CPU's bypass bits)


    public native int BuildDRScanChain(int      device_index,
                                       byte     this_device_scan_chain[],
                                       int      this_device_length_in_bits,
                                       byte     full_dr_scan_chain[]);

    // Builds a DR scan chain (for a system where all jtag devices but the one
    // specified by the device_index are in bypass mode) by pasting the this_device_scan_chain into
    // the appropriate bit locations within the full_dr_scan_chain. The resulting
    // new scan chain length is returned via full_dr_scan_length_in_bits_ptr.
    // Parameters:
    //    device_index - [0 - ...] the device's position in the list of devices
    //            on the scan chain, 0 = the device closest to TDI
    //    this_device_scan_chain[] - scan chain bits to be sent to device_index
    //            device
    //    this_device_length_in_bits - number of bits in this_device_scan_chain
    //    full_dr_scan_chain[] - scan chain produced by putting bypass bits and
    //       this_device_scan_chain bit together in the correct order
    // Returns : new_dr_chain_length_in_bits - the number of bits put into
    //    full_dr_scan_chain[] or 0 if one of the parameters is invalid.
    //    Call ErrorText() for details


    public native boolean CutDRScanChain(int   device_index,
                                      byte  origional_dr_scan_chain[],
                                      int   start_at_bit,
                                      int   copy_this_many_bits,
                                      byte  new_scan_chain[]);

    // Removes a subchain from the origional_dr_scan_chain. This function
    // assumes that the origional dr scan chain was scaned from the device
    // with all devices but the one specified by device_index in bypass mode.
    // start_at_bit is offset by the number of bypass bits that preceed the
    // start of this device's scan chain. The resulting subchain is written
    // into new_scan_chain[]
    // Parameters:
    // device_index - [0 - ...] the device's position in the list of devices
    //        on the scan chain, 0 = the device closest to TDI
    // origional_dr_scan_chain[] - full length scan chain containing both
    //     this cpu's scan bits and bypass bits from other cpus in the scan
    //     chain
    //  start_at_bit - [0 - ...] first bit in this CPU's IR scan chain to
    //        copy into new_scan_chain
    //  copy_this_many_bits	- [ - ...] number of bits to copy
    //  new_scan_chain - pointer to array into which the specified subset of
    //        origional_ir_scan_chain will be written
    // Returns : true - command succeeded
    //           false - invalid parameter call ErrorText() for
    //                   more details



 public native boolean BdmShift( String bdm_mode,
                             int    length_in_bits,
                             byte   out_data[],
                             byte   in_data[]);

 // Does a Motorola BDM style shift to the target
 // Parameters:
 //   bdm_mode ["ReadOnly","WriteOnly","ReadWrite","FastDownload","ResetHalt",
 //           "CFWriteOnly","CFReadWrite","CFSync"] - type of bdm
 //          operation to perform
 //   length_in_bits [1 - ...] - number of bits in scan chain contained in
 //           in_data and/or out_data
 //   out_data[] - array of bytes containing the data to be
 //           output via bdm
 //   in_data[] -array of bytes which will contain the data
 //           to be read via bdm

 public native String ErrorText();

 // Returns error text generated by the most recient Jtagio command
 // or "" if command succeeded.

  static
 {
		try {
			System.load("C:/Program Files (x86)/Macraigor Systems/JTAG Commander/jtag_usb2.dll");
			System.load("C:/Program Files (x86)/Macraigor Systems/JTAG Commander/MacraigorJtagio.dll");
		} catch (UnsatisfiedLinkError e) {
			System.err.println("Native code library failed to load.\n" + e);
			System.exit(1);
		}
   }


 
} // JTAGIOCLASS
