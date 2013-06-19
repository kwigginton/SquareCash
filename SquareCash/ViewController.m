//
//  ViewController.m
//  SquareCash
//
//  Created by Kenneth Wigginton on 5/27/13.
//  Copyright (c) 2013 Ken Wigginton. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize toField, amountField, reasonField, pw, email;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Check if it's first launch, if so, ask user for email address.
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        [self promptUserEmailWithPassword:YES];
    }else{
        self.email = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"];
        NSLog(@"Loaded user email as: %@", self.email);
        [self promptUserPassword];
    }
    
    toField.returnKeyType = UIReturnKeyDone;

    amountField.returnKeyType = UIReturnKeyDone;

    reasonField.returnKeyType = UIReturnKeyDone;

    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tapToDismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)promptUserEmailWithPassword:(BOOL) getPassword{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Enter your SquareCash Email" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    if(getPassword)
        message.tag = 0;
    else
        message.tag = 1;
    message.alertViewStyle = UIAlertViewStylePlainTextInput;
    [message show];
}

-(void)promptUserPassword{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Enter your email password:" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [message setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    message.tag = 2;
    [message show];
}

//Facilitates Dismissing the Keyboard given a touch on the view to dismiss the keyboard.
-(void)dismissKeyboard {
    [toField resignFirstResponder];
    [amountField resignFirstResponder];
    [reasonField resignFirstResponder];
}

- (IBAction)settingsButtonPressed{
    [self promptUserEmailWithPassword:YES];
}

- (IBAction)sendCash{
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = email;
    smtpSession.password = pw;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:email]];
    NSMutableArray *to = [[NSMutableArray alloc] init];

        MCOAddress *newAddress = [MCOAddress addressWithMailbox:toField.text];
        [to addObject:newAddress];

    [[builder header] setTo:to];
    NSMutableArray *cc = [[NSMutableArray alloc] init];

        newAddress = [MCOAddress addressWithMailbox:@"pay@square.com"];
        [cc addObject:newAddress];
    
    [[builder header] setCc:cc];
    
    [[builder header] setSubject:[NSString stringWithFormat:@"Here's $%@ for: %@", amountField.text, reasonField.text]];
    [builder setHTMLBody:@"<br><br><br>Sent via SquareCash!"];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        UIAlertView *toShow = [[UIAlertView alloc] initWithTitle:@"Send Cash" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        if(error) {
            toShow.tag = 3;
            [toShow setMessage:@"We're really sorry about this, but there was an issue with sending your cash, please try again or try changing your email."];
            NSLog(@"%@ Error sending cash:%@", email, error);
        } else {
            toShow.tag = 4;
            [toShow setMessage:@"You have successfully sent SquareCash!"];
            NSLog(@"%@ Successfully sent cash!", email);
        }
        [toShow show];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if(alertView.tag == 0){ //is email prompt followed by password
        if (buttonIndex == 0){
            //Cancel button hit.
            //Do Nothing
        }
        else{
            NSString* newEmail = [[alertView textFieldAtIndex:0] text];
            NSLog(@"Set new User-Email to: %@", newEmail);
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //Register the new User Email.
            [userDefaults setObject:newEmail forKey:@"userEmail"];
            
            if([userDefaults boolForKey:@"firstLaunch"])
                //Register that this is no longer considered firstLaunch
                [userDefaults setObject: [NSNumber numberWithBool:NO] forKey:@"firstLaunch"];
            self.email = newEmail;
            [userDefaults synchronize];
            //Follow up with password prompt
            [self promptUserPassword];
        }
    }else if(alertView.tag == 1){ //is email prompt without password
        if (buttonIndex == 0){
            //Cancel button hit.
            //Do Nothing
        }
        else{
            NSString* newEmail = [[alertView textFieldAtIndex:0] text];
            NSLog(@"Set new User-Email to: %@", newEmail);
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //Register the new User Email.
            [userDefaults setObject:newEmail forKey:@"userEmail"];
            
            if([userDefaults boolForKey:@"firstLaunch"]) //This should never be the case, since we only call alert w/ tag 0 on firstLaunch
                //Register that this is no longer considered firstLaunch
                [userDefaults setObject: [NSNumber numberWithBool:NO] forKey:@"firstLaunch"];
            self.email = newEmail;
            [userDefaults synchronize];
        }
    }else if(alertView.tag == 2){ //is password prompt
        //TODO use iOS keychain to store email/pass rather than insecure storage in the clear
        self.pw = [[alertView textFieldAtIndex:0] text];
    }else if(alertView.tag == 3){
        //Case for cash send failure alert
        // TODO perhaps allow error reporting or support call options.
    }else if(alertView.tag == 4){
        //Case for cash send success alert
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


- (IBAction)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (IBAction)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
@end
