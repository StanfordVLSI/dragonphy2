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
        DRAGONPHY_PROCESS = 'FREEPDK45'

    g = Graph()

    #-----------------------------------------------------------------------
    # Parameters
    #-----------------------------------------------------------------------

    parameters = {
        'construct_path': __file__,
        'design_name': 'weight_manager',
        'topographical': True
    }

    if DRAGONPHY_PROCESS == 'FREEPDK45':
        parameters['adk_name'] = 'freepdk-45nm'
        parameters['adk_view'] = 'view-standard'
        parameters['clock_period'] = 7.0
    elif DRAGONPHY_PROCESS == 'TSMC16':
        parameters['adk_name'] = 'tsmc16'
        parameters['adk_view'] = 'stdview'
        parameters['clock_period'] = 0.7
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
    constraints = Step(this_dir + '/constraints')
    dc = Step(this_dir + '/synopsys-dc-synthesis')

    # Default steps

    info           = Step( 'info',                           default=True )
    iflow          = Step( 'cadence-innovus-flowsetup',      default=True )
    init           = Step( 'cadence-innovus-init',           default=True )
    power          = Step( 'cadence-innovus-power',          default=True )
    place          = Step( 'cadence-innovus-place',          default=True )
    cts            = Step( 'cadence-innovus-cts',            default=True )
    postcts_hold   = Step( 'cadence-innovus-postcts_hold',   default=True )
    route          = Step( 'cadence-innovus-route',          default=True )
    postroute      = Step( 'cadence-innovus-postroute',      default=True )
    postroute_hold = Step( 'cadence-innovus-postroute_hold', default=True )
    signoff        = Step( 'cadence-innovus-signoff',        default=True )
    genlibdb       = Step( 'synopsys-ptpx-genlibdb',         default=True )
    gdsmerge       = Step( 'mentor-calibre-gdsmerge',        default=True )
    drc            = Step( 'mentor-calibre-drc',             default=True )
    lvs            = Step( 'mentor-calibre-lvs',             default=True )
    debugcalibre   = Step( 'cadence-innovus-debug-calibre',  default=True )

    #-----------------------------------------------------------------------
    # Graph -- Add nodes
    #-----------------------------------------------------------------------

    g.add_step( info           )
    g.add_step( rtl            )
    g.add_step( constraints    )
    g.add_step( dc             )
    g.add_step( iflow          )
    g.add_step( init           )
    g.add_step( power          )
    g.add_step( place          )
    g.add_step( cts            )
    g.add_step( postcts_hold   )
    g.add_step( route          )
    g.add_step( postroute      )
    g.add_step( postroute_hold )
    g.add_step( signoff        )
    g.add_step( genlibdb       )
    g.add_step( gdsmerge       )
    g.add_step( drc            )
    g.add_step( lvs            )
    g.add_step( debugcalibre   )

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

    g.connect_by_name( init,           power          )
    g.connect_by_name( power,          place          )
    g.connect_by_name( place,          cts            )
    g.connect_by_name( cts,            postcts_hold   )
    g.connect_by_name( postcts_hold,   route          )
    g.connect_by_name( route,          postroute      )
    g.connect_by_name( postroute,      postroute_hold )
    g.connect_by_name( postroute_hold, signoff        )

    g.connect_by_name( signoff,        genlibdb       )
    g.connect_by_name( adk,            genlibdb       )

    g.connect_by_name( signoff,        gdsmerge       )

    g.connect_by_name( signoff,        drc            )
    g.connect_by_name( gdsmerge,       drc            )
    g.connect_by_name( signoff,        lvs            )
    g.connect_by_name( gdsmerge,       lvs            )

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

    return g


if __name__ == '__main__':
    g = construct()
#    g.plot()
