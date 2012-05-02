//
//  NSArray+IRDiscreteLayoutAdditions.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 5/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSArray+IRDiscreteLayoutAdditions.h"

@implementation NSArray (IRDiscreteLayoutAdditions)

- (NSArray *) irdlPossibleCombinations {

	NSCParameterAssert([self isKindOfClass:[NSArray class]]);
	
	NSUInteger length = [self count];
	if (length <= 1)
		return (NSArray *)[NSArray arrayWithObject:self];
	
	NSMutableArray *answer = [NSMutableArray array];
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:(NSRange){ 0, length }];
	
	for (NSUInteger i = 0; i < length; i++) {
	
		NSMutableIndexSet *usedIndices = [indexSet mutableCopy];
		[usedIndices removeIndex:i];
		
		NSArray *otherObjects = [self objectsAtIndexes:usedIndices];
		NSCParameterAssert([otherObjects isKindOfClass:[NSArray class]]);
		
		for (NSArray *combination in [otherObjects irdlPossibleCombinations]) {
			
			NSCParameterAssert([combination isKindOfClass:[NSArray class]]);
			
			NSArray *usedCombination = [combination copy];
			NSArray *baseObjs = [NSArray arrayWithObject:[self objectAtIndex:i]];
			NSArray *addedAnswer = [baseObjs arrayByAddingObjectsFromArray:usedCombination];
			
			[answer addObject:addedAnswer];
			
		}
	
	}
	
	return (NSArray *)[answer copy];

}

@end
