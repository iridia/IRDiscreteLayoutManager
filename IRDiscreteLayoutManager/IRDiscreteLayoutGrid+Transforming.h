//
//  IRDiscreteLayoutGrid+Transforming.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

//	The Transforming additions to the layout grid allows relationships between two layout grid prototypes
//	As long as the two grid prototypes have fully fulfilled their layout area relationships, things will be fine

//	For example, if a prototype of 1024 by 768 and another prototype of 768 by 1024 have fully registered relationships
//	via [IRDiscreteLayoutGrid markAreaNamed:inGridPrototype:asEquivalentToAreaNamed:inGridPrototype:]
//	then during autorotation a newly filled grid can be substituted for landscape / portrait

#import "IRDiscreteLayoutGrid.h"

@interface IRDiscreteLayoutGrid (Transforming)

+ (void) markAreaNamed:(NSString *)aName inGridPrototype:(IRDiscreteLayoutGrid *)aGrid asEquivalentToAreaNamed:(NSString *)mappedName inGridPrototype:(IRDiscreteLayoutGrid *)mappedGrid;

- (NSSet *) allTransformablePrototypeDestinations;

- (IRDiscreteLayoutGrid *) transformedGridWithPrototype:(IRDiscreteLayoutGrid *)newGrid;

@end
