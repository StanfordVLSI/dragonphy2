# Contributing to DragonPHY

## Using pull requests

We use pull requests (PRs) to manage updates to the code base, and block merging of PRs unless automated tests pass (they're stored in the **dragonphy/tests** subdirectory).  Here are the steps to go through to use this system.
1. Make sure that you're up-to-date with the latest changes from the **master** branch:
```shell
> git pull origin master
```
2. Create a new branch to store your work, and change to that branch.  The name of the branch should give some brief indictation of the feature that you're working on.  For example, you might call the branch **new_sampler** if it mainly represents an upgrade to the sampler design.
```shell
> git checkout -b NAME_OF_YOUR_BRANCH
```
3. Make changes to the code and commit them.
```shell
<make changes to code>
> git commit -am "description of changes"
```
4. Push code back to GitHub:
```shell
> git push origin NAME_OF_YOUR_BRANCH
```
5. Go to the [dragonphy GitHub page](https://github.com/StanfordVLSI/dragonphy).
6. Click Pull Requests -> New Pull Request.
7. Make sure "base" is at **master** and set **compare** to the name of your branch.
8. Add a title and description of your pull request and click "Create Pull Request".
  * If the tests pass, then you should be able to click a button at the bottom of the page to merge the pull request.  At that point it is safe to click the button that deletes the branch you created, since the changes have been merged into the **master** branch.
  * If the tests don't pass, then modify the code and push it to your branch.  The checks will automatically be re-run and the pull request will be updated with the build status.  In other words,
```shell
<make changes to code>
> git commit -am "description of changes"
> git push origin NAME_OF_YOUR_BRANCH
```
10. Now that the changes are merged, switch back to the **master** branch and pull the changes on you machine.
```shell
> git checkout master
> git pull origin master
```

## Top-level directories
1. Common Python code should be placed in the **dragonphy/dragonphy** subdirectory.  Code placed here will be accessible to other scripts by importing the **dragonphy** module.  Scripts intended to be run directly should be placed in the **dragonphy/scripts** directory.
2. The receiver design should go in the **dragonphy/src** subdirectory.  This will mostly consist of Verilog code.
3. Verification sources should go in the **dragonphy/verif** subdirectory.  This includes things like TX stimulus, channel model, and various testbenches.
4. Tests that should be automatically run on GitHub commits should be placed in the **dragonphy/tests** directory.  Since **pytest** is used to run the tests, each script name should start with **test_**, and the scripts should define one or more functions whose names start with **test_** (each such function will be run as a separate test by **pytest**).

## Block-level directories
1. Each directory in **dragonphy/src** and **dragonphy/verif** represents the source code for a particular block, such as an RX sampler, feedforward equalizer, or a lossy channel model.  However, there will likely be multiple views for each block; each view should go in its own subdirectory, with the name of the subdirectory indicating its purpose.  For example, 
2. Here is a list of the standard subdirectory names (feel free to add to it):
    1. **struct**: Structural Verilog.  Does not need to be synthesized prior to PnR.  Could be either hand-written or automatically generated as a synthesis product.  If it's automatically generated, please do not check it into the repository.
    2. **syn**: Synthesizable Verilog.  Needs to be synthesized prior to PnR.
    3. **beh**: Behavioral model for CPU simulation.  Not intended to be synthesized.
    4. **fpga**: Synthesizable model for FPGA emulation.
    5. **spice**: Spice netlist.  Could be either hand-written or automatically generated.  If it's automatically generated, please do not check it into the repository.
    6. **layout**: Analog layout for a cell.

## Other guidelines
1. Please do not commit any process-specific designs or information.  This is very important!
2. Also, please do not commit outputs from generators.  This clutters the repository and makes it harder to figure out what are the actual design sources vs. intermediate results.
3. Please make sure that tests added to the **tests** folder do not take an excessive amount of time.  We want to make sure that pull requests can be verified in a reasonable amount of time.

## Example file layout

Consider the sample file layout below as an example of the guidelines above.  This is just an example to illustrate the file layout scheme described above.
```shell
dragonphy
├── __init__.py
├── common.py
scripts
├── gen_ffe.py
src
├── ffe
│   └── syn
│       └── ffe.sv
│   └── struct
│       └── ffe.sv
├── pi
│   └── struct
│       └── pi.sv
│   └── beh
│       └── pi.sv
│   └── fpga
│       └── pi.sv
tests
├── test_ffe.py
├── test_chan.py
verif
├── chan
│   └── beh
│       └── chan.sv
│   └── fpga
│       └── chan.sv
```
Notes:
1. Common Python files are stored in **dragonphy/dragonphy/common.py**.  These functions can then be imported from user code via a statement like `from dragonphy.common import NAME_OF_FUNC`.
2. A script to generate the **syn** view of the **ffe** block is stored in **dragonphy/scripts/gen_ffe.py**.  Note that since **src/ffe/syn/chan.sv** is generated, it should not be checked into the repository.
3. The structural Verilog view of the FFE implementation is generated by running synthesis on **dragonphy/src/ffe/syn/ffe.sv**, and the results are placed in **dragonphy/src/ffe/struct/ffe.sv**.  Since the structural Verilog is generated, it should not be checked in, but the synthesis script or framework should be.
4. The structural Verilog view of the phase interpolator is stored in **dragonphy/src/pi/struct/pi.sv**.  Unlike the **ffe** case, this might be a hand-written file containing instantiations of unit cells.
5. A behavioral model for the phase interpolator, intended for CPU simulation, is located in **dragonphy/src/pi/beh/pi.sv**.  This may be hand-written or generated (perhaps using **DaVE**).
6. A synthesizable behavioral model for the phase interpolator, intended for FPGA emulation, is located in **dragonphy/src/pi/fpga/pi.sv**.  This may be hand-written or generated (perhaps using **msdsl**).
7. Test scripts that should be automatically run upon git pushes/pull-requests are stored in the **dragonphy/tests** directory.  In this case, there are block-level tests for the FFE and for the channel model.
8. A behavioral model for the channel, intended for CPU simulation, is stored in the **dragonphy/verif/chan/beh/chan.sv** folder.  Note that this goes in the **verif** folder since it is not part of the design that is going to be taped out (i.e., the channel is outside of the RX chip).
9. A synthesizable model for the channel, intended for FPGA emulation, is stored in **dragonphy/verif/chan/fpga/chan.sv**.  This will likely be generated through a framework like **msdsl**.


