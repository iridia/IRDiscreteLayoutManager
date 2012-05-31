//
//  NSArray+IRDiscreteLayoutAdditions.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 5/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#include <algorithm>

#import "NSArray+IRDiscreteLayoutAdditions.h"

@implementation NSArray (IRDiscreteLayoutAdditions)

- (void) irdlEnumeratePossibleCombinationsWithBlock:(void(^)(NSArray *combination, BOOL *stop))block {

//	NSParameterAssert(block);
	BOOL stop = NO;

	NSUInteger count = [self count];
	if (!count)
		return;
	
	size_t items[count];
	for (NSUInteger i = 0; i < count; i++)
		items[i] = i;
	
	do {
	
		id objects[count];
		for (NSUInteger i = 0; i < count; i++)
			objects[i] = [self objectAtIndex:items[i]];
			
		NSArray *combination = [NSArray arrayWithObjects:objects count:count];
		
		block(combination, &stop);
	
  } while (!stop && std::next_permutation(items, items + count));

}

@end
