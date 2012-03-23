//
//  IRDiscreteLayoutManager.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutManager.h"
#import "IRDiscreteLayoutChangeSet.h"


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
	
	IRDiscreteLayoutGrid * (^instanceFromPrototype)(IRDiscreteLayoutGrid *, BOOL, NSIndexSet **) = ^ (IRDiscreteLayoutGrid *prototype, BOOL dequeueUsedItems, NSIndexSet **usedItemIndices) {
	
		//	If dequeueUsedItems is YES, removes item indices from the leftover index set too
	
		NSParameterAssert(!prototype.prototype);
		
		//	We don’t want to give the grid too many items to use, but we still want them to skip some items for convenience.
		//	Currently, the maximum number of skipped items is hard coded to 20 — we’ll overprovision grid instantiation
		
		NSAssert1([prototype numberOfLayoutAreas] > 0, @"Grid %@ must contain at least one layout area available for item association.", prototype);
		
		NSUInteger const prospectiveItemsCount = [prototype numberOfLayoutAreas] + 20;
		NSUInteger *itemIndices = malloc(sizeof(NSUInteger) * prospectiveItemsCount);
		NSUInteger numberOfProvidedItems = [leftoverItemIndices getIndexes:itemIndices maxCount:prospectiveItemsCount inIndexRange:NULL];
		
		NSArray *providedLayoutItems = ((^ {
		
			NSMutableArray *prospectiveItems = [NSMutableArray arrayWithCapacity:numberOfProvidedItems];
			for (unsigned int i = 0; i < numberOfProvidedItems; i++)
				[prospectiveItems addObject:[self.dataSource layoutManager:self itemAtIndex:itemIndices[i]]];
			
			return prospectiveItems;
		
		})());
		
		IRDiscreteLayoutGrid *instance = [prototype instantiatedGridWithAvailableItems:providedLayoutItems];
		
		if (instance) {

			NSMutableIndexSet *outIndices = usedItemIndices ? [NSMutableIndexSet indexSet] : nil;
			
			[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
				
				if (item) {
					
					NSUInteger itemIndex = [self.dataSource layoutManager:self indexOfLayoutItem:item];
					NSParameterAssert(itemIndex != NSNotFound);
					NSParameterAssert([leftoverItemIndices containsIndex:itemIndex]);
					
					[outIndices addIndex:itemIndex];
					
					if (dequeueUsedItems) {

						[leftoverItemIndices removeIndex:itemIndex];
					
					}
					
				}
				
			}];
			
			if (usedItemIndices)
				*usedItemIndices = [[outIndices copy] autorelease];
			
		}
		
		free(itemIndices);
		
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
					
					IRDiscreteLayoutGrid *instance = instanceFromPrototype(foundGrid, YES, nil);
					
					if (instance) {
					
						[returnedGrids addObject:instance];
						hasFoundValidGrid = YES;
										
					}

				}
			
				break;
			
			}
		
			case IRCompareScoreLayoutStrategy: {
			
				id <IRDiscreteLayoutItem> headItem = [self.dataSource layoutManager:self itemAtIndex:[leftoverItemIndices firstIndex]];
				
				IRDiscreteLayoutGrid *lastGridContainingHeadItem = ((^ {
					
					__block IRDiscreteLayoutGrid *foundGrid = nil;
					
					for (IRDiscreteLayoutGrid *grid in lastResult.grids) {
						
						[grid enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
						
							if (foundGrid)
								return;
						
							if (item == headItem) {
								foundGrid = grid;
							}
							
						}];
						
					};
					
					return foundGrid;
					
				})());
			
				NSMutableDictionary *instancesToScores = [NSMutableDictionary dictionaryWithCapacity:numberOfGrids];
				NSMutableDictionary *instancesToItemIndices = [NSMutableDictionary dictionaryWithCapacity:numberOfGrids];
				
				for (NSUInteger i = 0; i < numberOfGrids; i++) {
					
					IRDiscreteLayoutGrid *prototype = [self.delegate layoutManager:self layoutGridAtIndex:i];
					NSIndexSet *instanceItemIndices = nil;
					IRDiscreteLayoutGrid *instance = instanceFromPrototype(prototype, NO, &instanceItemIndices);
					
					if (instance) {
					
						NSValue *instanceValue = [NSValue valueWithNonretainedObject:instance];
						
						if (instanceItemIndices)
							[instancesToItemIndices	 setObject:instanceItemIndices forKey:instanceValue];
					
						__block float_t instanceScore = 0;	//	TBD: Fix Me
						
						//	Several aspects affect the score of the instance.
						
						if (lastGridContainingHeadItem) {
						
							//	For now it’s a pretty simple “take one point off if changed” algorithm
						
							IRDiscreteLayoutChangeSet *changeSet = [IRDiscreteLayoutChangeSet changeSetFromGrid:lastGridContainingHeadItem toGrid:instance];
							
							[changeSet enumerateChangesWithBlock:^(id item, IRDiscreteLayoutItemChangeType changeType) {
							
								switch (changeType) {
								
									case IRDiscreteLayoutItemChangeDeleting:
									case IRDiscreteLayoutItemChangeInserting: {
										instanceScore -= 1;
										break;
									}
									
									case IRDiscreteLayoutItemChangeRelayout:
									case IRDiscreteLayoutItemChangeNone: {
										break;
									}
								
								}
								
							}];
						
						}
						
						
						//	instanceItemIndices contains a bunch of item indices; find seams and detract score for each seam in space
						
						__block NSUInteger lastIndex = NSNotFound;
						
						[instanceItemIndices enumerateIndexesUsingBlock: ^ (NSUInteger idx, BOOL *stop) {
						
							if (lastIndex != NSNotFound)
							if (idx != (lastIndex + 1))
								instanceScore -= 1;
							
						}];
						
						
						//	A bunch of other faithful assumptions: having instantiated, more checks in place means more specificality
						
						[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
						
							if (validatorBlock)
								instanceScore += 1;
							
							if (layoutBlock)
								instanceScore += 1;
							
						}];
						
						[instancesToScores setObject:[NSNumber numberWithFloat:instanceScore] forKey:instanceValue];
						
					}
					
				}
				
				NSArray *sortedScores = [[instancesToScores allValues] sortedArrayUsingSelector:@selector(compare:)];
				if (![sortedScores count]) {
					*outError = IRDiscreteLayoutManagerError(IRDiscreteLayoutManagerPrototypeSearchFailureError, @"Unable to find an eligible layout grid prototype for leftover layout items during scored grid election.");
					return nil;
				}
				
				NSArray *allInstanceValues = [instancesToScores allKeysForObject:[sortedScores objectAtIndex:0]];
				if ([allInstanceValues count] > 1)
					NSLog(@"%s: ambiguous scoring among candidate instances %@", __PRETTY_FUNCTION__, allInstanceValues);
				
				NSValue *foundInstanceValue = [allInstanceValues objectAtIndex:0];
				IRDiscreteLayoutGrid *foundInstance = (IRDiscreteLayoutGrid *)[foundInstanceValue nonretainedObjectValue];
				if (foundInstance) {

					NSIndexSet *itemIndices = [instancesToItemIndices objectForKey:foundInstanceValue];
					if (itemIndices) {
						[leftoverItemIndices removeIndexes:itemIndices];
					}
					
					[returnedGrids addObject:foundInstance];
				
				}
				
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
