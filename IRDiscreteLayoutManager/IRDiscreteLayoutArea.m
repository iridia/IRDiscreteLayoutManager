//
//  IRDiscreteLayoutArea.m
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 5/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutArea.h"

@implementation IRDiscreteLayoutArea

- (id) copyWithZone:(NSZone *)zone {

	IRDiscreteLayoutArea *answer = [[[self class] alloc] init];
	
	answer.identifier = self.identifier;
	answer.item = self.item;
	answer.validatorBlock = self.validatorBlock;
	answer.layoutBlock = self.layoutBlock;
	answer.displayBlock = self.displayBlock;
	
	return answer;

}

@end
