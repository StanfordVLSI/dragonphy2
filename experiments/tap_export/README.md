1. Launch Synplify Premier:
```shell
> module load base synplify
> synplify_premier
```
2. Import ``tap_core.v`` and ``tap_constr.sdc`` with the ``File`` → ``Build Project`` dialog.
3. Open compile options with ``Options`` → ``Configure Verilog Compiler``
4. Go to the ``Verilog`` tab if it is not already open.
5. Check box for ``Use DesignWare Foundation Library``
6. Set the ``Design Compiler Install Location``.  This should be the Synopsys folder that has subfolders ``dw``, ``doc``, ``libraries``, etc.  A typical location is ``/cad/synopsys/syn/P-2019.03``.
7. Go to the ``Device`` tab and set the FPGA technology / part / package / speed.  For ZCU106, the exact part is not available, but you can try picking something similar like ``Xilinx Zynq UltraScale+ FPGAs`` → ``XCZU6EG`` → ``FFVB1156``  → ``-2-i-EVAL``.
8. Compile with ``Run`` → ``Run``.  This should take 1-2 minutes.
9. The EDIF file will be located at ``rev_1/tap_core.edf``.
