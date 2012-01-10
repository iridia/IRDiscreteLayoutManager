//
//  IRDiscreteLayoutManager.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutManager.h"

@interface IRDiscreteLayoutManager ()

@property (nonatomic, readwrite, retain) NSArray *currentlyConsumedItems;
@property (nonatomic, readwrite, retain) NSMutableDictionary *sessionDictionary;

@end


@implementation IRDiscreteLayoutManager

@synthesize dataSource, delegate, result;
@synthesize currentlyConsumedItems, sessionDictionary;

- (void) dealloc {

	[result release];
	[currentlyConsumedItems release];
	[sessionDictionary release];
	
	[super dealloc];

}

- (IRDiscreteLayoutResult *) calculatedResult {

	NSParameterAssert(self.dataSource);
	NSParameterAssert(self.delegate);
	
	self.currentlyConsumedItems = [NSArray array];
	self.sessionDictionary = [NSMutableDictionary dictionary];
	
	NSMutableArray *returnedGrids = [NSMutableArray array];
	NSUInteger numberOfItems = [self.dataSource numberOfItemsForLayoutManager:self];
	
	__block IRDiscreteLayoutGrid *currentGrid = nil;
	__block NSMutableArray *currentItems = nil;
	__block BOOL stop = NO;

	NSUInteger numberOfGrids = [self.delegate numberOfLayoutGridsForLayoutManager:self];
	
	IRDiscreteLayoutGrid * (^randomGrid)() = ^ {
	
		if (!numberOfGrids)
			return (IRDiscreteLayoutGrid *)nil;
		
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
		
		NSUInteger oldCurrentItemsCount = [currentItems count];
		
		if (!oldCurrentItemsCount) {
			stop = YES;
			continue;
		}
		
		[currentGrid enumerateLayoutAreasWithBlock: ^ (NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
			
			if (!item)
				return;
		
			[[self mutableArrayValueForKey:@"currentlyConsumedItems"] addObject:item];
			[currentItems removeObject:item];
			
		}];
		
		if (![currentItems count] || (oldCurrentItemsCount == [currentItems count])) {
			stop = YES;
		}
		
		[returnedGrids addObject:currentGrid];
		currentGrid = nil;
		
	}
	
	return [IRDiscreteLayoutResult resultWithGrids:returnedGrids];

}

@end
