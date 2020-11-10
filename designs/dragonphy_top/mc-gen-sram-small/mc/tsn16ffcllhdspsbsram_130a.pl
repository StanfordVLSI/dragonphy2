#! /usr/bin/perl
#######################################################
#
# File    : tsn16ffcllhdspsram_130a.pl
# Author  : TSMC    
# Func.   : Generate the SRAM instances for memory compiler in batch mode
# Version : 130a  Date : 03/29/2018
# Usage   : tsn16ffcllhdspsram_130a.pl [-h] [-NonTsmcName] [-file <cfgfile>] [-sd <sram_delay>] [-GND] [-SVT] [-NonBus] [-NonSD] [-NonDSLP] [-NonSLP] [-NonBWEB] [-ColRed] [-NonBIST] [-DualRail] [-DATASHEET] [-VERILOG] [-NLDM] [-LEF] [-SPICE] [-GDSII] [-DFT] [-CCS] [-ECSM] [-MasisWrapper] [-MasisMemory] [-PVT] [-LISTPVT]
#
#######################################################
use POSIX;
### Compiler type setting ####################################################
$compType = "spsbsram";
$bitcell = "c";
if($compType eq "1prf")
{
    $compNo = "5";
}
elsif($compType eq "uhd1prf")
{
    $compNo = "7";
}
elsif($compType eq "spsbsram")
{
    $compNo = "1";
}
elsif($compType eq "uhd2prf")
{
    $compNo = "6";
    $bitcell = "b";
}
elsif($compType eq "rom")
{
    $compNo = "3";
}
# [-GenROMCode] for ROM
# [-NonDSLP] [-NonSLP] [-NonBWEB] [-ColRed] for others
### Default Values Setting ####################################################
$tsmc_name="yes";
$sd=0.001;
$tsmc_develop_mode = "no";
$doCode="no";
### -h, -nontsmcname, -sd, -file, -GenRomCode can't put in config file
sub Default_Value
{
    $config="config.txt";
    $gencfgonly="no";
    $gnd="VSS";
    $vdd="VDD";
    $BIST_Enable="yes";
    $SLP_Enable="yes";
    $SD_Enable="yes";
    $DSLP_Enable="yes";
    $BWEB_Enable="yes";
    if($compType eq "rom")
    {
        $SLP_Enable="no";
        $DSLP_Enable="no";
        $BWEB_Enable="no";
    }
    $DualRail_Enable="no";
    $Bus_Delimiter="[";
    $Periphery_Vt="LVT";
    $Top_Metal="Mxd_h";
    $CCS_Enable="yes";
    $ECSM_Enable="yes";
    $Write_Assist_Enable = "yes";
    $masis_tielevel = "TestBench";
    $ColRed_Enable = "no";
    ###############################################################################
    $library = "tsn16ffcllhd".$compType;
    $fullver="20131200_130a";
    $version="130a";
    #############################
    $del_folder     = 0;
    $GDSII         = "true";
    $SPICE         = "true";
    $LEF         = "true";
    $DATASHEET     = "true";
    $NLDM         = "true";
    $VERILOG     = "true";
    $DFT         = "true";
    $CCS         = "true";
    $ECSM         = "true";
    #############################
    $get_wrapper   = 0 ;
    $get_memory    = 0 ;
    #############################
    $get_svt_option = 0 ;
    $get_lvt_option = 0 ;
    $pickPVT = 0;
}
## MODE PVT setting ########################
##//BEGIN_OF_PVT_GEN_SR_NAME//    
my @sr_pvt = ( "",
"ssgnp0p765vm40c",
"ssgnp0p765v0c",
"ssgnp0p765v125c",
"tt0p85v25c",
"tt0p85v85c",
"tt0p85vm10c",
"tt0p85v110c",
"ffgnp0p935vm40c",
"ffgnp0p935v0c",
"ffgnp0p935v125c",
"ffg0p935v125c",
"ssgnp0p675vm40c",
"ssgnp0p675v0c",
"ssgnp0p675v125c",
"ssgnp0p675v150c",
"tt0p75v25c",
"tt0p75v85c",
"tt0p75vm10c",
"tt0p75v110c",
"ffgnp0p825vm40c",
"ffgnp0p825v0c",
"ffgnp0p825v125c",
"ffgnp0p825v150c",
"ffg0p825v125c",
"ssgnp0p72vm40c",
"ssgnp0p72v0c",
"ssgnp0p72v125c",
"ssgnp0p72v150c",
"tt0p8v25c",
"tt0p8v85c",
"tt0p8vm10c",
"tt0p8v110c",
"ffgnp0p88vm40c",
"ffgnp0p88v0c",
"ffgnp0p88v125c",
"ffgnp0p88v150c",
"ffg0p88v125c",
"ssgnp0p9vm40c",
"ssgnp0p9v0c",
"ssgnp0p9v125c",
"ssgnp0p9v150c",
"tt1v25c",
"tt1v85c",
"tt1vm10c",
"tt1v110c",
"ffgnp1p05vm40c",
"ffgnp1p05v0c",
"ffgnp1p05v85c",
"ffgnp1p05v125c",
"ffgnp1p05v150c",
"ffg1p05v125c",
"ssgnp0p81vm40c",
"ssgnp0p81v0c",
"ssgnp0p81v125c",
"ssgnp0p81v150c",
"tt0p9v25c",
"tt0p9v85c",
"tt0p9vm10c",
"tt0p9v110c",
"ffgnp0p99vm40c",
"ffgnp0p99v0c",
"ffgnp0p99v125c",
"ffgnp0p99v150c",
"ffg0p99v125c",
"ssgnp0p855vm40c",
"ssgnp0p855v0c",
"ssgnp0p855v125c",
"tt0p95v25c",
"tt0p95v85c",
"tt0p95vm10c",
"tt0p95v110c",
"ffgnp1p045vm40c",
"ffgnp1p045v0c",
"ffgnp1p045v125c",
"ffg1p045v125c",
);
my $sr_worst_pvt = "ffg1p05v125c";
##//END_OF_PVT_GEN_SR_NAME//    
##//BEGIN_OF_PVT_GEN_DR_NAME//   
my @dr_pvt = ( "",
"ssgnp0p765v0p765vm40c",
"ssgnp0p765v0p765v0c",
"ssgnp0p765v0p765v125c",
"tt0p85v0p85v25c",
"tt0p85v0p85v85c",
"tt0p85v0p85vm10c",
"tt0p85v0p85v110c",
"ffgnp0p935v0p935vm40c",
"ffgnp0p935v0p935v0c",
"ffgnp0p935v0p935v125c",
"ffg0p935v0p935v125c",
"ssgnp0p72v0p765vm40c",
"ssgnp0p72v0p765v0c",
"ssgnp0p72v0p765v125c",
"ssgnp0p72v0p765v150c",
"tt0p8v0p85v25c",
"tt0p8v0p85v85c",
"tt0p8v0p85vm10c",
"tt0p8v0p85v110c",
"ffgnp0p88v0p935vm40c",
"ffgnp0p88v0p935v0c",
"ffgnp0p88v0p935v125c",
"ffgnp0p88v0p935v150c",
"ffg0p88v0p935v125c",
"ssgnp0p63v0p765vm40c",
"ssgnp0p63v0p765v0c",
"ssgnp0p63v0p765v125c",
"tt0p7v0p85v25c",
"tt0p7v0p85v85c",
"tt0p7v0p85vm10c",
"tt0p7v0p85v110c",
"ffgnp0p77v0p935vm40c",
"ffgnp0p77v0p935v0c",
"ffgnp0p77v0p935v125c",
"ffg0p77v0p935v125c",
"ssgnp0p54v0p765vm40c",
"ssgnp0p54v0p765v0c",
"ssgnp0p54v0p765v125c",
"tt0p6v0p85v25c",
"tt0p6v0p85v85c",
"tt0p6v0p85vm10c",
"tt0p6v0p85v110c",
"ffgnp0p66v0p935vm40c",
"ffgnp0p66v0p935v0c",
"ffgnp0p66v0p935v125c",
"ffg0p66v0p935v125c",
"ssgnp0p72v0p72vm40c",
"ssgnp0p72v0p72v0c",
"ssgnp0p72v0p72v125c",
"ssgnp0p72v0p72v150c",
"tt0p8v0p8v25c",
"tt0p8v0p8v85c",
"tt0p8v0p8vm10c",
"tt0p8v0p8v110c",
"ffgnp0p88v0p88vm40c",
"ffgnp0p88v0p88v0c",
"ffgnp0p88v0p88v125c",
"ffgnp0p88v0p88v150c",
"ffg0p88v0p88v125c",
"ssgnp0p63v0p72vm40c",
"ssgnp0p63v0p72v0c",
"ssgnp0p63v0p72v125c",
"tt0p7v0p8v25c",
"tt0p7v0p8v85c",
"tt0p7v0p8vm10c",
"tt0p7v0p8v110c",
"ffgnp0p77v0p88vm40c",
"ffgnp0p77v0p88v0c",
"ffgnp0p77v0p88v125c",
"ffg0p77v0p88v125c",
"ssgnp0p54v0p72vm40c",
"ssgnp0p54v0p72v0c",
"ssgnp0p54v0p72v125c",
"tt0p6v0p8v25c",
"tt0p6v0p8v85c",
"tt0p6v0p8vm10c",
"tt0p6v0p8v110c",
"ffgnp0p66v0p88vm40c",
"ffgnp0p66v0p88v0c",
"ffgnp0p66v0p88v125c",
"ffg0p66v0p88v125c",
"ssgnp0p675v0p675vm40c",
"ssgnp0p675v0p675v0c",
"ssgnp0p675v0p675v125c",
"ssgnp0p675v0p675v150c",
"tt0p75v0p75v25c",
"tt0p75v0p75v85c",
"tt0p75v0p75vm10c",
"tt0p75v0p75v110c",
"ffgnp0p825v0p825vm40c",
"ffgnp0p825v0p825v0c",
"ffgnp0p825v0p825v125c",
"ffgnp0p825v0p825v150c",
"ffg0p825v0p825v125c",
"ssgnp0p63v0p675vm40c",
"ssgnp0p63v0p675v0c",
"ssgnp0p63v0p675v125c",
"tt0p7v0p75v25c",
"tt0p7v0p75v85c",
"tt0p7v0p75vm10c",
"tt0p7v0p75v110c",
"ffgnp0p77v0p825vm40c",
"ffgnp0p77v0p825v0c",
"ffgnp0p77v0p825v125c",
"ffg0p77v0p825v125c",
"ssgnp0p54v0p675vm40c",
"ssgnp0p54v0p675v0c",
"ssgnp0p54v0p675v125c",
"tt0p6v0p75v25c",
"tt0p6v0p75v85c",
"tt0p6v0p75vm10c",
"tt0p6v0p75v110c",
"ffgnp0p66v0p825vm40c",
"ffgnp0p66v0p825v0c",
"ffgnp0p66v0p825v125c",
"ffg0p66v0p825v125c",
"ssgnp0p5v0p675vm40c",
"ssgnp0p5v0p675v0c",
"ssgnp0p5v0p675v125c",
"ssgnp0p5v0p675v150c",
"tt0p55v0p75v25c",
"tt0p55v0p75v85c",
"tt0p55v0p75vm10c",
"tt0p55v0p75v110c",
"ffgnp0p6v0p825vm40c",
"ffgnp0p6v0p825v0c",
"ffgnp0p6v0p825v125c",
"ffgnp0p6v0p825v150c",
"ffg0p6v0p825v125c",
"ssgnp0p9v0p9vm40c",
"ssgnp0p9v0p9v0c",
"ssgnp0p9v0p9v125c",
"tt1v1v25c",
"tt1v1v85c",
"tt1v1vm10c",
"tt1v1v110c",
"ffgnp1p05v1p05vm40c",
"ffgnp1p05v1p05v0c",
"ffgnp1p05v1p05v85c",
"ffgnp1p05v1p05v125c",
"ffg1p05v1p05v125c",
"ssgnp0p81v0p81vm40c",
"ssgnp0p81v0p81v0c",
"ssgnp0p81v0p81v125c",
"tt0p9v0p9v25c",
"tt0p9v0p9v85c",
"tt0p9v0p9vm10c",
"tt0p9v0p9v110c",
"ffgnp0p99v0p99vm40c",
"ffgnp0p99v0p99v0c",
"ffgnp0p99v0p99v85c",
"ffgnp0p99v0p99v125c",
"ffg0p99v0p99v125c",
"ssgnp0p81v0p9vm40c",
"ssgnp0p81v0p9v0c",
"ssgnp0p81v0p9v125c",
"tt0p9v1v25c",
"tt0p9v1v85c",
"tt0p9v1vm10c",
"tt0p9v1v110c",
"ffgnp0p99v1p05vm40c",
"ffgnp0p99v1p05v0c",
"ffgnp0p99v1p05v85c",
"ffgnp0p99v1p05v125c",
"ffg0p99v1p05v125c",
"ssgnp0p855v0p855vm40c",
"ssgnp0p855v0p855v0c",
"ssgnp0p855v0p855v125c",
"tt0p95v0p95v25c",
"tt0p95v0p95v85c",
"tt0p95v0p95vm10c",
"tt0p95v0p95v110c",
"ffgnp1p045v1p045vm40c",
"ffgnp1p045v1p045v0c",
"ffgnp1p045v1p045v125c",
"ffg1p045v1p045v125c",
);
my $dr_worst_pvt = "ffg1p05v1p05v125c";
##//END_OF_PVT_GEN_DR_NAME//    
my @sr_pvt_enable = ("true") x scalar(@sr_pvt);
my @dr_pvt_enable = ("true") x scalar(@dr_pvt);
my @pvts;
### Out Side command ############################################################
&Default_Value;
if ($ARGV[0])
{
    for $i (0..$#ARGV)
    {
        if ($ARGV[$i]=~/-file/i)
        {
            $config=$ARGV[$i+1];
            unless (-e $config) { die"\n[Error] Can not find the file $config\n\n"; }
        }
    }

    $out_command = &command_set(@ARGV);
    if($out_command == 1 and $tsmc_develop_mode eq "yes")
    {
        die "Can't use option which is not -h, -NonTsmcName, -sd, -file, -GenRomCode \n";
    }
}

$cfg_command = &check_file_command();
if($tsmc_develop_mode eq "yes")
{
   $cfg_command = 0;
}

if(($cfg_command == 1) && ($out_command == 1))
{
    print "[Error] Option setting in config.txt file cannot be executed by gen perl script followed by options (e.g.  <compiler_name>.pl -NonBIST -NonSD )\n";
    exit 1;
}

### Usage checking ############################################################
sub check_option
{
    my $option = shift @_;
    my $find_op = "false";

    if ($option=~/^-h$/i) { $find_op = "true"; }
    if ($option=~/^-NonTsmcName$/i) { $find_op = "true"; }
    if ($option=~/^-PVT$/i) { $find_op = "true"; }
    if ($option=~/^-LISTPVT$/i) { $find_op = "true"; }
    if ($option=~/^-GenROMCode$/i and $compType eq "rom") { $find_op = "true"; }
    if ($option=~/^-file$/i){ $find_op = "true"; }
    if ($option=~/^-GND$/i) { $find_op = "true"; }
    if ($option=~/^-sd$/i) { $find_op = "true"; }
    if ($option=~/^-NonBIST$/i) { $find_op = "true"; }
    if ($option=~/^-NonBWEB$/i and $compType ne "rom") { $find_op = "true"; }
    if ($option=~/^-NonBus$/i) { $find_op = "true"; }
    if ($option=~/^-LVT$/i) { $find_op = "true"; }
    if ($option=~/^-SVT$/i) { $find_op = "true"; }
    if ($option=~/^-NonSD$/i) { $find_op = "true"; }
    if ($option=~/^-NonDSLP$/i and $compType ne "rom") { $find_op = "true"; }
    if ($option=~/^-NonSLP$/i and $compType ne "rom") { $find_op = "true"; }
    if ($option=~/^-ColRed$/i and $compType ne "rom") { $find_op = "true"; }
    if ($option=~/^-DualRail$/i) { $find_op = "true"; }
    if ($option=~/^-MasisWrapper$/i) { $find_op = "true"; }
    if ($option=~/^-MasisMemory$/i) { $find_op = "true"; }
#    if ($option=~/^-Mxa$/i) { $find_op = "true"; }

    if ($option=~/^-GDSII$/i) { $find_op = "true"; }
    if ($option=~/^-SPICE$/i) { $find_op = "true"; }
    if ($option=~/^-LEF$/i) { $find_op = "true"; }
    if ($option=~/^-DATASHEET$/i) { $find_op = "true"; }
    if ($option=~/^-NLDM$/i) { $find_op = "true"; }
    if ($option=~/^-VERILOG$/i) { $find_op = "true"; }
    if ($option=~/^-DFT$/i) { $find_op = "true"; }
    if ($option=~/^-CCS$/i) { $find_op = "true"; }
    if ($option=~/^-ECSM$/i) { $find_op = "true"; }
    return $find_op;
}

sub command_set
{
    my @command = @_;
    my $ibuf = 999;
    my $command_work = 0;

    if ($command[0]) {
      for($i=0;$i<scalar(@command);$i++)
      {
        if ($command[$i]=~/^-LISTPVT$/i) { &listPVT; }
        if ($command[$i]=~/-file/i || $command[$i]=~/-sd/i )
        {$ibuf = $i;}
        if($i == $ibuf || $i == $ibuf + 1)
        {}
        else
        {
            if ($command[$i]=~/\.hex$/i and $compType eq "rom") { next; }
            $op_find = &check_option($command[$i]);
            if($op_find eq "false")
            {
                print "\n";
                print "[Error] The option \"$command[$i]\" is not supported.\n";
                print "[Info] Please see \"HELP\" and key-in correct option.\n";
                print "\n";
                &help;
            }
        }
   
        if ($command[$i]=~/-h/i) { &help; }
        if ($command[$i]=~/-NonTsmcName/i) { $tsmc_name="no"; }
        if ($command[$i]=~/-file/i) {
            $config=$command[$i+1];
            unless (-e $config) { die"[Error] Can not find the file $config\n\n"; }
        }
        if ($command[$i]=~/-sd/i) { if ($command[$i+1]) { $sd=$command[$i+1]; } }
        if ($command[$i]=~/-GenROMCode/i) { $doCode="yes"; }
        ### -h, -nontsmcname, -sd, -file -GenROMCode can't put in config file
        #Don't need to set $command_work

        if ($command[$i]=~/-SVT/i) {
            $instype="ts".$compNo."n16ffcllsbsvt".$bitcell;
            $Periphery_Vt = "SVT";
            $get_svt_option = 1 ;
            $command_work = 1;
        }
        if ($command[$i]=~/-LVT/i) {
            $instype="ts".$compNo."n16ffcllsblvt".$bitcell;
            $Periphery_Vt = "LVT";
            $get_lvt_option = 1 ;
            $command_work = 1;
        }      
        if ($command[$i]=~/^-PVT$/i) { $i = &handlePVT(@command);$command_work = 1; }
        if($i == scalar(@command)) { last; }
        if ($command[$i]=~/-GND/i) {$gnd="GND";$command_work = 1;}
        if ($command[$i]=~/-NonBus/i) { $Bus_Delimiter="0"; $command_work = 1;}
        if ($command[$i]=~/-DualRail/i) { $DualRail_Enable="yes";  $command_work = 1;}
        if ($command[$i]=~/-NonSLP/i and $compType ne "rom") { $SLP_Enable="no"; $command_work = 1; }
        if ($command[$i]=~/-NonDSLP/i and $compType ne "rom") { $DSLP_Enable="no"; $command_work = 1;}
        if ($command[$i]=~/-NonSD/i) { $SD_Enable="no"; $command_work = 1; }
        if ($command[$i]=~/-NonBIST/i) { $BIST_Enable="no"; $command_work = 1; }
        if ($command[$i]=~/-NonBWEB/i and $compType ne "rom") { $BWEB_Enable="no"; $command_work = 1; }
        if ($command[$i]=~/-ColRed/i) { $ColRed_Enable="yes";$command_work = 1;}
        if ($command[$i]=~/-MasisWrapper/i)
        {
            $masis_tielevel="Wrapper";
            $get_wrapper   =1 ;
            $command_work = 1;
        }
        if ($command[$i]=~/-MasisMemory/i)
        {
            $masis_tielevel="Memory";
            $get_memory    =1 ;
            $command_work = 1;
        }       
#        if ($command[$i]=~/-Mxa/i)
#        {
#            $Top_Metal="Mxa";
#            $get_mxa    =1 ;
#            $command_work = 1;
#        }
#        if ($command[$i]=~/-Mxc/i)
#        { 
#            $Top_Metal="Mxc";
#            $get_mxc    =1 ;
#            $command_work = 1;
#        }
        
    #### del folder{ ##################################
        if($del_folder == 0)
        {
            if ($command[$i]=~/-GDSII/i) { $del_folder = 1; $command_work = 1;}
            if ($command[$i]=~/-SPICE/i) { $del_folder = 1; $command_work = 1;}
            if ($command[$i]=~/-LEF/i) { $del_folder = 1; $command_work = 1;}
            if ($command[$i]=~/-DATASHEET/i) { $del_folder = 1; $command_work = 1;}
            if ($command[$i]=~/-NLDM/i) { $del_folder = 1; $command_work = 1;}
            if ($command[$i]=~/-VERILOG/i) { $del_folder = 1; $command_work = 1;}
            if ($command[$i]=~/-DFT/i) { $del_folder = 1; $command_work = 1;}
            if ($command[$i]=~/-CCS/i) { $del_folder = 1; $command_work = 1;}
            if ($command[$i]=~/-ECSM/i) { $del_folder = 1; $command_work = 1;}
        }
   
        if($del_folder == 1)
        {
            $del_folder = 2   ;
            $GDSII = "false"  ;
            $SPICE = "false"  ;
            $LEF = "false"    ;
            $DATASHEET = "false";
            $NLDM = "false"   ;
            $VERILOG = "false";
            $DFT = "false"    ;
            $CCS = "false"    ;
            $ECSM = "false"   ;
        }
   
        if($del_folder == 2)
        {
            if ($command[$i]=~/-GDSII/i) { $GDSII = "true"; $command_work = 1;}
            if ($command[$i]=~/-SPICE/i) { $SPICE = "true"; $command_work = 1;}
            if ($command[$i]=~/-LEF/i) { $LEF = "true"; $command_work = 1;}
            if ($command[$i]=~/-DATASHEET/i) { $DATASHEET = "true"; $command_work = 1;}
            if ($command[$i]=~/-NLDM/i) { $NLDM = "true"; $command_work = 1;}
            if ($command[$i]=~/-VERILOG/i) { $VERILOG = "true"; $command_work = 1;}
            if ($command[$i]=~/-DFT/i) { $DFT = "true"; $command_work = 1;}
            if ($command[$i]=~/-CCS/i) { $CCS = "true"; $command_work = 1;}
            if ($command[$i]=~/-ECSM/i) { $ECSM = "true"; $command_work = 1;}
        }
    #### }del folder ##################################   
                          
      }
    }
   
    ########### Check the Usage #######################
    if( ($get_lvt_option eq 1)&&($get_svt_option eq 1) ){
        print "[Error] -SVT and -LVT options can not be enabled at the same time\n" ;
        exit(1) ;
    }
    if( ($get_wrapper eq 1)&&( $get_memory eq 1) ){
        print "[Error] It is not allowed to enable -MasisWrapper and -MasisMemory at the same time\n";
        exit 1;
    }
    #if( ($get_mxa eq 1)&&( $get_mxc eq 1) ){
    #    print "[Error] It is not allowed to enable -Mxa and -Mxc at the same time\n";
    #    exit 1;
    #}
    return $command_work;
}

sub handlePVT
{
    my @command = @_;
    @sr_pvt_enable = ("false") x scalar(@sr_pvt);
    @dr_pvt_enable = ("false") x scalar(@dr_pvt);

    @pvts = ();
    $pickPVT = 1;
    $j = $i+1;
    for(;$j<scalar(@command);$j++)
    {
        if ($command[$j] =~ /^-/i)
        {
            return $j-1;
        }       
        $pvt = $command[$j];
        push(@pvts, $pvt);
    }
    return $j;
}

sub listPVT
{
    print "[Info] The option -PVT only accepts the following PVT\n";
    for($i=1;$i<scalar(@sr_pvt);$i++)
    {
        print "$sr_pvt[$i]\n";
    }
    print "[Info] Total ".$#sr_pvt." for Single Rail PVT\n";
    for($i=1;$i<scalar(@dr_pvt);$i++)
    {
        print "$dr_pvt[$i]\n";
    }
    print "[Info] Total ".$#dr_pvt." for Dual Rail PVT\n";
    exit 1;
}

### -h, -nontsmcname, -sd, -file can't put in config file
sub check_file_command
{
    my $find_command = 0;
    open (IN_FILE, "<$config") or die "Can't read $config: $!\n";
    foreach $_ (<IN_FILE>)
    {
        $_ =~ s/^\s+//g;
        $_ =~ s/\s+$//g;
        if($_ =~ /^#/) {next;}
        if($_ =~ /^$/) {next;}
        my @cfg_line = split(/\s+/,$_);
        for my $i (0..$#cfg_line)
        {
            if($cfg_line[$i] =~ /^-/)
            {
                if("false" eq &check_option($cfg_line[$i]))
                {
                    print "\n";
                    print "[Error] The option \"$cfg_line[$i]\" is not supported.\n";
                    print "[Info] Please see \"HELP\" and key-in correct option.\n";
                    print "\n";
                    &help;
                }
                if ($cfg_line[$i] =~ /^-h$/i) { print "\n[Error] CFG file not support $cfg_line[$i] command\n"; exit; }
                if ($cfg_line[$i] =~ /^-LISTPVT$/i) { print "\n[Error] CFG file not support $cfg_line[$i] command\n"; exit; }
                if ($cfg_line[$i] =~ /^-NonTsmcName$/i) { print "\n[Error] CFG file not support $cfg_line[$i] command\n"; exit; }
                if ($cfg_line[$i] =~ /^-GenROMCode$/i and $compType eq "rom") { print "\n[Error] CFG file not support $cfg_line[$i] command\n"; exit; }
                if ($cfg_line[$i] =~ /^-file$/i){ print "\n[Error] CFG file not support $cfg_line[$i] command\n"; exit; }
                if ($cfg_line[$i] =~ /^-sd$/i) { print "\n[Error] CFG file not support $cfg_line[$i] command\n"; exit; }
                $find_command = 1;
            }
        }
    }
    close (IN_FILE);
    return $find_command;
}

sub checkPVT
{
    ### For -pvt option ############################################################
    if(scalar(@pvts)==0)
    {
        print "[Error] Please specify valid PVT with option -PVT\n";
        print "[Info] Use option -LISTPVT to see the valid PVT.\n";
        exit 1;
    }
    if ($DualRail_Enable eq "no")
    {
        my @erpvt = ();
        foreach $j (0..$#pvts)
        {
            $pvt = $pvts[$j];
            $found = 0;
            foreach $i (1..$#sr_pvt)
            {
                $item = $sr_pvt[$i];
                if($item eq $pvt)
                {
                    $sr_pvt_enable[$i] = "true";
                    $found = 1;
                    last;
                }           
            }
            if($found == 0)
            {
                push(@erpvt, $pvt);
            }
        }
        if(scalar(@erpvt)>0)
        {
            $erpvtline = join ", ", @erpvt;
            print "[Error] $erpvtline is(are) invalid PVT for $file_folder (Single Rail)\n";
            print "[Info] Use option -LISTPVT to see the valid PVT.\n";
            exit 1;
        }
        foreach $i (1..$#sr_pvt)
        {
            $item = $sr_pvt[$i];
            if($item eq $sr_worst_pvt)
            {
                if($sr_pvt_enable[$i] ne "true")
                {
                    $sr_pvt_enable[$i] = "true";
                    $delworst = 1;
                    $delpvt = $sr_worst_pvt;
                }
                last;
            }           
        }
    }
    else
    {
        my @erpvt = ();
        foreach $j (0..$#pvts)
        {
            $pvt = $pvts[$j];
            $found = 0;
            foreach $i (1..$#dr_pvt)
            {
                $item = $dr_pvt[$i];
                if($item eq $pvt)
                {
                    $dr_pvt_enable[$i] = "true";
                    $found = 1;
                    last;
                }           
            }
            if($found == 0)
            {
                push(@erpvt, $pvt);
            }
        }
        if(scalar(@erpvt)>0)
        {
            $erpvtline = join ", ", @erpvt;
            print "[Error] $erpvtline is(are) invalid PVT for $file_folder (Dual Rail)\n";
            print "[Info] Use option -LISTPVT to see the valid PVT.\n";
            exit 1;
        }
        foreach $i (1..$#dr_pvt)
        {
            $item = $dr_pvt[$i];
            if($item eq $dr_worst_pvt)
            {
                if($dr_pvt_enable[$i] ne "true")
                {
                    $dr_pvt_enable[$i] = "true";
                    $delworst = 1;
                    $delpvt = $dr_worst_pvt;
                }
                last;
            }           
        }
    }
}

### Config setting and checking ############################################################
open (CONFIG, "<$config") or die "Can't read $config: $!\n";
while (chomp($_=<CONFIG>)) {
    $_ =~ s/^\s+//g;
    $_ =~ s/\s+$//g;
    if($_ =~ /^#/) { next;}
    if($_ =~ /^$/) { next;}
    if ($tsmc_name =~/yes/i)
    {
        @tmp = split /\s+/,$_;
        $hex = $tmp[1];

        if($cfg_command == 1)
        {
            &Default_Value;
            $NWORD=$NBIT=$NMUX=$seg=$_;
            if($compType eq "uhd2prf" or $compType eq "rom")
            {
                /^(\d+)x(\d+)m(\d+)(\s+(.*)?)?/i;
                $NWORD = $1;
                $NBIT = $2;
                $NMUX = $3;
                $seg = "";
                $op = $5;
            }
            else
            {
                /^(\d+)x(\d+)m(\d+)([smf])(\s+(.*)?)?/i;
                $NWORD = $1;
                $NBIT = $2;
                $NMUX = $3;
                $seg = $4;
                $op = $6;
            }
            &command_set(split(/\s+/,$op));
        }
        else
        {
            $NWORD=$NBIT=$NMUX=$seg=$_;
            if($compType eq "uhd2prf" or $compType eq "rom")
            {
                /^(\d+)x(\d+)m(\d+)(\w+)?(\s+(lvt|svt|ulvt))?/i;
                $NWORD = $1;
                $NBIT = $2;
                $NMUX = $3;
                $seg = "";
                $op = $4;
                $vt = $6;
            }
            else
            {
                /^(\d+)x(\d+)m(\d+)([smf])(\w+)?(\s+(lvt|svt|ulvt))?/i;
                $NWORD = $1;
                $NBIT = $2;
                $NMUX = $3;
                $seg = $4;
                $op = $5;
                $vt = $7;
            }
            if($tsmc_develop_mode eq "yes")
            {
                $BWEB_Enable = $BIST_Enable = $SLP_Enable = $SD_Enable = $DualRail_Enable = $ColRed_Enable = $Write_Assist_Enable = $DSLP_Enable = "no";
                if($op =~ /w/i and $compType ne "rom") { $BWEB_Enable = "yes"; }
                if($op =~ /b/i) { $BIST_Enable = "yes"; }
                if($op =~ /s/i and $compType ne "rom") { $SLP_Enable = "yes"; }
                if($op =~ /h/i and $compType ne "rom") { $DSLP_Enable = "yes"; }
                if($op =~ /o/i) { $SD_Enable = "yes"; }
                if($op =~ /x/i) { $Write_Assist_Enable = "yes"; }
                if($op =~ /d/i) { $DualRail_Enable = "yes"; }
                if($op =~ /cp/i and $compType ne "rom") { $ColRed_Enable = "yes"; }

                if($vt =~ /^lvt$/i) { $Periphery_Vt="LVT";}
                if($vt =~ /^ulvt$/i) { $Periphery_Vt="ULVT";}
                if($vt =~ /^svt$/i) { $Periphery_Vt="SVT";}
            }
        }
   
        $option = "";
        if($BWEB_Enable eq 'yes')
        {    $option .= "w";}
        if($BIST_Enable eq 'yes')
        {    $option .= "b";}
        if($SLP_Enable eq 'yes')
        {  $option .= "s";}
        if($DSLP_Enable eq 'yes')
        {  $option .= "h";}
        if($SD_Enable eq 'yes')
        {  $option .= "o";}
        if($DualRail_Enable eq 'yes')
        {    $option .= "d";}
#        if($Write_Assist_Enable eq 'yes')
#        {    $option .= "x";}
        if($ColRed_Enable eq 'yes')
        {    $option .= "cp";}
       
        if ($Periphery_Vt =~ /SVT/i) {$instype="ts".$compNo."n16ffcllsbsvt".$bitcell;}
        if ($Periphery_Vt =~ /LVT/i) {$instype="ts".$compNo."n16ffcllsblvt".$bitcell;}       
        if ($Periphery_Vt =~ /ULVT/i) {$instype="ts".$compNo."n16ffcllsbulvt".$bitcell;}       
     
        $file=$instype.$NWORD."x".$NBIT."m".$NMUX.lc($seg).$option;
        $FILE="\U$file\E";           

        #print "*** NWORD=$NWORD NBIT=$NBIT NMUX=$NMUX seg=$seg\n";
        #print "*** BWEB_Enable=$BWEB_Enable BIST_Enable=$BIST_Enable SLP_Enable=$SLP_Enable DSLP_Enable=$DSLP_Enable SD_Enable=$SD_Enable DualRail_Enable=$DualRail_Enable Write_Assist_Enable=$Write_Assist_Enable\n";
        #print "*** Creating instance : $file\n";
        if($doCode=~/yes/i) {
            $codefile = "${file}_${version}.hex";
        }
        elsif ($doCode=~/no/i) {
            $codefile = $hex;
        }
    }
    else
    {
        @tmp = split /\s+/,$_;
        $hex = $tmp[4];
        if($cfg_command == 1)
        {
            &Default_Value;
            $file=$NWORD=$NBIT=$NMUX=$seg=$_;
            if($compType eq "uhd2prf" or $compType eq "rom")
            {
                /^(\S+)\s+(\d+)\s+(\d+)\s+(\d+)(\s+(.*)?)?/i;
                $file = $1;
                $NWORD = $2;
                $NBIT = $3;
                $NMUX = $4;
                $seg = "";
                $op = $6;
            }
            else
            {
                /^(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\w)(\s+(.*)?)?/i;
                $file = $1;
                $NWORD = $2;
                $NBIT = $3;
                $NMUX = $4;
                $seg = $5;
                $op = $7;
            }
            &command_set(split(/\s+/,$op));
        }
        else
        {
            if($compType eq "uhd2prf" or $compType eq "rom")
            {
                ($file,$NWORD,$NBIT,$NMUX,$op,$vt)=(split /\s+/,$_)[0,1,2,3,4,5];
                $seg = "";
            }
            else
            {
                ($file,$NWORD,$NBIT,$NMUX,$seg,$op,$vt)=(split /\s+/,$_)[0,1,2,3,4,5,6];
            }

            if($tsmc_develop_mode eq "yes")
            {
                $BWEB_Enable = $BIST_Enable = $SLP_Enable = $SD_Enable = $DualRail_Enable = $ColRed_Enable = $Write_Assist_Enable = $DSLP_Enable = "no";
                if($op =~ /w/i and $compType ne "rom") { $BWEB_Enable = "yes"; }
                if($op =~ /b/i) { $BIST_Enable = "yes"; }
                if($op =~ /s/i and $compType ne "rom") { $SLP_Enable = "yes"; }
                if($op =~ /h/i and $compType ne "rom") { $DSLP_Enable = "yes"; }
                if($op =~ /o/i) { $SD_Enable = "yes"; }
#                if($op =~ /x/i) { $Write_Assist_Enable = "yes"; }
                if($op =~ /d/i) { $DualRail_Enable = "yes"; }
                if($op =~ /cp/i and $compType ne "rom") { $ColRed_Enable = "yes"; }

                if($op =~ /^lvt$/i) { $Periphery_Vt="LVT";}
                if($op =~ /^ulvt$/i) { $Periphery_Vt="ULVT";}
                if($op =~ /^svt$/i) { $Periphery_Vt="SVT";}
                if($vt =~ /^lvt$/i) { $Periphery_Vt="LVT";}
                if($vt =~ /^ulvt$/i) { $Periphery_Vt="ULVT";}
                if($vt =~ /^svt$/i) { $Periphery_Vt="SVT";}
            }
        }

        $FILE=$file;

        $option = "";
        if($BWEB_Enable eq 'yes')
        {    $option .= "w";}
        if($BIST_Enable eq 'yes')
        {    $option .= "b";}
        if($SLP_Enable eq 'yes')
        {    $option .= "s";}
        if($DSLP_Enable eq 'yes')
        {    $option .= "h";}
        if($SD_Enable eq 'yes')
        {$option .= "o";}
        if($DualRail_Enable eq 'yes')
        {    $option .= "d";}
#        if($Write_Assist_Enable eq 'yes')
#        {    $option .= "x";}
        if($ColRed_Enable eq 'yes')
        {    $option .= "cp";}

        #print "*** NWORD=$NWORD NBIT=$NBIT NMUX=$NMUX seg=$seg\n";
        #print "*** BWEB_Enable=$BWEB_Enable BIST_Enable=$BIST_Enable SLP_Enable=$SLP_Enable DSLP_Enable=$DSLP_Enable SD_Enable=$SD_Enable DualRail_Enable=$DualRail_Enable Write_Assist_Enable=$Write_Assist_Enable\n";
        #print "*** Creating instance : $file\n";
        if($doCode=~/yes/i) {
            $codefile = "$file.hex";
        }
        elsif ($doCode=~/no/i) {
            $codefile = $hex;
        }
    }
    if($seg !~ /^s$/i )
    {
        print "[Error] Only Support small segmentation\n";
        exit 1;
    }

    $segmentation = "\U$seg\E";
    $segmentation =~ s/S/Small/;
    $segmentation =~ s/M/Medium/;
    $segmentation =~ s/F/Fast/;
    if($compType eq "uhd2prf")
    {
        $segmentation = "Small";
    }
    if($compType eq "rom")
    {
        $segmentation = "Fast";
        $seg_tag=64;     
    }
    #print "*************************************************************************************\n";
    $NWORD_error=$NBIT_error=$NMUX_error=$seg_error=$option_error=0;
    if ($NWORD eq "") {$NWORD_error =1;} elsif ($NWORD =~ /\D/) {$NWORD_error=1;}
    if ($NWORD_error==1)  {print "*** WORDDEPTH of instance is not set properly. Check file \"$config\" ***\n";}
    if ($NBIT eq "") {$NBIT_error =1;} elsif ($NBIT =~ /\D/) {$NBIT_error=1;}
    if ($NBIT_error==1)  {print "*** IO of instance is not set properly. Check file \"$config\" ***\n";}
    if ($NMUX eq "") {$NMUX_error =1;} elsif ($NMUX =~ /\D/) {$NMUX_error=1;}
    if ($NMUX_error==1)  {print "*** MUX of instance is not set properly. Check file \"$config\" ***\n";}
    if ($codefile eq "" and $compType eq "rom") {$codefile_error =1;}
    if ($codefile_error==1) {print "*** Intended rom code file is not specified, please list the rom code file in config.txt ***\n";}
    #print "*************************************************************************************\n";
    ######### 20160805 add error message alignment
    if ($NMUX == 4 || $NMUX == 8) {
    } 
    else {    
        print "[ERROR] MUX $NMUX is not supported, please check config.txt...\n";
        exit 1;
    }
    if ( $NMUX == 4 ) {
        if ( ($NWORD < 32 || $NWORD > 1024) || ( ($NWORD >= 32 || $NWORD <= 1024) && $NWORD % 16 !=0) ) {
            print "[ERROR] Word depth $NWORD must be a multiple of 16 in the range of 32 ~ 1024 for MUX4, please check config.txt...\n";
            exit 1;
        }
        if ( $NBIT < 4 || $NBIT > 144) {
            print "[ERROR] IO $NBIT must be a multiple of 1 in the range of 4 ~ 144 for MUX4, please check config.txt...\n";
            exit 1;
        }        
    }
    if ( $NMUX == 8 ) {
        if ( ($NWORD < 64 || $NWORD > 2048) || ( ($NWORD >= 64 || $NWORD <= 2048) && $NWORD % 32 !=0) ) {
            print "[ERROR] Word depth $NWORD must be a multiple of 16 in the range of 64 ~ 2048 for MUX8, please check config.txt...\n";
            exit 1;
        }
        if ( $NBIT < 4 || $NBIT > 72) {
            print "[ERROR] IO $NBIT must be a multiple of 1 in the range of 4 ~ 72 for MUX8, please check config.txt...\n";
            exit 1;
        }        
    }

    ###############################################################################
    if($compType ne "rom")
    {
        &option_error_message;
    }

    if ($tsmc_name eq "yes") {
        $file_folder = $file."_$version";
    }
    else {
        $file_folder = $file;
    }

    $delworst = 0;   #delete worst case PVT
    if($pickPVT == 1)
    {
        &checkPVT;  #execute it after setting DR/SR
    }

    ### Output parameters setting ############################################################
    open(OUT,">./".$file.".cfg");
    print OUT "\n";
    print OUT "    Compiler_Name = $library\_$fullver\n";
    print OUT "    CgS__Memory_Name = \"$FILE\"\n";
    print OUT "    CgS__Library_Name = \"$FILE\"\n";
    print OUT "    CgS__Tiler_Option = TILER_PINMAP\n";
    print OUT "    CgB__Netlist_Enabled = true\n";
    print OUT "    CgB__Run_Make = false\n";
    print OUT "    CoB__LEF_Case_Sensitive = true\n";
    print OUT "    CpS__GND_Pin_Custom_Name = $gnd\n";
    print OUT "    CpS__VDD_Pin_Custom_Name = $vdd\n"; 
    print OUT "\n";
 
    print OUT "    NWORD = $NWORD\n";
    print OUT "    NBIT = $NBIT\n";
    print OUT "    NMUX = $NMUX\n";   
    print OUT "    Segmentation = \"$segmentation\"\n";
    print OUT "    SRAM_Delay = $sd\n";
    print OUT "    Periphery_Vt = \"$Periphery_Vt\"\n";
    print OUT "    Top_Metal = \"$Top_Metal\"\n";
    print OUT "\n";

    print OUT "    Bus_Delimiter = \"$Bus_Delimiter\"\n";
    print OUT "    BIST_Enable = \"$BIST_Enable\"\n";
    print OUT "    AWT_Enable = \"no\"\n";
    print OUT "    BWEB_Enable = \"$BWEB_Enable\"\n";
    print OUT "    SLP_Enable = \"$SLP_Enable\"\n";
    print OUT "    DSLP_Enable = \"$DSLP_Enable\"\n";
    print OUT "    SD_Enable = \"$SD_Enable\"\n";
    print OUT "    Dual_Rail_Enable = \"$DualRail_Enable\"\n";
    print OUT "    ColRed_Enable = \"$ColRed_Enable\"\n";
    print OUT "    CCS_Enable = \"$CCS_Enable\"\n";
    print OUT "    ECSM_Enable = \"$ECSM_Enable\"\n";  
    print OUT "    Write_Assist_Enable = \"$Write_Assist_Enable\"\n";
    print OUT "    MASIS_Tielevel = \"$masis_tielevel\"\n";  
    print OUT "    RowRed_Enable = \"no\"\n";  
    print OUT "    TM1_Mode = \"no\"\n";  
    print OUT "    TM2_Mode = \"no\"\n";  
#    print OUT "    GL_LL = \"LL\"\n";
#    print OUT "    IS_MIV = 0\n";
    if($compType eq "rom")
    {
    print OUT "    MixVt_Enable = \"no\"\n";
    print OUT "    TP_Enable = \"yes\"\n";
    print OUT "    CrmS__ROM_Content_File = \"$codefile\"\n";
    print OUT "    CrmB__ROM_MSB_LSB_Order = false\n";
    }
    print OUT "\n";
 
    if ($tsmc_name eq "yes")
    {
        print OUT "    Use_TSMC_Naming = \"true\"\n";
    }
    else
    {
        print OUT "    Use_TSMC_Naming = \"false\"\n";
    }
    print OUT "    CfS__Output_Directory = \"".$file_folder."\"\n";
    print OUT "\n";

##//BEGIN_OF_MODEL_GEN// 
    print OUT "    CmS__Model_Enabled0 = true\n"; #Text DataSheet
    print OUT "    CmS__Model_Enabled1 = true\n"; #Antenna LEF
    print OUT "    CmS__Model_Enabled2 = true\n"; #Verilog
    print OUT "    CmS__Model_Enabled3 = true\n"; #Power-aware Verilog
    print OUT "    CmS__Model_Enabled4 = false\n"; #Synthesizable Verilog
    print OUT "    CmS__Model_Enabled5 = true\n"; #FPGA Verilog
    print OUT "    CmS__Model_Enabled6 = false\n"; #STUB Verilog
    print OUT "    CmS__Model_Enabled7 = true\n"; #Tetramax ATPG Model
    print OUT "    CmS__Model_Enabled8 = true\n"; #Synopsys MASIS
if( $SWT_Enable eq "yes")
{
    print OUT "    CmS__Model_Enabled9 = false\n"; #DFT CTL
}
    print OUT "    CmS__Model_Enabled10 = false\n"; #REDHAWK AVM
    print OUT "    CmS__Model_Enabled11 = true\n"; #NLDM
    print OUT "    CmS__Model_Enabled12 = true\n"; #Synopsys CCS
    print OUT "    CmS__Model_Enabled13 = true\n"; #Cadence ECSM
    print OUT "    CmS__Model_Enabled14 = true\n"; #Fastscan
    print OUT "    CmS__Model_Enabled15 = true\n"; #LogicV
##//END_OF_MODEL_GEN//
  print OUT "\n";

    if ($DualRail_Enable eq "no")
    {
##//BEGIN_OF_PVT_GEN_SR//   
	print OUT "	CmB__Expand_Model_Custom1 = $sr_pvt_enable[1]\n"; #SSGNPG_0.765_0.765_-40             
	print OUT "	CmB__Expand_Model_Custom2 = $sr_pvt_enable[2]\n"; #SSGNPG_0.765_0.765_0               
	print OUT "	CmB__Expand_Model_Custom3 = $sr_pvt_enable[3]\n"; #SSGNPG_0.765_0.765_125             
	print OUT "	CmB__Expand_Model_Custom4 = $sr_pvt_enable[4]\n"; #TT_0.85_0.85_25                    
	print OUT "	CmB__Expand_Model_Custom5 = $sr_pvt_enable[5]\n"; #TT_0.85_0.85_85                    
	print OUT "	CmB__Expand_Model_Custom6 = $sr_pvt_enable[6]\n"; #TT_0.85_0.85_-10                   
	print OUT "	CmB__Expand_Model_Custom7 = $sr_pvt_enable[7]\n"; #TT_0.85_0.85_110                   
	print OUT "	CmB__Expand_Model_Custom8 = $sr_pvt_enable[8]\n"; #FFGNPG_0.935_0.935_-40             
	print OUT "	CmB__Expand_Model_Custom9 = $sr_pvt_enable[9]\n"; #FFGNPG_0.935_0.935_0               
	print OUT "	CmB__Expand_Model_Custom10 = $sr_pvt_enable[10]\n"; #FFGNPG_0.935_0.935_125             ;
	print OUT "	CmB__Expand_Model_Custom11 = $sr_pvt_enable[11]\n"; #FFG_0.935_0.935_125                ;
	print OUT "	CmB__Expand_Model_Custom12 = $sr_pvt_enable[12]\n"; #SSGNPG_0.675_0.675_-40             ;
	print OUT "	CmB__Expand_Model_Custom13 = $sr_pvt_enable[13]\n"; #SSGNPG_0.675_0.675_0               ;
	print OUT "	CmB__Expand_Model_Custom14 = $sr_pvt_enable[14]\n"; #SSGNPG_0.675_0.675_125             ;
	print OUT "	CmB__Expand_Model_Custom15 = $sr_pvt_enable[15]\n"; #SSGNPG_0.675_0.675_150             ;
	print OUT "	CmB__Expand_Model_Custom16 = $sr_pvt_enable[16]\n"; #TT_0.75_0.75_25                    ;
	print OUT "	CmB__Expand_Model_Custom17 = $sr_pvt_enable[17]\n"; #TT_0.75_0.75_85                    ;
	print OUT "	CmB__Expand_Model_Custom18 = $sr_pvt_enable[18]\n"; #TT_0.75_0.75_-10                   ;
	print OUT "	CmB__Expand_Model_Custom19 = $sr_pvt_enable[19]\n"; #TT_0.75_0.75_110                   ;
	print OUT "	CmB__Expand_Model_Custom20 = $sr_pvt_enable[20]\n"; #FFGNPG_0.825_0.825_-40             ;
	print OUT "	CmB__Expand_Model_Custom21 = $sr_pvt_enable[21]\n"; #FFGNPG_0.825_0.825_0               ;
	print OUT "	CmB__Expand_Model_Custom22 = $sr_pvt_enable[22]\n"; #FFGNPG_0.825_0.825_125             ;
	print OUT "	CmB__Expand_Model_Custom23 = $sr_pvt_enable[23]\n"; #FFGNPG_0.825_0.825_150             ;
	print OUT "	CmB__Expand_Model_Custom24 = $sr_pvt_enable[24]\n"; #FFG_0.825_0.825_125                ;
	print OUT "	CmB__Expand_Model_Custom25 = $sr_pvt_enable[25]\n"; #SSGNPG_0.72_0.72_-40               ;
	print OUT "	CmB__Expand_Model_Custom26 = $sr_pvt_enable[26]\n"; #SSGNPG_0.72_0.72_0                 ;
	print OUT "	CmB__Expand_Model_Custom27 = $sr_pvt_enable[27]\n"; #SSGNPG_0.72_0.72_125               ;
	print OUT "	CmB__Expand_Model_Custom28 = $sr_pvt_enable[28]\n"; #SSGNPG_0.72_0.72_150               ;
	print OUT "	CmB__Expand_Model_Custom29 = $sr_pvt_enable[29]\n"; #TT_0.8_0.8_25                      ;
	print OUT "	CmB__Expand_Model_Custom30 = $sr_pvt_enable[30]\n"; #TT_0.8_0.8_85                      ;
	print OUT "	CmB__Expand_Model_Custom31 = $sr_pvt_enable[31]\n"; #TT_0.8_0.8_-10                     ;
	print OUT "	CmB__Expand_Model_Custom32 = $sr_pvt_enable[32]\n"; #TT_0.8_0.8_110                     ;
	print OUT "	CmB__Expand_Model_Custom33 = $sr_pvt_enable[33]\n"; #FFGNPG_0.88_0.88_-40               ;
	print OUT "	CmB__Expand_Model_Custom34 = $sr_pvt_enable[34]\n"; #FFGNPG_0.88_0.88_0                 ;
	print OUT "	CmB__Expand_Model_Custom35 = $sr_pvt_enable[35]\n"; #FFGNPG_0.88_0.88_125               ;
	print OUT "	CmB__Expand_Model_Custom36 = $sr_pvt_enable[36]\n"; #FFGNPG_0.88_0.88_150               ;
	print OUT "	CmB__Expand_Model_Custom37 = $sr_pvt_enable[37]\n"; #FFG_0.88_0.88_125                  ;
	print OUT "	CmB__Expand_Model_Custom38 = $sr_pvt_enable[38]\n"; #SSGNPG_0.9_0.9_-40                 ;
	print OUT "	CmB__Expand_Model_Custom39 = $sr_pvt_enable[39]\n"; #SSGNPG_0.9_0.9_0                   ;
	print OUT "	CmB__Expand_Model_Custom40 = $sr_pvt_enable[40]\n"; #SSGNPG_0.9_0.9_125                 ;
	print OUT "	CmB__Expand_Model_Custom41 = $sr_pvt_enable[41]\n"; #SSGNPG_0.9_0.9_150                 ;
	print OUT "	CmB__Expand_Model_Custom42 = $sr_pvt_enable[42]\n"; #TT_1_1_25                          ;
	print OUT "	CmB__Expand_Model_Custom43 = $sr_pvt_enable[43]\n"; #TT_1_1_85                          ;
	print OUT "	CmB__Expand_Model_Custom44 = $sr_pvt_enable[44]\n"; #TT_1_1_-10                         ;
	print OUT "	CmB__Expand_Model_Custom45 = $sr_pvt_enable[45]\n"; #TT_1_1_110                         ;
	print OUT "	CmB__Expand_Model_Custom46 = $sr_pvt_enable[46]\n"; #FFGNPG_1.05_1.05_-40               ;
	print OUT "	CmB__Expand_Model_Custom47 = $sr_pvt_enable[47]\n"; #FFGNPG_1.05_1.05_0                 ;
	print OUT "	CmB__Expand_Model_Custom48 = $sr_pvt_enable[48]\n"; #FFGNPG_1.05_1.05_85                ;
	print OUT "	CmB__Expand_Model_Custom49 = $sr_pvt_enable[49]\n"; #FFGNPG_1.05_1.05_125               ;
	print OUT "	CmB__Expand_Model_Custom50 = $sr_pvt_enable[50]\n"; #FFGNPG_1.05_1.05_150               ;
	print OUT "	CmB__Expand_Model_Custom51 = $sr_pvt_enable[51]\n"; #FFG_1.05_1.05_125                  ;
	print OUT "	CmB__Expand_Model_Custom52 = $sr_pvt_enable[52]\n"; #SSGNPG_0.81_0.81_-40               ;
	print OUT "	CmB__Expand_Model_Custom53 = $sr_pvt_enable[53]\n"; #SSGNPG_0.81_0.81_0                 ;
	print OUT "	CmB__Expand_Model_Custom54 = $sr_pvt_enable[54]\n"; #SSGNPG_0.81_0.81_125               ;
	print OUT "	CmB__Expand_Model_Custom55 = $sr_pvt_enable[55]\n"; #SSGNPG_0.81_0.81_150               ;
	print OUT "	CmB__Expand_Model_Custom56 = $sr_pvt_enable[56]\n"; #TT_0.9_0.9_25                      ;
	print OUT "	CmB__Expand_Model_Custom57 = $sr_pvt_enable[57]\n"; #TT_0.9_0.9_85                      ;
	print OUT "	CmB__Expand_Model_Custom58 = $sr_pvt_enable[58]\n"; #TT_0.9_0.9_-10                     ;
	print OUT "	CmB__Expand_Model_Custom59 = $sr_pvt_enable[59]\n"; #TT_0.9_0.9_110                     ;
	print OUT "	CmB__Expand_Model_Custom60 = $sr_pvt_enable[60]\n"; #FFGNPG_0.99_0.99_-40               ;
	print OUT "	CmB__Expand_Model_Custom61 = $sr_pvt_enable[61]\n"; #FFGNPG_0.99_0.99_0                 ;
	print OUT "	CmB__Expand_Model_Custom62 = $sr_pvt_enable[62]\n"; #FFGNPG_0.99_0.99_125               ;
	print OUT "	CmB__Expand_Model_Custom63 = $sr_pvt_enable[63]\n"; #FFGNPG_0.99_0.99_150               ;
	print OUT "	CmB__Expand_Model_Custom64 = $sr_pvt_enable[64]\n"; #FFG_0.99_0.99_125                  ;
	print OUT "	CmB__Expand_Model_Custom65 = $sr_pvt_enable[65]\n"; #SSGNPG_0.855_0.855_-40             ;
	print OUT "	CmB__Expand_Model_Custom66 = $sr_pvt_enable[66]\n"; #SSGNPG_0.855_0.855_0               ;
	print OUT "	CmB__Expand_Model_Custom67 = $sr_pvt_enable[67]\n"; #SSGNPG_0.855_0.855_125             ;
	print OUT "	CmB__Expand_Model_Custom68 = $sr_pvt_enable[68]\n"; #TT_0.95_0.95_25                    ;
	print OUT "	CmB__Expand_Model_Custom69 = $sr_pvt_enable[69]\n"; #TT_0.95_0.95_85                    ;
	print OUT "	CmB__Expand_Model_Custom70 = $sr_pvt_enable[70]\n"; #TT_0.95_0.95_-10                   ;
	print OUT "	CmB__Expand_Model_Custom71 = $sr_pvt_enable[71]\n"; #TT_0.95_0.95_110                   ;
	print OUT "	CmB__Expand_Model_Custom72 = $sr_pvt_enable[72]\n"; #FFGNPG_1.045_1.045_-40             ;
	print OUT "	CmB__Expand_Model_Custom73 = $sr_pvt_enable[73]\n"; #FFGNPG_1.045_1.045_0               ;
	print OUT "	CmB__Expand_Model_Custom74 = $sr_pvt_enable[74]\n"; #FFGNPG_1.045_1.045_125             ;
	print OUT "	CmB__Expand_Model_Custom75 = $sr_pvt_enable[75]\n"; #FFG_1.045_1.045_125                ;
##//END_OF_PVT_GEN_SR//   
    }
    else
    {
##//BEGIN_OF_PVT_GEN_DR//   
	print OUT "	CmB__Expand_Model_Custom1 = $dr_pvt_enable[1]\n";	#SSGNPG_0.765_0.765_-40   
	print OUT "	CmB__Expand_Model_Custom2 = $dr_pvt_enable[2]\n";	#SSGNPG_0.765_0.765_0
	print OUT "	CmB__Expand_Model_Custom3 = $dr_pvt_enable[3]\n";	#SSGNPG_0.765_0.765_125
	print OUT "	CmB__Expand_Model_Custom4 = $dr_pvt_enable[4]\n";	#TT_0.85_0.85_25
	print OUT "	CmB__Expand_Model_Custom5 = $dr_pvt_enable[5]\n";	#TT_0.85_0.85_85
	print OUT "	CmB__Expand_Model_Custom6 = $dr_pvt_enable[6]\n";	#TT_0.85_0.85_-10
	print OUT "	CmB__Expand_Model_Custom7 = $dr_pvt_enable[7]\n";	#TT_0.85_0.85_110
	print OUT "	CmB__Expand_Model_Custom8 = $dr_pvt_enable[8]\n";	#FFGNPG_0.935_0.935_-40
	print OUT "	CmB__Expand_Model_Custom9 = $dr_pvt_enable[9]\n";	#FFGNPG_0.935_0.935_0
	print OUT "	CmB__Expand_Model_Custom10 = $dr_pvt_enable[10]\n";	#FFGNPG_0.935_0.935_125
	print OUT "	CmB__Expand_Model_Custom11 = $dr_pvt_enable[11]\n";	#FFG_0.935_0.935_125
	print OUT "	CmB__Expand_Model_Custom12 = $dr_pvt_enable[12]\n";	#SSGNPG_0.72_0.765_-40
	print OUT "	CmB__Expand_Model_Custom13 = $dr_pvt_enable[13]\n";	#SSGNPG_0.72_0.765_0
	print OUT "	CmB__Expand_Model_Custom14 = $dr_pvt_enable[14]\n";	#SSGNPG_0.72_0.765_125
	print OUT "	CmB__Expand_Model_Custom15 = $dr_pvt_enable[15]\n";	#SSGNPG_0.72_0.765_150
	print OUT "	CmB__Expand_Model_Custom16 = $dr_pvt_enable[16]\n";	#TT_0.8_0.85_25
	print OUT "	CmB__Expand_Model_Custom17 = $dr_pvt_enable[17]\n";	#TT_0.8_0.85_85
	print OUT "	CmB__Expand_Model_Custom18 = $dr_pvt_enable[18]\n";	#TT_0.8_0.85_-10
	print OUT "	CmB__Expand_Model_Custom19 = $dr_pvt_enable[19]\n";	#TT_0.8_0.85_110
	print OUT "	CmB__Expand_Model_Custom20 = $dr_pvt_enable[20]\n";	#FFGNPG_0.88_0.935_-40
	print OUT "	CmB__Expand_Model_Custom21 = $dr_pvt_enable[21]\n";	#FFGNPG_0.88_0.935_0
	print OUT "	CmB__Expand_Model_Custom22 = $dr_pvt_enable[22]\n";	#FFGNPG_0.88_0.935_125
	print OUT "	CmB__Expand_Model_Custom23 = $dr_pvt_enable[23]\n";	#FFGNPG_0.88_0.935_150
	print OUT "	CmB__Expand_Model_Custom24 = $dr_pvt_enable[24]\n";	#FFG_0.88_0.935_125
	print OUT "	CmB__Expand_Model_Custom25 = $dr_pvt_enable[25]\n";	#SSGNPG_0.63_0.765_-40
	print OUT "	CmB__Expand_Model_Custom26 = $dr_pvt_enable[26]\n";	#SSGNPG_0.63_0.765_0
	print OUT "	CmB__Expand_Model_Custom27 = $dr_pvt_enable[27]\n";	#SSGNPG_0.63_0.765_125
	print OUT "	CmB__Expand_Model_Custom28 = $dr_pvt_enable[28]\n";	#TT_0.7_0.85_25
	print OUT "	CmB__Expand_Model_Custom29 = $dr_pvt_enable[29]\n";	#TT_0.7_0.85_85
	print OUT "	CmB__Expand_Model_Custom30 = $dr_pvt_enable[30]\n";	#TT_0.7_0.85_-10
	print OUT "	CmB__Expand_Model_Custom31 = $dr_pvt_enable[31]\n";	#TT_0.7_0.85_110
	print OUT "	CmB__Expand_Model_Custom32 = $dr_pvt_enable[32]\n";	#FFGNPG_0.77_0.935_-40
	print OUT "	CmB__Expand_Model_Custom33 = $dr_pvt_enable[33]\n";	#FFGNPG_0.77_0.935_0
	print OUT "	CmB__Expand_Model_Custom34 = $dr_pvt_enable[34]\n";	#FFGNPG_0.77_0.935_125
	print OUT "	CmB__Expand_Model_Custom35 = $dr_pvt_enable[35]\n";	#FFG_0.77_0.935_125
	print OUT "	CmB__Expand_Model_Custom36 = $dr_pvt_enable[36]\n";	#SSGNPG_0.54_0.765_-40
	print OUT "	CmB__Expand_Model_Custom37 = $dr_pvt_enable[37]\n";	#SSGNPG_0.54_0.765_0
	print OUT "	CmB__Expand_Model_Custom38 = $dr_pvt_enable[38]\n";	#SSGNPG_0.54_0.765_125
	print OUT "	CmB__Expand_Model_Custom39 = $dr_pvt_enable[39]\n";	#TT_0.6_0.85_25
	print OUT "	CmB__Expand_Model_Custom40 = $dr_pvt_enable[40]\n";	#TT_0.6_0.85_85
	print OUT "	CmB__Expand_Model_Custom41 = $dr_pvt_enable[41]\n";	#TT_0.6_0.85_-10
	print OUT "	CmB__Expand_Model_Custom42 = $dr_pvt_enable[42]\n";	#TT_0.6_0.85_110
	print OUT "	CmB__Expand_Model_Custom43 = $dr_pvt_enable[43]\n";	#FFGNPG_0.66_0.935_-40
	print OUT "	CmB__Expand_Model_Custom44 = $dr_pvt_enable[44]\n";	#FFGNPG_0.66_0.935_0
	print OUT "	CmB__Expand_Model_Custom45 = $dr_pvt_enable[45]\n";	#FFGNPG_0.66_0.935_125
	print OUT "	CmB__Expand_Model_Custom46 = $dr_pvt_enable[46]\n";	#FFG_0.66_0.935_125
	print OUT "	CmB__Expand_Model_Custom47 = $dr_pvt_enable[47]\n";	#SSGNPG_0.72_0.72_-40
	print OUT "	CmB__Expand_Model_Custom48 = $dr_pvt_enable[48]\n";	#SSGNPG_0.72_0.72_0
	print OUT "	CmB__Expand_Model_Custom49 = $dr_pvt_enable[49]\n";	#SSGNPG_0.72_0.72_125
	print OUT "	CmB__Expand_Model_Custom50 = $dr_pvt_enable[50]\n";	#SSGNPG_0.72_0.72_150
	print OUT "	CmB__Expand_Model_Custom51 = $dr_pvt_enable[51]\n";	#TT_0.8_0.8_25
	print OUT "	CmB__Expand_Model_Custom52 = $dr_pvt_enable[52]\n";	#TT_0.8_0.8_85
	print OUT "	CmB__Expand_Model_Custom53 = $dr_pvt_enable[53]\n";	#TT_0.8_0.8_-10
	print OUT "	CmB__Expand_Model_Custom54 = $dr_pvt_enable[54]\n";	#TT_0.8_0.8_110
	print OUT "	CmB__Expand_Model_Custom55 = $dr_pvt_enable[55]\n";	#FFGNPG_0.88_0.88_-40
	print OUT "	CmB__Expand_Model_Custom56 = $dr_pvt_enable[56]\n";	#FFGNPG_0.88_0.88_0
	print OUT "	CmB__Expand_Model_Custom57 = $dr_pvt_enable[57]\n";	#FFGNPG_0.88_0.88_125
	print OUT "	CmB__Expand_Model_Custom58 = $dr_pvt_enable[58]\n";	#FFGNPG_0.88_0.88_150
	print OUT "	CmB__Expand_Model_Custom59 = $dr_pvt_enable[59]\n";	#FFG_0.88_0.88_125
	print OUT "	CmB__Expand_Model_Custom60 = $dr_pvt_enable[60]\n";	#SSGNPG_0.63_0.72_-40
	print OUT "	CmB__Expand_Model_Custom61 = $dr_pvt_enable[61]\n";	#SSGNPG_0.63_0.72_0
	print OUT "	CmB__Expand_Model_Custom62 = $dr_pvt_enable[62]\n";	#SSGNPG_0.63_0.72_125
	print OUT "	CmB__Expand_Model_Custom63 = $dr_pvt_enable[63]\n";	#TT_0.7_0.8_25
	print OUT "	CmB__Expand_Model_Custom64 = $dr_pvt_enable[64]\n";	#TT_0.7_0.8_85
	print OUT "	CmB__Expand_Model_Custom65 = $dr_pvt_enable[65]\n";	#TT_0.7_0.8_-10
	print OUT "	CmB__Expand_Model_Custom66 = $dr_pvt_enable[66]\n";	#TT_0.7_0.8_110
	print OUT "	CmB__Expand_Model_Custom67 = $dr_pvt_enable[67]\n";	#FFGNPG_0.77_0.88_-40
	print OUT "	CmB__Expand_Model_Custom68 = $dr_pvt_enable[68]\n";	#FFGNPG_0.77_0.88_0
	print OUT "	CmB__Expand_Model_Custom69 = $dr_pvt_enable[69]\n";	#FFGNPG_0.77_0.88_125
	print OUT "	CmB__Expand_Model_Custom70 = $dr_pvt_enable[70]\n";	#FFG_0.77_0.88_125
	print OUT "	CmB__Expand_Model_Custom71 = $dr_pvt_enable[71]\n";	#SSGNPG_0.54_0.72_-40
	print OUT "	CmB__Expand_Model_Custom72 = $dr_pvt_enable[72]\n";	#SSGNPG_0.54_0.72_0
	print OUT "	CmB__Expand_Model_Custom73 = $dr_pvt_enable[73]\n";	#SSGNPG_0.54_0.72_125
	print OUT "	CmB__Expand_Model_Custom74 = $dr_pvt_enable[74]\n";	#TT_0.6_0.8_25
	print OUT "	CmB__Expand_Model_Custom75 = $dr_pvt_enable[75]\n";	#TT_0.6_0.8_85
	print OUT "	CmB__Expand_Model_Custom76 = $dr_pvt_enable[76]\n";	#TT_0.6_0.8_-10
	print OUT "	CmB__Expand_Model_Custom77 = $dr_pvt_enable[77]\n";	#TT_0.6_0.8_110
	print OUT "	CmB__Expand_Model_Custom78 = $dr_pvt_enable[78]\n";	#FFGNPG_0.66_0.88_-40
	print OUT "	CmB__Expand_Model_Custom79 = $dr_pvt_enable[79]\n";	#FFGNPG_0.66_0.88_0
	print OUT "	CmB__Expand_Model_Custom80 = $dr_pvt_enable[80]\n";	#FFGNPG_0.66_0.88_125
	print OUT "	CmB__Expand_Model_Custom81 = $dr_pvt_enable[81]\n";	#FFG_0.66_0.88_125
	print OUT "	CmB__Expand_Model_Custom82 = $dr_pvt_enable[82]\n";	#SSGNPG_0.675_0.675_-40
	print OUT "	CmB__Expand_Model_Custom83 = $dr_pvt_enable[83]\n";	#SSGNPG_0.675_0.675_0
	print OUT "	CmB__Expand_Model_Custom84 = $dr_pvt_enable[84]\n";	#SSGNPG_0.675_0.675_125
	print OUT "	CmB__Expand_Model_Custom85 = $dr_pvt_enable[85]\n";	#SSGNPG_0.675_0.675_150
	print OUT "	CmB__Expand_Model_Custom86 = $dr_pvt_enable[86]\n";	#TT_0.75_0.75_25
	print OUT "	CmB__Expand_Model_Custom87 = $dr_pvt_enable[87]\n";	#TT_0.75_0.75_85
	print OUT "	CmB__Expand_Model_Custom88 = $dr_pvt_enable[88]\n";	#TT_0.75_0.75_-10
	print OUT "	CmB__Expand_Model_Custom89 = $dr_pvt_enable[89]\n";	#TT_0.75_0.75_110
	print OUT "	CmB__Expand_Model_Custom90 = $dr_pvt_enable[90]\n";	#FFGNPG_0.825_0.825_-40
	print OUT "	CmB__Expand_Model_Custom91 = $dr_pvt_enable[91]\n";	#FFGNPG_0.825_0.825_0
	print OUT "	CmB__Expand_Model_Custom92 = $dr_pvt_enable[92]\n";	#FFGNPG_0.825_0.825_125
	print OUT "	CmB__Expand_Model_Custom93 = $dr_pvt_enable[93]\n";	#FFGNPG_0.825_0.825_150
	print OUT "	CmB__Expand_Model_Custom94 = $dr_pvt_enable[94]\n";	#FFG_0.825_0.825_125
	print OUT "	CmB__Expand_Model_Custom95 = $dr_pvt_enable[95]\n";	#SSGNPG_0.63_0.675_-40
	print OUT "	CmB__Expand_Model_Custom96 = $dr_pvt_enable[96]\n";	#SSGNPG_0.63_0.675_0
	print OUT "	CmB__Expand_Model_Custom97 = $dr_pvt_enable[97]\n";	#SSGNPG_0.63_0.675_125
	print OUT "	CmB__Expand_Model_Custom98 = $dr_pvt_enable[98]\n";	#TT_0.7_0.75_25
	print OUT "	CmB__Expand_Model_Custom99 = $dr_pvt_enable[99]\n";	#TT_0.7_0.75_85
	print OUT "	CmB__Expand_Model_Custom100 = $dr_pvt_enable[100]\n";	#TT_0.7_0.75_-10
	print OUT "	CmB__Expand_Model_Custom101 = $dr_pvt_enable[101]\n";	#TT_0.7_0.75_110
	print OUT "	CmB__Expand_Model_Custom102 = $dr_pvt_enable[102]\n";	#FFGNPG_0.77_0.825_-40
	print OUT "	CmB__Expand_Model_Custom103 = $dr_pvt_enable[103]\n";	#FFGNPG_0.77_0.825_0
	print OUT "	CmB__Expand_Model_Custom104 = $dr_pvt_enable[104]\n";	#FFGNPG_0.77_0.825_125
	print OUT "	CmB__Expand_Model_Custom105 = $dr_pvt_enable[105]\n";	#FFG_0.77_0.825_125
	print OUT "	CmB__Expand_Model_Custom106 = $dr_pvt_enable[106]\n";	#SSGNPG_0.54_0.675_-40
	print OUT "	CmB__Expand_Model_Custom107 = $dr_pvt_enable[107]\n";	#SSGNPG_0.54_0.675_0
	print OUT "	CmB__Expand_Model_Custom108 = $dr_pvt_enable[108]\n";	#SSGNPG_0.54_0.675_125
	print OUT "	CmB__Expand_Model_Custom109 = $dr_pvt_enable[109]\n";	#TT_0.6_0.75_25
	print OUT "	CmB__Expand_Model_Custom110 = $dr_pvt_enable[110]\n";	#TT_0.6_0.75_85
	print OUT "	CmB__Expand_Model_Custom111 = $dr_pvt_enable[111]\n";	#TT_0.6_0.75_-10
	print OUT "	CmB__Expand_Model_Custom112 = $dr_pvt_enable[112]\n";	#TT_0.6_0.75_110
	print OUT "	CmB__Expand_Model_Custom113 = $dr_pvt_enable[113]\n";	#FFGNPG_0.66_0.825_-40
	print OUT "	CmB__Expand_Model_Custom114 = $dr_pvt_enable[114]\n";	#FFGNPG_0.66_0.825_0
	print OUT "	CmB__Expand_Model_Custom115 = $dr_pvt_enable[115]\n";	#FFGNPG_0.66_0.825_125
	print OUT "	CmB__Expand_Model_Custom116 = $dr_pvt_enable[116]\n";	#FFG_0.66_0.825_125
	print OUT "	CmB__Expand_Model_Custom117 = $dr_pvt_enable[117]\n";	#SSGNPG_0.5_0.675_-40
	print OUT "	CmB__Expand_Model_Custom118 = $dr_pvt_enable[118]\n";	#SSGNPG_0.5_0.675_0
	print OUT "	CmB__Expand_Model_Custom119 = $dr_pvt_enable[119]\n";	#SSGNPG_0.5_0.675_125
	print OUT "	CmB__Expand_Model_Custom120 = $dr_pvt_enable[120]\n";	#SSGNPG_0.5_0.675_150
	print OUT "	CmB__Expand_Model_Custom121 = $dr_pvt_enable[121]\n";	#TT_0.55_0.75_25
	print OUT "	CmB__Expand_Model_Custom122 = $dr_pvt_enable[122]\n";	#TT_0.55_0.75_85
	print OUT "	CmB__Expand_Model_Custom123 = $dr_pvt_enable[123]\n";	#TT_0.55_0.75_-10
	print OUT "	CmB__Expand_Model_Custom124 = $dr_pvt_enable[124]\n";	#TT_0.55_0.75_110
	print OUT "	CmB__Expand_Model_Custom125 = $dr_pvt_enable[125]\n";	#FFGNPG_0.6_0.825_-40
	print OUT "	CmB__Expand_Model_Custom126 = $dr_pvt_enable[126]\n";	#FFGNPG_0.6_0.825_0
	print OUT "	CmB__Expand_Model_Custom127 = $dr_pvt_enable[127]\n";	#FFGNPG_0.6_0.825_125
	print OUT "	CmB__Expand_Model_Custom128 = $dr_pvt_enable[128]\n";	#FFGNPG_0.6_0.825_150
	print OUT "	CmB__Expand_Model_Custom129 = $dr_pvt_enable[129]\n";	#FFG_0.6_0.825_125
	print OUT "	CmB__Expand_Model_Custom130 = $dr_pvt_enable[130]\n";	#SSGNPG_0.9_0.9_-40
	print OUT "	CmB__Expand_Model_Custom131 = $dr_pvt_enable[131]\n";	#SSGNPG_0.9_0.9_0
	print OUT "	CmB__Expand_Model_Custom132 = $dr_pvt_enable[132]\n";	#SSGNPG_0.9_0.9_125
	print OUT "	CmB__Expand_Model_Custom133 = $dr_pvt_enable[133]\n";	#TT_1_1_25
	print OUT "	CmB__Expand_Model_Custom134 = $dr_pvt_enable[134]\n";	#TT_1_1_85
	print OUT "	CmB__Expand_Model_Custom135 = $dr_pvt_enable[135]\n";	#TT_1_1_-10
	print OUT "	CmB__Expand_Model_Custom136 = $dr_pvt_enable[136]\n";	#TT_1_1_110
	print OUT "	CmB__Expand_Model_Custom137 = $dr_pvt_enable[137]\n";	#FFGNPG_1.05_1.05_-40
	print OUT "	CmB__Expand_Model_Custom138 = $dr_pvt_enable[138]\n";	#FFGNPG_1.05_1.05_0
	print OUT "	CmB__Expand_Model_Custom139 = $dr_pvt_enable[139]\n";	#FFGNPG_1.05_1.05_85
	print OUT "	CmB__Expand_Model_Custom140 = $dr_pvt_enable[140]\n";	#FFGNPG_1.05_1.05_125
	print OUT "	CmB__Expand_Model_Custom141 = $dr_pvt_enable[141]\n";	#FFG_1.05_1.05_125
	print OUT "	CmB__Expand_Model_Custom142 = $dr_pvt_enable[142]\n";	#SSGNPG_0.81_0.81_-40
	print OUT "	CmB__Expand_Model_Custom143 = $dr_pvt_enable[143]\n";	#SSGNPG_0.81_0.81_0
	print OUT "	CmB__Expand_Model_Custom144 = $dr_pvt_enable[144]\n";	#SSGNPG_0.81_0.81_125
	print OUT "	CmB__Expand_Model_Custom145 = $dr_pvt_enable[145]\n";	#TT_0.9_0.9_25
	print OUT "	CmB__Expand_Model_Custom146 = $dr_pvt_enable[146]\n";	#TT_0.9_0.9_85
	print OUT "	CmB__Expand_Model_Custom147 = $dr_pvt_enable[147]\n";	#TT_0.9_0.9_-10
	print OUT "	CmB__Expand_Model_Custom148 = $dr_pvt_enable[148]\n";	#TT_0.9_0.9_110
	print OUT "	CmB__Expand_Model_Custom149 = $dr_pvt_enable[149]\n";	#FFGNPG_0.99_0.99_-40
	print OUT "	CmB__Expand_Model_Custom150 = $dr_pvt_enable[150]\n";	#FFGNPG_0.99_0.99_0
	print OUT "	CmB__Expand_Model_Custom151 = $dr_pvt_enable[151]\n";	#FFGNPG_0.99_0.99_85
	print OUT "	CmB__Expand_Model_Custom152 = $dr_pvt_enable[152]\n";	#FFGNPG_0.99_0.99_125
	print OUT "	CmB__Expand_Model_Custom153 = $dr_pvt_enable[153]\n";	#FFG_0.99_0.99_125
	print OUT "	CmB__Expand_Model_Custom154 = $dr_pvt_enable[154]\n";	#SSGNPG_0.81_0.9_-40
	print OUT "	CmB__Expand_Model_Custom155 = $dr_pvt_enable[155]\n";	#SSGNPG_0.81_0.9_0
	print OUT "	CmB__Expand_Model_Custom156 = $dr_pvt_enable[156]\n";	#SSGNPG_0.81_0.9_125
	print OUT "	CmB__Expand_Model_Custom157 = $dr_pvt_enable[157]\n";	#TT_0.9_1_25
	print OUT "	CmB__Expand_Model_Custom158 = $dr_pvt_enable[158]\n";	#TT_0.9_1_85
	print OUT "	CmB__Expand_Model_Custom159 = $dr_pvt_enable[159]\n";	#TT_0.9_1_-10
	print OUT "	CmB__Expand_Model_Custom160 = $dr_pvt_enable[160]\n";	#TT_0.9_1_110
	print OUT "	CmB__Expand_Model_Custom161 = $dr_pvt_enable[161]\n";	#FFGNPG_0.99_1.05_-40
	print OUT "	CmB__Expand_Model_Custom162 = $dr_pvt_enable[162]\n";	#FFGNPG_0.99_1.05_0
	print OUT "	CmB__Expand_Model_Custom163 = $dr_pvt_enable[163]\n";	#FFGNPG_0.99_1.05_85
	print OUT "	CmB__Expand_Model_Custom164 = $dr_pvt_enable[164]\n";	#FFGNPG_0.99_1.05_125
	print OUT "	CmB__Expand_Model_Custom165 = $dr_pvt_enable[165]\n";	#FFG_0.99_1.05_125
	print OUT "	CmB__Expand_Model_Custom166 = $dr_pvt_enable[166]\n";	#SSGNPG_0.855_0.855_-40
	print OUT "	CmB__Expand_Model_Custom167 = $dr_pvt_enable[167]\n";	#SSGNPG_0.855_0.855_0
	print OUT "	CmB__Expand_Model_Custom168 = $dr_pvt_enable[168]\n";	#SSGNPG_0.855_0.855_125
	print OUT "	CmB__Expand_Model_Custom169 = $dr_pvt_enable[169]\n";	#TT_0.95_0.95_25
	print OUT "	CmB__Expand_Model_Custom170 = $dr_pvt_enable[170]\n";	#TT_0.95_0.95_85
	print OUT "	CmB__Expand_Model_Custom171 = $dr_pvt_enable[171]\n";	#TT_0.95_0.95_-10
	print OUT "	CmB__Expand_Model_Custom172 = $dr_pvt_enable[172]\n";	#TT_0.95_0.95_110
	print OUT "	CmB__Expand_Model_Custom173 = $dr_pvt_enable[173]\n";	#FFGNPG_1.045_1.045_-40
	print OUT "	CmB__Expand_Model_Custom174 = $dr_pvt_enable[174]\n";	#FFGNPG_1.045_1.045_0
	print OUT "	CmB__Expand_Model_Custom175 = $dr_pvt_enable[175]\n";	#FFGNPG_1.045_1.045_125
	print OUT "	CmB__Expand_Model_Custom176 = $dr_pvt_enable[176]\n";	#FFG_1.045_1.045_125     
##//END_OF_PVT_GEN_DR//    
    }
    print OUT "\n";
    close(OUT);
    
    if($compType eq "rom")
    {
        &genromcode;
    }
    $mco = $ENV{'MC_HOME'}."\/".$library."_".$fullver.".mco";
    if (-f $mco)
    {
        system "mc2-eu -c $library"."_".$fullver.".mco -cfg ".$file.".cfg -ui textual -v -p tsmceva";
    }
    else
    {
        system "mc2 -c $library"."_".$fullver." -cfg ".$file.".cfg -ui textual -v -p tsmceva";
    }
    &del_folder($file_folder); 
    if($delworst == 1)
    {
        system "find $ENV{PWD}/$file_folder -name \"*$delpvt*\" -exec rm {} \\\;";
    }
}
close(CONFIG);
exit;        

#####################################################
sub genromcode {
        $doCode1 = $doCode;
        if( $doCode1=~/yes/i ) 
        {
            if( open( CODEFILE, $codefile )) 
            {
                close( CODEFILE );
                while (1) 
                {
                    print "OK to overwrite $codefile? ";
                    $doCode1=<STDIN>;
                    last if ($doCode1=~/^y/i or $doCode1=~/^n/i);
                }
                $doCode1="yes" if ($doCode1=~/^y/i);
                $doCode1="no" if ($doCode1=~/^n/i);
            }
        }   
        if( $doCode1=~/yes/i ) 
        {
            open( CODEFILE, ">$codefile");
            $addr = 0;
            
            $extAddr = 0;
            $wl_cnt1=0;
            $seg_cnt1=0;
            $seg_last_wl1=0;
            $end_wl1=0;
            $seg_end1=0;
            $wl_cnt=0;
            $seg_cnt=0;
            $seg_last_wl=0;
            $end_wl=0;
            $seg_end=0;
            $seg_count=0;
            $last_word_line=$NWORD/$NMUX;

            $dataLength = int( ( $NBIT + 7 ) / 8 );
            $data = 0xff;
            $mask = (1 << ($NBIT - (($dataLength - 1) * 8))) - 1;
            
            $mode="majority_code";

            for($w=0;$w<$NWORD;++$w) 
            {
                $data = 0xff - $data;
                $w1=$w-($NMUX*$seg_tag*$seg_count)-8;

                if($mode eq "S1"){
                    $data = 0xff - $data;
                }
                if($mode eq "S0"){
                    $data = $data - $data;
                }

                if($mode eq "check_board"){
                     if( $w % ($NMUX*2) == 0  && $w ne "0") {
                          $data = 0xff - $data;
                     }
                }

                if($mode eq "double_code" && $w ne "0"){
                     if( $w1 < 0 ) {  }
               
                     elsif( $w1 > 0 && $w1 % ( (($NMUX*2) * 3)-8 ) == 0 ) {
                          $data = 0xff - $data;
                     
                     }
                     elsif( $w1 > 0 && $w % ( ($NMUX*2) * $seg_tag ) == 0 ) {
                             $data = 0xff - $data;
                             $seg_count++;
                     }
                }

                if($mode eq "adouble_code" && $w ne "0")
                {
                    $last_wl=$last_word_line-1;
                    if( $w % ($NMUX*2) == 0 ) {
                        $wl_cnt1++;
                        $seg_cnt1++;
                       
                        if($wl_cnt1 eq "2"){
                            #$data = 0xff - $data;
                        }

                        if($seg_cnt1 == 127){
                             $seg_last_wl1 = 1;
                             $seg_end1 = 1;
                        }
                    }
                    #print "seg_cnt1=$seg_cnt1\n";
                    if($end_wl1 eq "1") { $wl_cnt1 = 0; }
                    #print "seg_last_wl1=$seg_last_wl1\n";
                    #print "wl_cnt1=$wl_cnt1\n";
                    #print "last_wl=$last_wl\n";
                    if( $seg_last_wl1 eq "1" || $wl_cnt1 eq $last_wl) {
                         $data = 0xff - $data;
                         $seg_cnt1 = 0;
                         $seg_last_wl1 = 0;

                          if($wl_cnt1 eq $last_wl){
                              $end_wl1=1;
                          }
                    }
                }

                if($mode eq "majority_code")
                { 
                    if( ($w !=0) && (($w+(2*$NMUX)) % ($NMUX*$seg_tag) == 0))
                    {
                        $data = 0xff - $data;
                        #print "chantge $w"; 
                    }
                    if( ($w !=0) && ($w % ($NMUX*$seg_tag) == 0))
                    {
                        $data = 0xff - $data;
                        #print "chantge $w"; 
                    }
                    if(($w+(2*$NMUX)) == $NWORD && ($w+(2*$NMUX)) % ($NMUX*$seg_tag) != 0)
                    {
                        $data = 0xff - $data;
                        #print "chantge $w"; 
                    }
                }

                newRecord();
                appendByte($dataLength);
                appendByte($addr>>8);
                appendByte($addr&0xff);
                appendByte(0);
                appendByte( $data & $mask );
                for( $b = 0; $b < $dataLength - 1; ++$b ) {
                    appendByte( $data );
                }
                appendByte( (-$checksum)&0xff );
                print CODEFILE $record."\n";
                $addr += $dataLength;
                if( $addr > 0xffff ) 
                {
                    $addr -= 0x10000;
                    ++$extAddr;
                    newRecord();
                    appendByte(2);
                    appendByte(0);
                    appendByte(0);
                    appendByte(4);
                    appendByte($extAddr>>8);
                    appendByte($extAddr&0xff);
                    appendByte( (-$checksum)&0xff );
                    print CODEFILE $record."\n";
                }
            }
            newRecord();
            appendByte(0);
            appendByte(0);
            appendByte(0);
            appendByte(1);
            appendByte( (-$checksum)&0xff );
            print CODEFILE $record."\n";
            close( CODEFILE );
        }    
}

sub newRecord {
    $record = ":";
    $checksum = 0;
}
sub appendByte {
    my $byte = shift(@_);
    $checksum += $byte;
    $record = $record.sprintf( "%02x", $byte );
}

sub op_condition
{
    print "*************************************************************************************\n";
    if ($tsmc_name eq "yes") { print "*** Use TSMC naming convention (default option). ***\n"; }
    else { print "*** Do not use TSMC naming convention ! ***\n"; }
    if ($gencfgonly eq "yes") { print "*** Only generate configuration file($config) and do not run mc2 !  ***\n"; }
    print "*** Use Ground name($gnd). ***\n";
    print "*** SRAM DELAY = $sd. ***\n";
    #if ($BWEB_Enable eq "yes") { print "*** BWEB Enable (default option). ***\n"; }
    #else { print "*** BWEB Disable ! ***\n"; }
    #if ($BIST_Enable eq "yes") { print "*** BIST Enable (default option). ***\n"; }
    #else { print "*** BIST Disable ! ***\n"; }
    #if ($SLP_Enable eq "yes") { print "*** SLP Enable (default option). ***\n"; }
    #else { print "*** SLP Disable ! ***\n"; }
    #if ($DSLP_Enable eq "yes") { print "*** DSLP Enable (default option). ***\n"; }
    #else { print "*** DSLP Disable ! ***\n"; }
    #if ($SD_Enable eq "yes") { print "*** SD Enable (default option). ***\n"; }
    #else { print "*** SD Disable ! ***\n"; }
    #if ($DualRail_Enable eq "yes") { print "*** Dual_Rail Enable (default option). ***\n"; }
    #else { print "*** Dual_Rail Disable ! ***\n"; }
    #if ($Periphery_Vt eq "SVT") { print "*** SVT20 option ***\n"; }
    #else { print "*** ULVT20 option (default option). ***\n";}
    #if ($Periphery_Vt eq "LVT") { print "*** LVT20 option ***\n"; }
    #else { print "*** ULVT20 option (default option). ***\n";}
    #if ($CCST_Enable eq "yes") { print "*** CCST Enable (default option). ***\n"; }
    #else { print "*** CCST Disable ! ***\n"; }
}

sub option_error_message
{
    my @SR_error_message;
    my @DR_error_message;

    @SR_error_message =
    ("\n",
    "The supported options for single rail is below\n",
    "SLP DSLP SD\n",
    "N   N    N\n",
    "Y   N    N\n",
    "Y   N    Y\n",
    "N   Y    Y\n",
    "Y   Y    Y\n",
    "Y : yes ; N : no\n\n");

    @DR_error_message =
    ("\n",
    "The supported options for dual rail is below\n",
    "SLP DSLP SD\n",
    "Y   N    Y\n",
    "N   Y    Y\n",
    "Y   Y    Y\n",
    "Y : yes ; N : no\n\n");

    if($DualRail_Enable eq "yes")
    {
        if($SLP_Enable eq "yes" && $DSLP_Enable eq "no" && $SD_Enable eq "yes") {} ## SOD
        elsif($SLP_Enable eq "no" && $DSLP_Enable eq "yes" && $SD_Enable eq "yes") {} ## HOD
        elsif($SLP_Enable eq "yes" && $DSLP_Enable eq "yes" && $SD_Enable eq "yes") {} ## SHOD
        else
        {
            print "\n[Error] The input options setting SLP = $SLP_Enable; DSLP = $DSLP_Enable; SD = $SD_Enable; is not support!\n";
            print @DR_error_message;
            exit 1;
        }
    }
    else
    {
        if($SLP_Enable eq "no" && $DSLP_Enable eq "no" && $SD_Enable eq "no") {} ## NO option
        elsif($SLP_Enable eq "yes" && $DSLP_Enable eq "no" && $SD_Enable eq "no") {} ## S
        elsif($SLP_Enable eq "yes" && $DSLP_Enable eq "no" && $SD_Enable eq "yes") {} ## SO
        elsif($SLP_Enable eq "no" && $DSLP_Enable eq "yes" && $SD_Enable eq "yes") {} ## HO
        elsif($SLP_Enable eq "yes" && $DSLP_Enable eq "yes" && $SD_Enable eq "yes") {} ## SHO
        else
        {           
            print "\n[Error] The input options setting SLP = $SLP_Enable; DSLP = $DSLP_Enable; SD = $SD_Enable; is not support!\n";
            print @SR_error_message;
            exit 1;
        }
    }
}

sub del_folder
{
    my $file_path = shift @_;

    if( $GDSII eq "false" )
    {
        system "rm -rf ./$file_path/GDSII\n";
    }
    if( $SPICE eq "false" )
    {
        system "rm -rf ./$file_path/SPICE\n";
    }
    if( $LEF eq "false" )
    {
        system "rm -rf ./$file_path/LEF\n";
    }
    if( $DATASHEET eq "false" )
    {
        system "rm -rf ./$file_path/DATASHEET\n";
    }
    if( $NLDM eq "false" )
    {
        system "rm -rf ./$file_path/NLDM\n";
    }
    if( $VERILOG eq "false" )
    {
        system "rm -rf ./$file_path/VERILOG\n";
    }
    if( $DFT eq "false" )
    {
        system "rm -rf ./$file_path/DFT\n";
    }
    if( $CCS eq "false" )
    {
        system "rm -rf ./$file_path/CCS\n";
    }
    if( $ECSM eq "false" )
    {
        system "rm -rf ./$file_path/ECSM\n";
    }

}

sub help {
$hgen   = "";
$hnbweb = "";
$hnslp  = "";
$hndslp = "";
$hcol =   "";
if($compType eq "rom") {
$hgen =   "\n    -GenROMCode        : To generate the default rom code. (The user-defined rom code should be specified in config file as an argument for instance generation)";
}
else {
$hnbweb = "\n    -NonBWEB           : To disable BWEB option.";
$hnslp =  "\n    -NonSLP            : To disable SLP option.";
$hndslp = "\n    -NonDSLP           : To disable DSLP option.";
$hcol =   "\n    -ColRed            : To enable column redundancy option.";
}
print <<End_of_help;
NAME
    $library\_$version.pl

OPTIONS
    -h                 : Help
    -NonTsmcName       : To use user-defined naming convention (default is TSMC naming convention).$hgen   
    -file <configfile> : To use the input file from user as configuration file (default is config.txt).
    -GND               : To use GND as ground name (default is VSS).
    -sd <unit_delay>   : To set SRAM DELAY value (default value is $sd).
    -NonBus            : To set input and output pins as bit-blasted type.
    -DualRail          : To enable Dual Rail option (default is Disable).
    -SVT               : To enable svt option (default is lvt).$hnbweb
    -NonBIST           : To disable BIST option.$hnslp$hndslp
    -NonSD             : To disable SD option.$hcol
    -DATASHEET         : To generate DATASHEET kit only
    -VERILOG           : To generate VERILOG kit only
    -NLDM              : To generate NLDM kit only
    -LEF               : To generate LEF kit only
    -SPICE             : To generate SPICE kit only
    -GDSII             : To generate GDS kit only
    -DFT               : To generate DFT kit only
    -CCS               : To generate CCS kit only
    -ECSM              : To generate ECSM kit only
    -MasisWrapper      : To specify the TieLevel to Wrapper for the pins with Tag = None in Masis kit (default is TestBench)
    -MasisMemory       : To specify the TieLevel to Memory for the pins with Tag = None in Masis kit (default is TestBench)
    -PVT               : To choose specific PVT corners
    -LISTPVT           : To list PVT corners
   
EXAMPLES

     Example 1: To use TSMC naming convention.

     example% $library\_$version.pl -file config.txt

     Example 2: To use user-defined naming convention.

     example% $library\_$version.pl -NonTsmcName -file config.txt

     Example 3: To use GND as ground name and enable Dual-Rail option.

     example% $library\_$version.pl -GND -DualRail

     Example 4: To disable BIST option

     example% $library\_$version.pl -NonBIST

     Example 5: To generate DATASHEET kit only.
 
     example% $library\_$version.pl -DATASHEET
    
     Example 6: To generate VERILOG and NLDM kits only.
 
     example% $library\_$version.pl -VERILOG -NLDM         
 
     Example 7: To generate only 2 PVT.
 
     example% $library\_$version.pl -pvt tt1vm10c tt1v110c
 

End_of_help
exit 1;
}
