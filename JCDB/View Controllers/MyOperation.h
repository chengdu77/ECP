//
//  MyOperation.h
//  JCDB
//
//  Created by WangJincai on 16/1/15.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DATA(X) [X dataUsingEncoding:NSUTF8StringEncoding]
// Posting constants
//#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"image.jpg\"; filename=\"%@\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

@interface MyOperation : NSOperation


@property (strong,nonatomic) UIImage *theImage;
@property (strong,nonatomic) NSString *fileName;


- (NSDictionary *)uploadingWithUrl:(NSString *)baseurl;

@end
