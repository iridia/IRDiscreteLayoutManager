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

- (id) initWithIdentifier:(NSString *)inIdentifier {

	self = [super init];
	if (!self)
		return nil;
	
	identifier = inIdentifier;
	
	return self;

}

- (id) copyWithZone:(NSZone *)zone {

	IRDiscreteLayoutArea *answer = [[[self class] alloc] init];
	
	answer.identifier = self.identifier;
	answer.item = self.item;
	answer.validatorBlock = self.validatorBlock;
	answer.layoutBlock = self.layoutBlock;
	answer.displayBlock = self.displayBlock;
	
	return answer;

}

- (void) setItem:(id<IRDiscreteLayoutItem>)item {

	[self setItem:item error:nil];

}

- (BOOL) setItem:(id<IRDiscreteLayoutItem>)aLayoutItem error:(NSError **)outError {

	if (aLayoutItem == item)
		return YES;
	
	NSParameterAssert(self.grid.prototype);
	NSParameterAssert(self.identifier);
	
	if (aLayoutItem) {
	
		IRDiscreteLayoutAreaValidatorBlock vb = self.validatorBlock;
		
		if (vb && !vb(self, aLayoutItem)) {
			
			if (outError)
				*outError = IRDiscreteLayoutError(IRDiscreteLayoutGridItemValidationFailureError, [NSString stringWithFormat:@"Item %@ is not accepted by the validator block of area %@", aLayoutItem, self], nil);
			
			return NO;
			
		}
	
	}
	
	[self willChangeValueForKey:@"item"];
	
	item = aLayoutItem;
	
	[self didChangeValueForKey:@"item"];

	return YES;

}

#if TARGET_IPHONE_SIMULATOR

- (BOOL) isNSDictionary__ {

	return YES;

}

#endif

- (NSString *) descriptionWithLocale:(id)locale indent:(NSUInteger)level {

	return [NSString stringWithFormat:
		
		@"<%@: %p %@ >",
		
		NSStringFromClass([self class]),
		self,

		[[NSDictionary dictionaryWithObjectsAndKeys:
		
			self.identifier, @"Identifier",
			[NSString stringWithFormat:@"<%@: %p>", NSStringFromClass([self.item class]), self.item], @"Item",
			
		nil] descriptionWithLocale:locale indent:level]
	
	];

}

- (BOOL) isEqual:(IRDiscreteLayoutArea *)otherArea {

	if (![otherArea isKindOfClass:[IRDiscreteLayoutArea class]])
		return NO;
		
	return [self.item isEqual:otherArea.item];
	
}

@end
