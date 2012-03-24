#	IRDiscreteLayoutManager

Evadne Wu at Iridia Productions, 2011–2012.

The Discrete Layout Manager helps create page-by-page layouts, each page showing multiple items.  It is specifically developed for use on an iPad, and is currently under active development and maintenance as of March 2012.

The Layout Manager requires a data source object, which provides items to show, and a delegate object which provides Layout Grid Prototypes, which specify how items may look like when composed together in a page.  The calculated Layout Result contains a series of Layout Grid Instances, each conceptually maps to an on-screen page and describes items within the page.

The entire project is under the new BSD license, and contributed code goes under the same license as well.


## Logistics

### Bootstrapping the Layout Manager

The recommended way to use the project is to link it into your project as a Git submodule, then add the Xcode project `IRDiscreteLayoutManager.xcodeproj` to your Xcode 4 Workspace.  After that, link the static library target `libIRDiscreteLayoutManager` with your app target, and configure **Header Search Paths** in your target so the compiler knows where to look for information when you use classes from the project.

To use the project, include the umbrella header where needed:

	#import "IRDiscreteLayout.h"


### Providing Layout Items

The central class in the project is `IRDiscreteLayoutManager`, which requires a Data Source object to provide items that could be used during layout computation.

**Layout Item** objects must conform to `<IRDiscreteLayoutItem>`, and there is an identically named base class which provides reference implementation.  The protocol itself is mainly a guideline to follow.
	
The Data Source must conform to `<IRDiscreteLayoutManagerDataSource>`.


### Defining Layout Grid Prototypes

**Layout Grid Prototypes** specify how a conceptual page could look like, where to put items, what items are allowed in each Layout Area, and a convenience for instantiating views ultimately responsible for presenting the items.

They are provided by the Layout Manager’s Delegate object, which must conform to `<IRDiscreteLayoutManagerDelegate>`.  The prototypes must inherit from class `IRDiscreteLayoutGrid`.

To prepare a prototype for use, register one or many **Layout Area**s within the grid.  Each area must hold an unique (among areas within the protoype) name which identifies the area, a **Layout Block** which dynamically calculates the containing rectangle of the item on the page, and a **Validator Block** which is allowed to deny certain items from being placed at certain places.

The **Display Block** is a convenience which returns a view instance backing the display of a particular item, but is not required for the prototype to work. 


#### Handling Portrait and Landscape orientations

To handle cases where it is desirable for content to present differently in Landscape and Portrait, use the **Layout Grid Transforming Additions** API defined in `IRDiscreteLayoutGrid(Transforming)`.  For each area in one grid, mark anothere area in the other grid as its equivalent.

If every single **Layout Area** in a prototype has an equivalent in another prototype, the two prototypes are considered *inter-transformable.*  In that case, calling `-transformedGridWithPrototype` on any instance of either grid returns a populated instance of the other grid prototype.

In cases where multiple **Layout Grid Prototype** instances are inter-transformable, or where it is desirable to add custom logic to determine the best prototype to use in a particular case, consider using `+allTransformablePrototypeDestinations`.


## Attribution & Contribution

The **Discrete Layout Manager** was originally created by Evadne Wu, affiliated with Iridia Productions and Waveface Inc.

To contribute, fork the project and send Pull Requests.  But before that, talk with Evadne (@evadne) if possible.  Also note that all code that gets pulled will fall under the BSD license as well.

We maintain a [Trello board](https://trello.com/board/irdiscretelayoutmanager/4f6c9027f212e5f32a3442bd) for the project, and we’ll track issues, features, bugs, and upcoming ideas there.
