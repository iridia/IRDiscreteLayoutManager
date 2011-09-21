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
	
	NSMutableArray *returnedGrids = [NSMutableArray array];
	NSUInteger numberOfItems = [self.dataSource numberOfItemsForLayoutManager:self];
	
	__block IRDiscreteLayoutGrid *currentGrid = nil;
	__block NSMutableArray *currentItems = nil;
	__block BOOL stop = NO;

	IRDiscreteLayoutGrid * (^randomGrid)() = ^ {
		
		NSUInteger randomIndex = (arc4random() % [self.delegate numberOfLayoutGridsForLayoutManager:self]);
		return [self.delegate layoutManager:self layoutGridAtIndex:randomIndex];
		
	};
	
	IRDiscreteLayoutGrid * (^nextGridPrototype)() = ^ {
	
		IRDiscreteLayoutGrid *tentativeGrid = randomGrid();
		
		if ([self.delegate respondsToSelector:@selector(layoutManager:nextGridForContentsUsingGrid:)])
			return [self.delegate layoutManager:self nextGridForContentsUsingGrid:tentativeGrid];
		
		return tentativeGrid;
		
	};
	
	currentItems = [NSMutableArray arrayWithCapacity:numberOfItems];
	for (NSUInteger index = 0; ((index < numberOfItems) && !stop); index ++) {
		
		id<IRDiscreteLayoutItem> item = [self.dataSource layoutManager:self itemAtIndex:index];
		[currentItems insertObject:item atIndex:index];
		
	}
	
	while (!stop) {
		
		if (!currentGrid)
			currentGrid = [nextGridPrototype() instantiatedGridWithAvailableItems:currentItems];
			
		if (!currentGrid) {
			stop = YES;
			continue;
		}
		
		[currentGrid enumerateLayoutAreasWithBlock: ^ (NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
			[currentItems removeObject:item];
		}];
		
		[returnedGrids addObject:currentGrid];
		currentGrid = nil;
		
		if (![currentItems count]) {
			stop = YES;
			continue;
		}
		
	}
	
	return [IRDiscreteLayoutResult resultWithGrids:returnedGrids];

}

@end
