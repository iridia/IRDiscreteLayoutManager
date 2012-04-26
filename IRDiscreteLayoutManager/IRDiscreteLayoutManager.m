//
//  IRDiscreteLayoutManager.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutError.h"
#import "IRDiscreteLayoutManager.h"
#import "IRDiscreteLayoutChangeSet.h"
#import "IRDiscreteLayoutGridCandidateInfo.h"

@implementation IRDiscreteLayoutManager

@synthesize dataSource, delegate;

- (void) dealloc {

	[super dealloc];

}

- (IRDiscreteLayoutResult *) calculatedResult {

	return [self calculatedResultWithReference:nil strategy:IRDefaultLayoutStrategy error:nil];

}

- (IRDiscreteLayoutResult *) calculatedResultWithReference:(IRDiscreteLayoutResult *)lastResult strategy:(IRDiscreteLayoutStrategy)strategy error:(NSError **)outError {

	NSParameterAssert(self.dataSource);
	NSParameterAssert(self.delegate);
	
	outError = outError ? outError : &(NSError *){ nil };
	
	NSUInteger const numberOfItems = [self.dataSource numberOfItemsForLayoutManager:self];
	NSUInteger const numberOfGrids = [self.delegate numberOfLayoutGridsForLayoutManager:self];
	
	if (!numberOfItems || !numberOfGrids) {
		*outError = IRDiscreteLayoutError(IRDiscreteLayoutGenericError, @"No items or layout grids exist for use.", nil);
		return nil;
	}
	
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
			
			//	Not allowing empti-ness instances
			
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
						*outError = IRDiscreteLayoutError(IRDiscreteLayoutManagerPrototypeSearchFailureError, @"Unable to find an eligible layout grid prototype for leftover layout items during random grid election.", nil);
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
				IRDiscreteLayoutGrid *lastGridContainingHeadItem = [lastResult gridContainingItem:headItem];
				
				NSMutableArray *allCandidateInfos = [NSMutableArray array];
			
				for (NSUInteger i = 0; i < numberOfGrids; i++) {
					
					IRDiscreteLayoutGrid *prototype = [self.delegate layoutManager:self layoutGridAtIndex:i];
					NSIndexSet *indices = nil;
					IRDiscreteLayoutGrid *instance = instanceFromPrototype(prototype, NO, &indices);
					
					if (instance) {
					
						IRDiscreteLayoutGridCandidateInfo *candidateInfo = [IRDiscreteLayoutGridCandidateInfo infoWithGrid:instance itemIndices:indices referenceGrid:lastGridContainingHeadItem delegateIndex:i];
						
						[allCandidateInfos addObject:candidateInfo];
						
					}
					
				}
				
				NSArray *candidates = [allCandidateInfos sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
				
					[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO],
					[NSSortDescriptor sortDescriptorWithKey:@"delegateIndex" ascending:YES],
				
				nil]];
				
				if (![candidates count]) {
					*outError = IRDiscreteLayoutError(IRDiscreteLayoutManagerPrototypeSearchFailureError, @"Unable to find an eligible layout grid prototype for leftover layout items during scored grid election.", nil);
					return nil;
				}
				
				IRDiscreteLayoutGridCandidateInfo *foundCandidateInfo = ((^ {
				
					CGFloat bestScore = ((IRDiscreteLayoutGridCandidateInfo *)[candidates objectAtIndex:0]).score;
					
					NSArray *allBestCandidates = [candidates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(IRDiscreteLayoutGridCandidateInfo *aCandidate, NSDictionary *bindings) {
						return aCandidate.score == bestScore;
					}]];
					
					return [allBestCandidates objectAtIndex:arc4random_uniform([allBestCandidates count])];
				
				})());
				
				IRDiscreteLayoutGrid *foundGrid = foundCandidateInfo.grid;
				
				if ([self.delegate respondsToSelector:@selector(layoutManager:targetGridForEnqueueingProposedGrid:fromCandidates:toResult:)]) {
				
					IRDiscreteLayoutResult *interimResult = [IRDiscreteLayoutResult resultWithGrids:returnedGrids];
					
					NSMutableArray *allFoundGrids = [NSMutableArray arrayWithCapacity:[candidates count]];
					for (IRDiscreteLayoutGridCandidateInfo *candidateInfo in candidates)
						[allFoundGrids addObject:candidateInfo.grid];
					
					IRDiscreteLayoutGrid *overriddenGrid = [self.delegate layoutManager:self targetGridForEnqueueingProposedGrid:foundGrid fromCandidates:allFoundGrids toResult:interimResult];
					
					if (overriddenGrid != foundGrid) {
					
						for (IRDiscreteLayoutGridCandidateInfo *candidateInfo in candidates) {
						
							if (candidateInfo.grid == overriddenGrid) {
								
								foundCandidateInfo = candidateInfo;
								break;
								
							}
						
						}
					
					}
					
					foundGrid = overriddenGrid;
					
				}
				
				[leftoverItemIndices removeIndexes:foundCandidateInfo.itemIndices];
				[returnedGrids addObject:foundCandidateInfo.grid];
				
				break;
			
			}
			
		}
		
		//	Post condition: must have exhausted some items
		//	We might allow empty pages in the future, but not now.  If you want them, deal with them at the calling site.
		
		if (lastLeftoverItemIndicesCount == [leftoverItemIndices count]) {
			*outError = IRDiscreteLayoutError(IRDiscreteLayoutManagerItemExhaustionFailureError, @"Unable to exhaust all layout items during random grid election.", nil);
			return nil;
		}
	
	}
		
	IRDiscreteLayoutResult *result = [IRDiscreteLayoutResult resultWithGrids:returnedGrids];
	
	return result;

}

@end
