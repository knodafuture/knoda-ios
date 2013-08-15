//
//  OutcomeWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 14.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface OutcomeWebRequest : BaseWebRequest

- (id)initWithPredictionId:(NSInteger)predictionId realise:(BOOL)realise;

@end
