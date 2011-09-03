#	IRDiscreteLayoutManager

Evadne Wu at Iridia Productions, 2011.

**This project is under heavy progress and should not be used in production yet, although it has already been actively used in production by ourselves.**  The discrete layout manager is an experimental layout manager for providing information that can be used to display discrete layout objects on an iPad.  Although theoretically it might also work on an iPhone, the limited display size makes it somewhat impractical.

All the stuff in the repository is under the new BSD license unless otherwise specified.


## Overview

There are very few classes in this project.  Generally, the identically-named `IRDiscreteLayoutManager` is where all the action happens.  It holds a data source which is responsible for managing items that can appear on the screen, and a delegate which is mainly responsible about their presentation, besides potentially affecting its layout behavior.

The minimal unit of output by the layout manager is one **discrete layout grid (`IRDiscreteLayoutGrid`)**.  Grids are either prototype grids, to whom **layout areas** can be added, or instantiated grids, whose layout areas are locked, but can hold real content.


## Layout areas

A layout area is the minimal constructive unit of a layout grid, as a grid prototype without any layout areas is useless.  Every single layout area holds an item, but its presentation is not hard-coded nor predetermined.

When adding layout areas to a layout grid prototype, one can specify a **layout block**, a **display block** and a **validator block**.  All these blocks are used by the layout manager, and mostly only during layout calculation.  All the blocks are given the current grid (of the layout area that the blocks are associated with), and the prospective item that would be filled in the grid.  The difference is in their returned values, and thus their main responsibilities: the **validator block** potentially vetoes an item from being placed in the grid, the **layout block** returns a `CGRect` which is the recommended layout area frame, and the **display block** returns a new view that is suitable for use on-screen, with the bounds returned by the layout block.

The layout manager does not cache or store anything.  The layout results is always re-calculated on-demand, via `-[IRDiscreteLayoutManager calculatedResult]`.  Currently, the result object only holds a bunch of instantiated grids, since all other functionalities are already fulfilled thru composition.


## Transforming between grids

The **Transforming additions** is added to the layout grid, by providing an internal store that binds two layout areas in distinct layout grid prototypes together.  If all layout areas in a layout grid prototype can be associated with a different and unique layout area in another layout grid, the two grids are inter-transformable.  Firing `-allTransformablePrototypeDestinations` on a grid returns all transformation destinations — all the other grid prototypes that the current grid can transform into.  This is useful for cases where the final layout needs to respond to device orientation changes efficiently.

Calling `-transformedGridWithPrototype:` on any grid, using any of its transformation destinations, returns a newly populated instantiated grid that can be immediately used for relayout.  Simply enumerating thru the layout areas, invoking the layout blocks and using the returned values on existing subviews, re-layouts everything relatively effortlessly.


## Upcoming plans for the project

* Supporting out-of-order layout items
* Granular item scoring / context-sensitive ordering
* Finish the sample app
