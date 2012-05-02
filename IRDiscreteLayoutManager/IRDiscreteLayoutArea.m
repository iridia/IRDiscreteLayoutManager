//
//  IRDiscreteLayoutArea.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 5/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutArea.h"
#import "IRDiscreteLayoutGrid.h"
#import "IRDiscreteLayoutError.h"

@implementation IRDiscreteLayoutArea
@synthesize identifier, item, validatorBlock, layoutBlock, displayBlock, grid;

- (id) copyWithZone:(NSZone *)zone {

	IRDiscreteLayoutArea *answer = [[[self class] alloc] init];
	
	answer.identifier = self.identifier;
	answer.item = self.item;
	answer.validatorBlock = self.validatorBlock;
	answer.layoutBlock = self.layoutBlock;
	answer.displayBlock = self.displayBlock;
	
	return answer;

}

- (BOOL) setItem:(id<IRDiscreteLayoutItem>)aLayoutItem error:(NSError **)outError {

	NSParameterAssert(self.grid.prototype);
	NSParameterAssert(self.identifier);
	
	IRDiscreteLayoutAreaValidatorBlock vb = self.validatorBlock;
	if (aLayoutItem && vb && !vb(self, aLayoutItem)) {
		
		if (outError)
			*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridItemValidationFailureError, [NSString stringWithFormat:@"Item %@ is not accepted by the validator block of area %@", aLayoutItem, self], nil);
		
		return NO;
		
	}
	
	self.item = aLayoutItem;

	return YES;

}

- (NSString *) description {

	return [NSString stringWithFormat:@"<%@: 0x%x> { Identifier: %@, Item: %@ } ", NSStringFromClass([self class]), (unsigned int)self, self.identifier, self.item];

}

@end
