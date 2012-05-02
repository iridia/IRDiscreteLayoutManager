//
//  IRDiscreteLayoutGridCandidateInfo.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 4/25/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutGridCandidateInfo.h"
#import "IRDiscreteLayoutChangeSet.h"
#import "IRDiscreteLayoutArea.h"

@interface IRDiscreteLayoutGridCandidateInfo ()

- (CGFloat) scoreMutatingFromGrid:(IRDiscreteLayoutGrid *)otherGrid;

- (id) initWithGrid:(IRDiscreteLayoutGrid *)gridInstance itemIndices:(NSIndexSet *)gridItemIndices referenceGrid:(IRDiscreteLayoutGrid *)referenceGridInstance delegateIndex:(NSUInteger)index;

@end


@implementation IRDiscreteLayoutGridCandidateInfo
@synthesize grid, itemIndices, referenceGrid, delegateIndex, score;

+ (id) infoWithGrid:(IRDiscreteLayoutGrid *)gridInstance itemIndices:(NSIndexSet *)gridItemIndices referenceGrid:(IRDiscreteLayoutGrid *)referenceGridInstance delegateIndex:(NSUInteger)index {

	return [[self alloc] initWithGrid:gridInstance itemIndices:gridItemIndices referenceGrid:referenceGridInstance delegateIndex:index];

}

- (id) initWithGrid:(IRDiscreteLayoutGrid *)gridInstance itemIndices:(NSIndexSet *)gridItemIndices referenceGrid:(IRDiscreteLayoutGrid *)referenceGridInstance delegateIndex:(NSUInteger)index {

	self = [super init];
	if (!self)
		return nil;
	
	grid = gridInstance;
	itemIndices = gridItemIndices;
	referenceGrid = referenceGridInstance;
	score = [self scoreMutatingFromGrid:referenceGrid];
	delegateIndex = index;
	
	return self;

}

- (CGFloat) scoreMutatingFromGrid:(IRDiscreteLayoutGrid *)otherGrid {

	__block float_t answer = 0;
	
	if (grid) {
	
		__block BOOL fullyPopulated = YES;
		
		[grid.layoutAreas enumerateObjectsUsingBlock:^(IRDiscreteLayoutArea *area, NSUInteger idx, BOOL *stop) {

			if (area.validatorBlock) {
				
				answer += 1;
				
			} else {
			
				answer -= 1;
				
			}
			
			if (!area.item)
				fullyPopulated = NO;
			
		}];
		
		if (fullyPopulated)
			answer += [grid.layoutAreas count];
		
	}
	
	if (otherGrid) {
	
		//	For now it’s a pretty simple “take one point off if changed” algorithm
	
		IRDiscreteLayoutChangeSet *changeSet = [IRDiscreteLayoutChangeSet changeSetFromGrid:otherGrid toGrid:grid];
		
		[changeSet enumerateChangesWithBlock:^(id item, IRDiscreteLayoutItemChangeType changeType) {
		
			switch (changeType) {
			
				case IRDiscreteLayoutItemChangeDeleting:
				case IRDiscreteLayoutItemChangeInserting: {
					answer -= 1;
					break;
				}
				
				case IRDiscreteLayoutItemChangeRelayout:
				case IRDiscreteLayoutItemChangeNone: {
					break;
				}
			
			}
			
		}];
	
	}
	
	if (itemIndices) {
	
		__block NSUInteger lastIndex = NSNotFound;
		
		[itemIndices enumerateIndexesUsingBlock: ^ (NSUInteger idx, BOOL *stop) {
		
			if (lastIndex != NSNotFound)
			if (idx != (lastIndex + 1)) {
				answer -= 1;
			}
			
		}];
	
	}
	
	answer /= [grid.layoutAreas count];
	
	return answer;

}

- (NSString *) description {
	
	return [NSString stringWithFormat:@"%@ { Grid = %@, Score = %f, Delegate Index = %iu }", [super description], grid, score, delegateIndex];
	
}

@end
