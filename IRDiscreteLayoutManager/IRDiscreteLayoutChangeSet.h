//
//  IRDiscreteLayoutChangeSet.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/22/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

enum  {
  
	IRDiscreteLayoutItemChangeInserting,
  IRDiscreteLayoutItemChangeDeleting,
	IRDiscreteLayoutItemChangeRelayout,	//	As long as the result from the layout blocks eval differently, this will be used on everlasting items
	IRDiscreteLayoutItemChangeNone
	
}; typedef NSUInteger IRDiscreteLayoutItemChangeType;

@class IRDiscreteLayoutGrid;
@interface IRDiscreteLayoutChangeSet : NSObject

+ (id) changeSetFromGrid:(IRDiscreteLayoutGrid *)fromGrid toGrid:(IRDiscreteLayoutGrid *)toGrid;
- (id) initWithSourceGrid:(IRDiscreteLayoutGrid *)fromGrid destinationGrid:(IRDiscreteLayoutGrid *)toGrid;

- (void) enumerateChangesWithBlock:(void(^)(id item, IRDiscreteLayoutItemChangeType changeType))block;

@end
