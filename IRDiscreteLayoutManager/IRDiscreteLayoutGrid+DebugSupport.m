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

	return [NSString stringWithFormat:@"<%@: 0x%x> { Identifier: %@, Prototype: %@, Areas: %@ } ", NSStringFromClass([self class]), (unsigned int)self, self.identifier, self.prototype, self.layoutAreas];

}

- (NSString *) descriptionWithLocale:(id)locale indent:(NSUInteger)level {

	return [[NSDictionary dictionaryWithObjectsAndKeys:
	
		[self description], @"Identity",
		self.prototype, @"Prototype",
		self.layoutAreas, @"Areas",
		
	nil] descriptionWithLocale:locale indent:level];

}

@end
