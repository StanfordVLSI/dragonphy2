# modified from GcdUnit full commercial example

import os

from mflowgen.components import Graph, Step

def construct():

  if 'DRAGONPHY_PROCESS' in os.environ:
      DRAGONPHY_PROCESS = os.environ['DRAGONPHY_PROCESS']
  else:
      DRAGONPHY_PROCESS = 'TSMC16'

  g = Graph()

  #-----------------------------------------------------------------------
  # Parameters
  #-----------------------------------------------------------------------

  adk_name = 'tsmc16'
  adk_view = 'stdview'

  parameters = {
    'construct_path' : __file__,
    'design_name'    : 'tx_top',
    'clock_period'   : 2.0,
    'adk'            : adk_name,
    'adk_view'       : adk_view,
    'topographical'  : True,
  }

  #-----------------------------------------------------------------------
  # Create nodes
  #-----------------------------------------------------------------------

  this_dir = os.path.dirname( os.path.abspath( __file__ ) )

  # ADK step

  g.set_adk( adk_name )
  adk = g.get_adk_step()

  # Custom steps

  rtl = Step( this_dir + '/rtl' )
  constraints = Step( this_dir + '/constraints' )
  dc = Step( this_dir + '/synopsys-dc-synthesis' )
  qtm = Step(this_dir + '/qtm')
  # Define blocks function

  blocks = []

  # Added steps for blackbox

  if DRAGONPHY_PROCESS == 'TSMC16':
      blocks += [
          Step( this_dir + '/output_buffer'     ),
          Step( this_dir + '/phase_interpolator'),
          Step( this_dir + '/termination'       ),
          Step( this_dir + '/input_divider'     ),
      ]

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

  dbs = [
        'output_buffer_lib.db',
        'phase_interpolator_lib.db',
        'termination_lib.db',
        'input_divider_lib.db'
  ]
  dc.extend_inputs(dbs)
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

  for block in blocks:
    g.add_step ( block )

  g.add_step( qtm )
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
  g.connect_by_name( adk, 	     qtm            )

  for block in blocks + [qtm]:
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
#  g.plot()

