# Adapted from mflowgen GcdUnit example

# To select the process, set the DRAGONPHY_PROCESS environment variable
# to either FREEPDK45 or TSMC16

import os

from mflowgen.components import Graph, Step

def construct():

    # Get the name of the process to be used from the environment
    if 'DRAGONPHY_PROCESS' in os.environ:
        DRAGONPHY_PROCESS = os.environ['DRAGONPHY_PROCESS']
    else:
        DRAGONPHY_PROCESS = 'TSMC16'

    g = Graph()

    #-----------------------------------------------------------------------
    # Parameters
    #-----------------------------------------------------------------------

    parameters = {
        'construct_path': __file__,
        'design_name': 'dragonphy_top',
        'topographical': True,
        'hold_target_slack': 0.05
    }

    if DRAGONPHY_PROCESS == 'FREEPDK45':
        parameters['adk_name'] = 'freepdk-45nm'
        parameters['adk_view'] = 'view-standard'
        parameters['qtm_tech_lib'] = 'NangateOpenCellLibrary'
        # override default scale factors for an older, slower process
        parameters['constr_time_scale'] = 10.0
        parameters['constr_cap_scale'] = 10.0*1e3
    elif DRAGONPHY_PROCESS == 'TSMC16':
        parameters['adk_name'] = 'tsmc16'
        parameters['adk_view'] = 'stdview'
    else:
        raise Exception(f'Unknown process: {DRAGONPHY_PROCESS}')

    #-----------------------------------------------------------------------
    # Create nodes
    #-----------------------------------------------------------------------

    this_dir = os.path.dirname( os.path.abspath( __file__ ) )

    # ADK step

    g.set_adk(parameters['adk_name'])
    adk = g.get_adk_step()

    # Custom steps

    rtl = Step(this_dir + '/rtl')
    # genlibdb_constraints = Step(this_dir + '/custom-genlibdb-constraints')
    constraints = Step(this_dir + '/constraints')

    if DRAGONPHY_PROCESS == 'FREEPDK45':
        gen_sram = Step(this_dir + '/openram-gen-sram')
        gen_sram_small = Step(this_dir + '/openram-gen-sram-small')
    elif DRAGONPHY_PROCESS == 'TSMC16':
        gen_sram = Step(this_dir + '/mc-gen-sram')
        gen_sram_small = Step(this_dir + '/mc-gen-sram-small')
    else:
        raise Exception(f'Unknown process: {DRAGONPHY_PROCESS}')

    custom_init = Step(this_dir + '/custom-init')
    # custom_lvs = Step(this_dir + '/custom-lvs-rules')
    custom_power = Step(this_dir + '/custom-power')
    custom_geom = Step(this_dir + '/custom-geom')
    custom_route = Step(this_dir + '/custom-route')
    dc = Step(this_dir + '/synopsys-dc-synthesis')
    qtm = Step(this_dir + '/qtm')
    # Block-level designs (only work in TSMC16)
    blocks = []

    print(DRAGONPHY_PROCESS)
    if DRAGONPHY_PROCESS == 'TSMC16':
        blocks += [
            Step( this_dir + '/analog_core'       ),
            Step( this_dir + '/input_buffer'      ),
            Step( this_dir + '/output_buffer'     ),
            Step( this_dir + '/input_divider' ),
            Step( this_dir + '/phase_interpolator' ),
            Step( this_dir + '/termination' ),
            Step( this_dir + '/mdll_r1' )
        ]

    init = Step(this_dir + '/cadence-innovus-init')
    cts  = Step(this_dir + '/cadence-innovus-cts')
    lvs  = Step(this_dir + '/mentor-calibre-lvs')
    # Default steps
    info           = Step( 'info',                           default=True )
    iflow          = Step( 'cadence-innovus-flowsetup',      default=True )
    #init           = Step( 'cadence-innovus-init',           default=True )
    power          = Step( 'cadence-innovus-power',          default=True )
    place          = Step( 'cadence-innovus-place',          default=True )
    #cts            = Step( 'cadence-innovus-cts',            default=True )
    postcts_hold   = Step( 'cadence-innovus-postcts_hold',   default=True )
    route          = Step( 'cadence-innovus-route',          default=True )
    postroute      = Step( 'cadence-innovus-postroute',      default=True )
    postroute_hold = Step( 'cadence-innovus-postroute_hold', default=True )
    signoff        = Step( 'cadence-innovus-signoff',        default=True )
    pt_signoff     = Step( 'synopsys-pt-timing-signoff',     default=True )
    genlibdb       = Step( 'synopsys-ptpx-genlibdb',         default=True )
    gdsmerge       = Step( 'mentor-calibre-gdsmerge',        default=True )
    drc            = Step( 'mentor-calibre-drc',             default=True )
    #lvs            = Step( 'mentor-calibre-lvs',             default=True )
    debugcalibre   = Step( 'cadence-innovus-debug-calibre',  default=True )

    # Add extra input edges to innovus steps that need custom tweaks

    init.extend_inputs(custom_init.all_outputs())
    init.extend_inputs(custom_geom.all_outputs())

    power.extend_inputs(custom_power.all_outputs())
    power.extend_inputs(custom_geom.all_outputs())

    route.extend_inputs(custom_route.all_outputs())

    # Add *.db files for macros to downstream nodes
    dbs = [
        'analog_core_lib.db',
        'input_buffer_lib.db',
        'output_buffer_lib.db',
        'input_divider_lib.db',
        'phase_interpolator_lib.db',
        'termination_lib.db',
        'mdll_r1_top_lib.db',
        'sram_tt.db',
        'sram_small_tt.db'
    ]
    dc.extend_inputs(dbs)
    pt_signoff.extend_inputs(dbs)
    genlibdb.extend_inputs(dbs)

    # These steps need timing and lef info for black boxes
    libs = [
        'analog_core.lib',
        'mdll_r1_top.lib',
        'input_buffer.lib',
        'output_buffer.lib',
        'input_divider.lib',
        'phase_interpolator.lib',
        'termination.lib',
        'sram_tt.lib',
        'sram_small_tt.lib'
    ]

    lefs = [
        'analog_core.lef',
        'input_buffer.lef',
        'output_buffer.lef',
        'input_divider.lef',
        'phase_interpolator.lef',
        'termination.lef',
        'mdll_r1_top.lef',
        'sram.lef',
        'sram_small.lef'
    ]

    lib_lef_steps = \
        [iflow, init, power, place, cts, postcts_hold, route, postroute, signoff]
    for step in lib_lef_steps:
        step.extend_inputs(libs + lefs)

    # Add GDS files for black boxes to GDS merge step
    gds_list = [
        'analog_core.gds',
        'input_buffer.gds',
        'output_buffer.gds',
        'input_divider.gds',
        'phase_interpolator.gds',
        'termination.gds',
        'mdll_r1_top.gds',
        'sram.gds',
        'sram_small.gds'
    ]
    gdsmerge.extend_inputs(gds_list)

    # Need Spice or Verilog netlists files for black boxes for LVS
    spi_list = [
        'analog_core.spi',
        'mdll_r1_top_macro.cdl',
        'input_buffer.spi',
        'input_divider.spi',
        'phase_interpolator.spi',
        'termination.spi',
        'output_buffer.lvs.v',
        'mdll_r1_top.lvs.v',
        'sram.spi',
        'sram_small.spi'
    ]
    lvs.extend_inputs(spi_list)

    #-----------------------------------------------------------------------
    # Graph -- Add nodes
    #-----------------------------------------------------------------------

    g.add_step( info                 )
    g.add_step( rtl                  )
    g.add_step( gen_sram             )
    g.add_step( gen_sram_small       )
    g.add_step( constraints          )
    g.add_step( dc                   )
    g.add_step( iflow                )
    g.add_step( init                 )
    g.add_step( custom_init          )
    g.add_step( power                )
    g.add_step( custom_power         )
    g.add_step( place                )
    g.add_step( cts                  )
    g.add_step( postcts_hold         )
    g.add_step( custom_route         )
    g.add_step( route                )
    g.add_step( postroute            )
    g.add_step( postroute_hold       )
    g.add_step( signoff              )
    g.add_step( pt_signoff           )
    # g.add_step( genlibdb_constraints )
    g.add_step( genlibdb             )
    g.add_step( gdsmerge             )
    g.add_step( drc                  )
    g.add_step( lvs                  )
    # g.add_step( custom_lvs           )
    g.add_step( debugcalibre         )

    # blocks like analog_core, input_buffer, etc.
    for block in blocks:
        g.add_step( block )

    # *.lib and *.db files for some blocks
    g.add_step( qtm )

    # variables related to the design geometry
    g.add_step( custom_geom )

    #-----------------------------------------------------------------------
    # Graph -- Add edges
    #-----------------------------------------------------------------------

    # Connect by name

    g.connect_by_name( adk,            dc             )
    g.connect_by_name( adk,            iflow          )
    g.connect_by_name( adk,            init           )
    g.connect_by_name( adk,            power          )
    g.connect_by_name( adk,            place          )
    g.connect_by_name( adk,            cts            )
    g.connect_by_name( adk,            postcts_hold   )
    g.connect_by_name( adk,            route          )
    g.connect_by_name( adk,            postroute      )
    g.connect_by_name( adk,            postroute_hold )
    g.connect_by_name( adk,            signoff        )
    g.connect_by_name( adk,            gdsmerge       )
    g.connect_by_name( adk,            drc            )
    g.connect_by_name( adk,            lvs            )
    g.connect_by_name( adk,            qtm            )

    # Connect up blocks like analog_core, input_buffer, etc.
    # The QTM step is also included here because it provides
    # *.lib and *.db files for some of the blocks
    for block in blocks + [gen_sram, gen_sram_small, qtm]:
        g.connect_by_name(block, dc)
        g.connect_by_name(block, iflow)
        g.connect_by_name(block, init)
        g.connect_by_name(block, power)
        g.connect_by_name(block, place)
        g.connect_by_name(block, cts)
        g.connect_by_name(block, postcts_hold)
        g.connect_by_name(block, route)
        g.connect_by_name(block, postroute)
        g.connect_by_name(block, signoff)
        g.connect_by_name(block, genlibdb)
        g.connect_by_name(block, pt_signoff)
        g.connect_by_name(block, gdsmerge)
        g.connect_by_name(block, drc)
        g.connect_by_name(block, lvs)

    g.connect_by_name( rtl,            dc             )
    g.connect_by_name( constraints,    dc             )

    g.connect_by_name( dc,             iflow          )
    g.connect_by_name( dc,             init           )
    g.connect_by_name( dc,             power          )
    g.connect_by_name( dc,             place          )
    g.connect_by_name( dc,             cts            )

    g.connect_by_name( iflow,          init           )
    g.connect_by_name( iflow,          power          )
    g.connect_by_name( iflow,          place          )
    g.connect_by_name( iflow,          cts            )
    g.connect_by_name( iflow,          postcts_hold   )
    g.connect_by_name( iflow,          route          )
    g.connect_by_name( iflow,          postroute      )
    g.connect_by_name( iflow,          postroute_hold )
    g.connect_by_name( iflow,          signoff        )

    g.connect_by_name( custom_init,    init           )
    g.connect_by_name( custom_geom,    init           )

    g.connect_by_name( custom_power,   power          )
    g.connect_by_name( custom_geom,    power          )

    # g.connect_by_name( custom_lvs,     lvs            )

    g.connect_by_name( init,           power          )
    g.connect_by_name( power,          place          )
    g.connect_by_name( place,          cts            )
    g.connect_by_name( cts,            postcts_hold   )
    g.connect_by_name( postcts_hold,   route          )
    g.connect_by_name( custom_route,   route         )
    g.connect_by_name( route,          postroute      )
    g.connect_by_name( postroute,      postroute_hold )
    g.connect_by_name( postroute_hold, signoff        )
    g.connect_by_name( signoff,        gdsmerge       )
    g.connect_by_name( signoff,        drc            )
    g.connect_by_name( signoff,        lvs            )
    g.connect_by_name( gdsmerge,       drc            )
    g.connect_by_name( gdsmerge,       lvs            )

    g.connect_by_name( signoff,        genlibdb       )
    g.connect_by_name( adk,            genlibdb       )
    # g.connect_by_name( genlibdb_constraints, genlibdb )

    g.connect_by_name( adk,            pt_signoff     )
    g.connect_by_name( signoff,        pt_signoff     )

    g.connect_by_name( adk,            debugcalibre   )
    g.connect_by_name( dc,             debugcalibre   )
    g.connect_by_name( iflow,          debugcalibre   )
    g.connect_by_name( signoff,        debugcalibre   )
    g.connect_by_name( drc,            debugcalibre   )
    g.connect_by_name( lvs,            debugcalibre   )

    #-----------------------------------------------------------------------
    # Parameterize
    #-----------------------------------------------------------------------

    g.update_params( parameters )

    ####
    # modify script order for init
    ####

    order = init.get_param('order')  # get the default script run order

    # Add 'set-geom-vars.tcl' at the beginning
    order.insert(0, 'set-geom-vars.tcl')

    init.update_params({'order': order})

    ####
    # modify script order for power
    ####

    order = power.get_param('order')  # get the default script run order

    # Add 'set-geom-vars.tcl' at the beginning
    order.insert(0, 'set-geom-vars.tcl')

    power.update_params({'order': order})
    postroute_hold.update_params({'hold_target_slack' : parameters['hold_target_slack']}, allow_new=True) 

    return g


if __name__ == '__main__':
    g = construct()
#    g.plot()

