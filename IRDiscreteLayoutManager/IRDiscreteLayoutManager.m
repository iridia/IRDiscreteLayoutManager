//
//  IRDiscreteLayoutManager.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutManager.h"


@implementation IRDiscreteLayoutManager

@synthesize dataSource, delegate;

- (void) dealloc {

	[super dealloc];

}

- (IRDiscreteLayoutResult *) calculatedResult {

	NSError *error = nil;
	IRDiscreteLayoutResult *result = [self calculatedResultWithReference:nil strategy:IRDefaultLayoutStrategy error:&error];
	
	if (!result)
		NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
	
	return result;

}

- (IRDiscreteLayoutResult *) calculatedResultWithReference:(IRDiscreteLayoutResult *)lastResult strategy:(IRDiscreteLayoutStrategy)strategy error:(NSError **)outError {

	NSParameterAssert(self.dataSource);
	NSParameterAssert(self.delegate);
	
	outError = outError ? outError : &(NSError *){ nil };
	
	NSUInteger const numberOfItems = [self.dataSource numberOfItemsForLayoutManager:self];
	NSUInteger const numberOfGrids = [self.delegate numberOfLayoutGridsForLayoutManager:self];
	
	if (!numberOfItems || !numberOfGrids)
		return nil;
	
	NSMutableIndexSet *leftoverItemIndices = [NSMutableIndexSet indexSetWithIndexesInRange:(NSRange){ 0, numberOfItems }];
	NSMutableArray *returnedGrids = [NSMutableArray array];
	
	IRDiscreteLayoutGrid * (^instanceFromPrototype)(IRDiscreteLayoutGrid *, BOOL) = ^ (IRDiscreteLayoutGrid *prototype, BOOL dequeueUsedItems) {
	
		//	If dequeueUsedItems is YES, removes item indices from the leftover index set too
	
		NSParameterAssert(!prototype.prototype);
		
		NSUInteger const numberOfAreas = [prototype numberOfLayoutAreas];
		NSAssert1(numberOfAreas, @"Grid %@ must contain at least one layout area available for item association.", prototype);
		
		NSUInteger *itemIndices = malloc(sizeof(NSUInteger) * numberOfAreas);
		NSUInteger numberOfUsedItems = [leftoverItemIndices getIndexes:itemIndices maxCount:numberOfAreas inIndexRange:NULL];
		
		IRDiscreteLayoutGrid *instance = [prototype instantiatedGridWithAvailableItems:((^ {
		
			NSMutableArray *	prospectiveItems = [NSMutableArray arrayWithCapacity:numberOfUsedItems];
			for (unsigned int i = 0; i < numberOfUsedItems; i++)
				[prospectiveItems addObject:[self.dataSource layoutManager:self itemAtIndex:itemIndices[i]]];
			
			return prospectiveItems;
			
		})())];
		
		free(itemIndices);
		
		if (instance && dequeueUsedItems) {
			
			[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
				
				if (item) {
					
					NSUInteger itemIndex = [self.dataSource layoutManager:self indexOfLayoutItem:item];
					NSParameterAssert(itemIndex != NSNotFound);
					NSParameterAssert([leftoverItemIndices containsIndex:itemIndex]);
					
					[leftoverItemIndices removeIndex:itemIndex];
					
				}
				
			}];
	
		}
		
		return instance;
	
	};
	
	//	Grid prototype tracking should be hoisted out from the default block backing the random layout strategy.
	//	We can share the tracking code any way.
		
	while ([leftoverItemIndices count]) {
	
		NSUInteger const lastLeftoverItemIndicesCount = [leftoverItemIndices count];
				
		switch (strategy) {
			
			case IRRandomLayoutStrategy: {
				
				NSMutableIndexSet * availableLayoutGridPrototypeIndices = [NSMutableIndexSet indexSetWithIndexesInRange:(NSRange){ 0, numberOfGrids }];
				
				__block IRDiscreteLayoutGrid * (^randomGrid)(NSUInteger *) = [[^ (NSUInteger *outIndex) {
			
					outIndex = outIndex ? outIndex : &(NSUInteger){ 0 };
					
					if (![availableLayoutGridPrototypeIndices count]) {
						*outIndex = NSNotFound;
						return (IRDiscreteLayoutGrid *)nil;
					}
					
					NSUInteger index = (arc4random() % numberOfGrids);
					if (![availableLayoutGridPrototypeIndices containsIndex:index])
						return randomGrid(outIndex);
					
					*outIndex = index;
					return [self.delegate layoutManager:self layoutGridAtIndex:index];
					
				} copy] autorelease];
				
				BOOL hasFoundValidGrid = NO;
				while (!hasFoundValidGrid) {
					
					//	Iterate thru all the valid grids, which is not already used
				
					NSUInteger foundGridIndex = NSNotFound;
					IRDiscreteLayoutGrid * const foundGrid = randomGrid(&foundGridIndex);
					
					if (!foundGrid) {
						*outError = IRDiscreteLayoutManagerError(IRDiscreteLayoutManagerPrototypeSearchFailureError, @"Unable to find an eligible layout grid prototype for leftover layout items during random grid election.");
						return nil;
					}
					
					[availableLayoutGridPrototypeIndices removeIndex:foundGridIndex];
					
					
					
					IRDiscreteLayoutGrid *instance = instanceFromPrototype(foundGrid, YES);
					
					if (instance) {
					
						[returnedGrids addObject:instance];
						hasFoundValidGrid = YES;
										
					}

				}
			
				break;
			
			}
		
			case IRCompareScoreLayoutStrategy: {
			
				//	Instantiate then compare.  Those that could not be instantiated will get left out.
				
//				NSMutableSet *instances = [NSMutableSet setWithCapacity:numberOfGrids];
//				for (NSUInteger i = 0; i < numberOfGrids; i++) {
//					IRDiscreteLayoutGrid *instance =
//				}
				
				break;
			
			}
			
		}
		
		//	Post condition: must have exhausted some items
		//	We might allow empty pages in the future, but not now.  If you want them, deal with them at the calling site.
		
		if (lastLeftoverItemIndicesCount == [leftoverItemIndices count]) {
			*outError = IRDiscreteLayoutManagerError(IRDiscreteLayoutManagerItemExhaustionFailureError, @"Unable to exhaust all layout items during random grid election.");
			return nil;
		}
	
	}
		
	return [IRDiscreteLayoutResult resultWithGrids:returnedGrids];

}

@end


NSError * IRDiscreteLayoutManagerError (NSUInteger code, NSString *description) {

	return [NSError errorWithDomain:IRDiscreteLayoutGridErrorDomain code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
	
		description, NSLocalizedDescriptionKey,
	
	nil]];

}

NSString * const IRDiscreteLayoutManagerErrorDomain = @"com.iridia.discreteLayout.layoutManager";
NSUInteger IRDiscreteLayoutManagerGenericError = 0;;
NSUInteger IRDiscreteLayoutManagerItemExhaustionFailureError = 1;
NSUInteger IRDiscreteLayoutManagerPrototypeSearchFailureError = 2;
