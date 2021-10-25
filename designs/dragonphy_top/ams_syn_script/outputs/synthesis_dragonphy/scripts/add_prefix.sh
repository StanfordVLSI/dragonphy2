
#!/bin/sh

aprDir="/aha/sjkim85/apr_flow"
synDir="${aprDir}/synthesis_dragonphy"
pnrDir="${aprDir}/pnr_dragonphy"

module1="stochastic_adc_PR" 
module2="phase_interpolator" 
module3="biasgen" 
module4="input_divider" 

\cp ${pnrDir}/${module1}/results/${module1}.pnr.v ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 

sed -i "s/^module inv/module ${module1}_inv/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module a_nd/module ${module1}_a_nd/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module n_and/module ${module1}_n_and/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module n_or/module ${module1}_n_or/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module o_r/module ${module1}_o_r/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module x_or/module ${module1}_x_or/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module x_nor/module ${module1}_x_nor/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module ff/module ${module1}_ff/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module mux/module ${module1}_mux/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module n_and4/module ${module1}_n_and4/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module inv_chain/module ${module1}_inv_chain/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module dcdl/module ${module1}_dcdl/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module arbiter/module ${module1}_arbiter/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module bin2thm/module ${module1}_bin2thm/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/^module phase_monitor/module ${module1}_phase_monitor/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 

sed -i "s/  inv/  ${module1}_inv/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  a_nd/  ${module1}_a_nd/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  n_and/  ${module1}_n_and/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  n_or/  ${module1}_n_or/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  o_r/  ${module1}_o_r/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  x_or/  ${module1}_x_or/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  x_nor/  ${module1}_x_nor/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  ff/  ${module1}_ff/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  mux/  ${module1}_mux/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  n_and4/  ${module1}_n_and4/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  inv_chain/  ${module1}_inv_chain/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  dcdl/  ${module1}_dcdl/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  arbiter/  ${module1}_arbiter/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  bin2thm/  ${module1}_bin2thm/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 
sed -i "s/  phase_monitor/  ${module1}_phase_monitor/g" ${pnrDir}/${module1}/results/${module1}.pnr.prefix.v 


\cp ${pnrDir}/${module2}/results/${module2}.pnr.v ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 

sed -i "s/^module inv/module ${module2}_inv/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module a_nd/module ${module2}_a_nd/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module n_and/module ${module2}_n_and/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module n_or/module ${module2}_n_or/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module o_r/module ${module2}_o_r/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module x_or/module ${module2}_x_or/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module x_nor/module ${module2}_x_nor/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module ff/module ${module2}_ff/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module mux/module ${module2}_mux/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module n_and4/module ${module2}_n_and4/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module inv_chain/module ${module2}_inv_chain/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module dcdl/module ${module2}_dcdl/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module arbiter/module ${module2}_arbiter/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module bin2thm/module ${module2}_bin2thm/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/^module phase_monitor/module ${module2}_phase_monitor/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 

sed -i "s/  inv/  ${module2}_inv/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  a_nd/  ${module2}_a_nd/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  n_and/  ${module2}_n_and/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  n_or/  ${module2}_n_or/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  o_r/  ${module2}_o_r/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  x_or/  ${module2}_x_or/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  x_nor/  ${module2}_x_nor/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  ff/  ${module2}_ff/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  mux/  ${module2}_mux/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  n_and4/  ${module2}_n_and4/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  inv_chain/  ${module2}_inv_chain/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  dcdl/  ${module2}_dcdl/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  arbiter/  ${module2}_arbiter/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  bin2thm/  ${module2}_bin2thm/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 
sed -i "s/  phase_monitor/  ${module2}_phase_monitor/g" ${pnrDir}/${module2}/results/${module2}.pnr.prefix.v 

\cp ${pnrDir}/${module3}/results/${module3}.pnr.v ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 

sed -i "s/^module inv/module ${module3}_inv/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module a_nd/module ${module3}_a_nd/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module n_and/module ${module3}_n_and/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module n_or/module ${module3}_n_or/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module o_r/module ${module3}_o_r/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module x_or/module ${module3}_x_or/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module x_nor/module ${module3}_x_nor/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module ff/module ${module3}_ff/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module mux/module ${module3}_mux/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module n_and4/module ${module3}_n_and4/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module inv_chain/module ${module3}_inv_chain/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module dcdl/module ${module3}_dcdl/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module arbiter/module ${module3}_arbiter/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module bin2thm/module ${module3}_bin2thm/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/^module phase_monitor/module ${module3}_phase_monitor/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 

sed -i "s/  inv/  ${module3}_inv/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  a_nd/  ${module3}_a_nd/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  n_and/  ${module3}_n_and/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  n_or/  ${module3}_n_or/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  o_r/  ${module3}_o_r/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  x_or/  ${module3}_x_or/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  x_nor/  ${module3}_x_nor/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  ff/  ${module3}_ff/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  mux/  ${module3}_mux/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  n_and4/  ${module3}_n_and4/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  inv_chain/  ${module3}_inv_chain/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  dcdl/  ${module3}_dcdl/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  arbiter/  ${module3}_arbiter/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  bin2thm/  ${module3}_bin2thm/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 
sed -i "s/  phase_monitor/  ${module3}_phase_monitor/g" ${pnrDir}/${module3}/results/${module3}.pnr.prefix.v 


\cp ${pnrDir}/${module4}/results/${module4}.pnr.v ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 

sed -i "s/^module inv/module ${module4}_inv/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module a_nd/module ${module4}_a_nd/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module n_and/module ${module4}_n_and/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module n_or/module ${module4}_n_or/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module o_r/module ${module4}_o_r/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module x_or/module ${module4}_x_or/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module x_nor/module ${module4}_x_nor/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module ff/module ${module4}_ff/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module mux/module ${module4}_mux/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module n_and4/module ${module4}_n_and4/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module inv_chain/module ${module4}_inv_chain/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module dcdl/module ${module4}_dcdl/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module arbiter/module ${module4}_arbiter/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module bin2thm/module ${module4}_bin2thm/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/^module phase_monitor/module ${module4}_phase_monitor/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 

sed -i "s/  inv/  ${module4}_inv/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  a_nd/  ${module4}_a_nd/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  n_and/  ${module4}_n_and/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  n_or/  ${module4}_n_or/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  o_r/  ${module4}_o_r/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  x_or/  ${module4}_x_or/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  x_nor/  ${module4}_x_nor/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  ff/  ${module4}_ff/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  mux/  ${module4}_mux/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  n_and4/  ${module4}_n_and4/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  inv_chain/  ${module4}_inv_chain/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  dcdl/  ${module4}_dcdl/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  arbiter/  ${module4}_arbiter/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  bin2thm/  ${module4}_bin2thm/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 
sed -i "s/  phase_monitor/  ${module4}_phase_monitor/g" ${pnrDir}/${module4}/results/${module4}.pnr.prefix.v 




