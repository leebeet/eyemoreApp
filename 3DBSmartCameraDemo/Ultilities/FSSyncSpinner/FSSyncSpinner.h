//
//  FSSyncSpinner.h
//  Pods
//
//  Created by Wenchao Ding on 3/8/15.
//
//

#import <UIKit/UIKit.h>
#import "FSSyncSpinner.h"
//typedef void(^FinishBlock)(BOOL Finish);
//@protocol FSSyncSpinnerDelegate <NSObject>
//
//@optional
//- (void)syncSpinnerDidFinishAnimating;
//
//@end
@interface FSSyncSpinner : UIView

@property (assign, nonatomic) BOOL hidesWhenFinished;
//@property (assign, nonatomic) id <FSSyncSpinnerDelegate> delegate;
- (void)startAnimating;
- (void)finish;

@end
