//
//  ViewController.h
//  SquareCash
//
//  Created by Kenneth Wigginton on 5/27/13.
//  Copyright (c) 2013 Ken Wigginton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/mailcore.h>

@interface ViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>
@property IBOutlet UITextField* toField;
@property IBOutlet UITextField* amountField;
@property IBOutlet UITextField* reasonField;
@property IBOutlet UIImageView* settingsButton;
@property NSString *pw;
@property NSString *email;
-(IBAction)sendCash;
-(IBAction)settingsButtonPressed;
@end
