//
//  IRDiscreteLayoutGrid+DebugSupport.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import "IRDiscreteLayoutGrid+DebugSupport.h"


@implementation IRDiscreteLayoutGrid (DebugSupport)

- (NSString *) description {

	return [self descriptionWithLocale:nil indent:0];

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
			self.layoutAreas, @"Areas",
			self.prototype, @"Prototype",
			
		nil] descriptionWithLocale:locale indent:level]
	
	];

}

@end
