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
	
	switch (strategy) {
		
		case IRRandomLayoutStrategy: {
		
			while ([leftoverItemIndices count]) {
			
				NSUInteger const lastLeftoverItemIndicesCount = [leftoverItemIndices count];
				
				//	TBD: now, layout!
				
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
					NSLog(@"finding grid");
					IRDiscreteLayoutGrid * const foundGrid = randomGrid(&foundGridIndex);
					if (!foundGrid) {
						*outError = IRDiscreteLayoutManagerError(IRDiscreteLayoutManagerPrototypeSearchFailureError, @"Unable to find an eligible layout grid prototype for leftover layout items during random grid election.");
						return nil;
					}
					
					[availableLayoutGridPrototypeIndices removeIndex:foundGridIndex];
					
					NSUInteger const numberOfAreas = [foundGrid numberOfLayoutAreas];
					NSAssert1(numberOfAreas, @"Grid %@ must contain at least one layout area available for item association.", foundGrid);
					
					NSUInteger *itemIndices = malloc(sizeof(NSUInteger) * numberOfAreas);
					NSUInteger numberOfUsedItems = [leftoverItemIndices getIndexes:itemIndices maxCount:numberOfAreas inIndexRange:NULL];
					
					IRDiscreteLayoutGrid *instance = [foundGrid instantiatedGridWithAvailableItems:((^ {
					
						NSMutableArray *prospectiveItems = [NSMutableArray arrayWithCapacity:numberOfUsedItems];
						for (unsigned int i = 0; i < numberOfUsedItems; i++)
							[prospectiveItems addObject:[self.dataSource layoutManager:self itemAtIndex:itemIndices[i]]];
						
						return prospectiveItems;
						
					})())];
					
					free(itemIndices);
					
					if (instance) {
					
						[returnedGrids addObject:instance];
						
						hasFoundValidGrid = YES;
						
						[instance enumerateLayoutAreasWithBlock:^(NSString *name, id item, IRDiscreteLayoutGridAreaValidatorBlock validatorBlock, IRDiscreteLayoutGridAreaLayoutBlock layoutBlock, IRDiscreteLayoutGridAreaDisplayBlock displayBlock) {
							
							if (item) {
								
								NSUInteger itemIndex = [self.dataSource layoutManager:self indexOfLayoutItem:item];
								NSParameterAssert(itemIndex != NSNotFound);
								
								[leftoverItemIndices removeIndex:itemIndex];
								
							}
							
						}];

						//	Post condition: must have exhausted some items
						//	We might allow empty pages in the future, but not now.  If you want them, deal with them at the calling site.
						
						if (lastLeftoverItemIndicesCount == [leftoverItemIndices count]) {
							*outError = IRDiscreteLayoutManagerError(IRDiscreteLayoutManagerItemExhaustionFailureError, @"Unable to exhaust all layout items during random grid election.");
							return nil;
						}
					
					}


				}
			
			}
		
			break;
		
		}
		
		case IRCompareScoreLayoutStrategy: {
		
			NSParameterAssert(NO);	//	TBD
			break;
		
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
