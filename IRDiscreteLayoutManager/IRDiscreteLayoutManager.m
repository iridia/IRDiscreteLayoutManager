//
//  IRDiscreteLayoutManager.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutManager.h"

@implementation IRDiscreteLayoutManager

@synthesize dataSource, delegate, result;

- (void) dealloc {

	[result release];
	[super dealloc];

}

- (IRDiscreteLayoutResult *) calculatedResult {

	NSParameterAssert(self.dataSource);
	NSParameterAssert(self.delegate);
	
	NSMutableArray *grids = [NSMutableArray array];
	NSUInteger numberOfItems = [self.dataSource numberOfItemsForLayoutManager:self];
	
	BOOL delegateHandlesGridOverride = [self.delegate respondsToSelector:@selector(layoutManager:nextGridForContentsUsingGrid:)];
	
	
	IRDiscreteLayoutGrid * (^randomGrid)() = ^ {
	
		NSLog(@"%s TBD", __PRETTY_FUNCTION__);
	
		return (IRDiscreteLayoutGrid *)nil;
	
	};
	
	IRDiscreteLayoutGrid * (^nextGridPrototype)() = ^ {
	
		IRDiscreteLayoutGrid *tentativeGrid = randomGrid();
	
		if (!delegateHandlesGridOverride)
			return tentativeGrid;
		else
			return [self.delegate layoutManager:self nextGridForContentsUsingGrid:tentativeGrid];
	
	};
	
	
	__block IRDiscreteLayoutGrid *currentGrid = nil;
	__block NSMutableArray *currentItems = nil;
	__block BOOL stop = NO;
	
	void (^stashGridAndItems)() = ^ {
		
		[currentItems enumerateObjectsUsingBlock: ^ (id<IRDiscreteLayoutItem> anItem, NSUInteger idx, BOOL *stop) {
			[currentGrid setLayoutItem:anItem forAreaNamed:[currentGrid.layoutAreaNames objectAtIndex:idx]];
		}];
		currentItems = nil;

		[grids addObject:currentGrid];
		currentGrid = nil;
		
	};
	
	for (NSUInteger index = 0; ((index < numberOfItems) && !stop); index ++) {
	
		if (!currentGrid)
			currentGrid = [nextGridPrototype() instantiatedGrid];
		
		if (!currentItems)
			currentItems = [NSMutableArray arrayWithCapacity:[currentGrid numberOfLayoutAreas]];
		
		id<IRDiscreteLayoutItem> item = [self.dataSource layoutManager:self itemAtIndex:index];
		[currentItems addObject:item];
		
		if ([currentGrid numberOfLayoutAreas] == [currentItems count])
			stashGridAndItems();
	
	};
	
	stashGridAndItems();
	
	
	return [IRDiscreteLayoutResult resultWithGrids:grids];

}

@end
