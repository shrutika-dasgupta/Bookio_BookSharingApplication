//
//  MyBooksTableViewCell.m
//  Bookio
//
//  Created by Bookio Team on 4/28/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "MyBooksTableViewCell.h"

@implementation MyBooksTableViewCell

- (IBAction)RentCheckButton:(id)sender {
    //enable the fields and set image as appropriate on toggle of rent check button
    if (self.RentSelect.selected == NO) {
        self.RentSelect.selected = YES;
        self.RentPrice.enabled = YES;
        [self.RentSelect setImage:[UIImage imageNamed:@"checkbox-ticked.png"] forState:UIControlStateNormal];
    } else {
        self.RentSelect.selected = NO;
        self.RentPrice.enabled = NO;
        [self.RentSelect setImage:[UIImage imageNamed:@"checkbox-unticked.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)SellCheckButton:(id)sender {
    //enable the fields and set image as appropriate on toggle of sell check button
    if (self.SellSelect.selected == NO) {
        self.SellSelect.selected = YES;
        self.SellPrice.enabled = YES;
        [self.SellSelect setImage:[UIImage imageNamed:@"checkbox-ticked.png"] forState:UIControlStateNormal];
    } else {
        self.SellSelect.selected = NO;
        self.SellPrice.enabled = NO;
        [self.SellSelect setImage:[UIImage imageNamed:@"checkbox-unticked.png"] forState:UIControlStateNormal];
    }
}

/* Returns true if the string has valid price */
-(BOOL)hasValidPrice:(NSString *)inputString
{
    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890."];
    NSCharacterSet *invalidChars = [validChars invertedSet];
    
    NSRange r = [inputString rangeOfCharacterFromSet:invalidChars];
    if (r.location != NSNotFound) {
        NSLog(@"the string contains illegal characters");
        return NO;
    }
    
    unsigned long dotOccurences = [[inputString componentsSeparatedByString:@"."] count] - 1;
    if (dotOccurences != 0 && dotOccurences != 1) {
        NSLog(@"string has too many periods");
        return NO;
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    NSString *zeroPrice = [NSString stringWithFormat:@"0"];
    
    if ([self.RentPrice isFirstResponder] && (self.RentPrice != touch.view))
    {
        //resign the keyboard
        if (self.RentPrice.isFirstResponder) {
            [self.RentPrice resignFirstResponder];
        }
        if ([self hasValidPrice: self.RentPrice.text] == NO) {
            //validate the price
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Alert"
                                      message:@"The rent price is invalid!!"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            
            //TODO: This is not working for some reason
            self.RentPrice.text = zeroPrice;
        }
        if([self.RentPrice.text isEqualToString:@""]) {
            self.RentPrice.text = zeroPrice;
        }
    }
    
    if ([self.SellPrice isFirstResponder] && (self.SellPrice != touch.view))
    {
        //resign the keyboard
        if (self.SellPrice.isFirstResponder) {
            [self.SellPrice resignFirstResponder];
        }
        if ([self hasValidPrice: self.SellPrice.text] == NO) {
            
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Alert"
                                      message:@"The sell price is invalid!!"
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
            //TODO: This is not working for some reason
            self.SellPrice.text = zeroPrice;
        }
        
        if([self.SellPrice.text isEqualToString:@""]) {
            self.SellPrice.text = zeroPrice;
        }
    }
}


- (IBAction)finishedRentPriceEdit:(id)sender {
    //resign keyboard
    if (self.RentPrice.isFirstResponder) {
        [self.RentPrice resignFirstResponder];
    }
    //validate price
    if ([self hasValidPrice: self.RentPrice.text] == NO) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                    initWithTitle:@"Alert"
                                    message:@"The rent price is invalid!!"
                                    delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)finishedSellPriceEdit:(id)sender {
    //resign keyboard
    if (self.SellPrice.isFirstResponder) {
        [self.SellPrice resignFirstResponder];
    }
    //validate price
    if ([self hasValidPrice: self.SellPrice.text] == NO) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Alert"
                                  message:@"The sell price is invalid!!"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }

}

@end
