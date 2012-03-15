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
		
	currentItems = [NSMutableArray arrayWithCapacity:numberOfItems];
	for (NSUInteger index = 0; ((index < numberOfItems) && !stop); index ++) {
		
		id<IRDiscreteLayoutItem> item = [self.dataSource layoutManager:self itemAtIndex:index];
		[currentItems insertObject:item atIndex:index];
		
	}
	
	while (!stop) {
	
		NSLog(@"starting new layout loop for the next page");
	
		NSMutableIndexSet *attemptedPrototypeIndices = [NSMutableIndexSet indexSet];
		BOOL canEnumerate = YES;
		
		while (canEnumerate) {
		
			//	If all the grids have been tried, we have no luck left
			
			if ([attemptedPrototypeIndices containsIndexesInRange:(NSRange){ 0, numberOfGrids }]) {
			
				NSLog(@"can not emuerate, attempted indices is full");
			
				canEnumerate = NO;
				continue;
			
			}
			
			IRDiscreteLayoutGrid * (^randomGrid)() = ^ {
			
				if (!numberOfGrids)
					return (IRDiscreteLayoutGrid *)nil;
				
				NSUInteger randomIndex = (arc4random() % [self.delegate numberOfLayoutGridsForLayoutManager:self]);
				return [self.delegate layoutManager:self layoutGridAtIndex:randomIndex];
				
			};
			
			BOOL (^gridHasBeenAttempted)(IRDiscreteLayoutGrid *, NSUInteger *) = ^ (IRDiscreteLayoutGrid *grid, NSUInteger *outIndex) {

				NSInteger index = [self.delegate layoutManager:self indexOfLayoutGrid:grid];
				NSParameterAssert(index != NSNotFound);
				
				if (outIndex)
					*outIndex = (NSUInteger)index;
				
				return (BOOL)[attemptedPrototypeIndices containsIndex:(NSUInteger)index];
			
			};
		
			IRDiscreteLayoutGrid * (^nextGridPrototype)() = ^ {
			
				IRDiscreteLayoutGrid *tentativeGrid = randomGrid();
				
				if ([self.delegate respondsToSelector:@selector(layoutManager:nextGridForContentsUsingGrid:)]) {
					
					IRDiscreteLayoutGrid *delegateAnswer = [self.delegate layoutManager:self nextGridForContentsUsingGrid:tentativeGrid];
					
					if (!gridHasBeenAttempted(delegateAnswer, NULL))
						return delegateAnswer;
					
				}
				
				return tentativeGrid;
				
			};
			
			IRDiscreteLayoutGrid *nextPrototype = nextGridPrototype();
			NSUInteger index = NSNotFound;
			
			if (gridHasBeenAttempted(nextPrototype, &index)) {
				NSLog(@"skipping grid at %i because it has been tried", index);
				continue;
			}
			
			[attemptedPrototypeIndices addIndex:(NSUInteger)index];
			
			NSLog(@"layout manager trying prototype %@ at index %i", nextPrototype, index);
			currentGrid = [nextPrototype instantiatedGridWithAvailableItems:currentItems];
			if (currentGrid) {
				canEnumerate = NO;
				NSLog(@"prototype at index %i was instantiated", index);
				continue;
			}
			
			NSLog(@"prototype at index %i failed to instantiate", index);
			
		}
		
		if (!currentGrid) {
			NSLog(@"failure to instantiate terminates loop early");
			stop = YES;
			continue;
		}
		
		NSUInteger oldCurrentItemsCount = [currentItems count];
		
		if (!oldCurrentItemsCount) {
			NSLog(@"failure to consume more items terminates loop early");
			stop = YES;
			continue;
		}
		
		[currentGrid enumerateLayoutAreasWithBlock: ^ (NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
			
			if (!item)
				return;
		
			[[self mutableArrayValueForKey:@"currentlyConsumedItems"] addObject:item];
			[currentItems removeObject:item];
			
		}];
		
		if (![currentItems count])
			stop = YES;
		
//		if (![currentItems count] || (oldCurrentItemsCount == [currentItems count])) {
//			stop = YES;
//		}
		
		[returnedGrids addObject:currentGrid];
		currentGrid = nil;
		
	}
	
	//	No item left behind
	NSAssert1(![currentItems count], @"Layout must consume all items; items left are %@", currentItems);
	
	return [IRDiscreteLayoutResult resultWithGrids:returnedGrids];

}

@end
