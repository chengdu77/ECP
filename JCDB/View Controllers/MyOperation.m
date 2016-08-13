//
//  MyOperation.m
//  JCDB
//
//  Created by WangJincai on 16/1/15.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "MyOperation.h"

@implementation MyOperation


//创建postdata
- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict{
    
    id boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray* keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
    
    for (int i = 0; i < [keys count]; i++){
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if ([value isKindOfClass:[NSData class]])
        {
            // handle image data
            NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
            [result appendData: DATA(formstring)];
            [result appendData:value];
        }
        else
        {
            // all non-image fields assumed to be strings
            NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
            [result appendData: DATA(formstring)];
            [result appendData:DATA(value)];
        }
        
        NSString *formstring = @"\r\n";
        [result appendData:DATA(formstring)];
    }
    
    NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:DATA(formstring)];
    return result;
}

//上传图片
- (NSDictionary *)uploadingWithUrl:(NSString *)baseurl{
    if (!self.theImage)
        NSLog(@"Please set image before uploading.");
    
    NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
    
    [post_dict setObject:@"Posted from iPhone" forKey:@"message"];
    [post_dict setObject:UIImageJPEGRepresentation(self.theImage, 0.75f) forKey:self.fileName];
    
    NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
    
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NSLog(@"Error creating the URL Request");
    
    [urlRequest setHTTPMethod: @"POST"];
    [urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
    
    // Submit & retrieve results
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (!result){
//        [self cleanup:[NSString stringWithFormat:@"Submission error: %@", [error localizedDescription]]];
        return nil;
    }
    
    // Return results
    
    NSError *err=nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&err];
    
//    NSString *outstring = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    return dic;
}

@end
