//
//  Constants.h
//  KSJX
//
//  Created by wangjc on 15-7-3.
//  Copyright (c) 2015年 wjc. All rights reserved.
//

#ifndef KSJX_Constants_h
#define KSJX_Constants_h

#import "UIColor+External.h"

#define kUploadFileUrl @"http://192.168.1.101/ksjx/upload.php"


#undef	RGB
#define RGB(R,G,B)		[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]

#undef	RGBA
#define RGBA(R,G,B,A)	[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]

#undef	HEX_RGB
#define HEX_RGB(V)		[UIColor fromHexValue:V]

#undef	HEX_RGBA
#define HEX_RGBA(V, A)	[UIColor fromHexValue:V alpha:A]

//所有界面颜色[UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]
#define kALLBUTTON_COLOR  RGB(0,175,240)

#define kBackgroundColor [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]
#define kRandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]

#define kFontColor [UIColor colorWithWhite:0.7 alpha:1.0]
#define kFontColor_Contacts RGB(67,74,84)

#define kSuccessCode 1
#define kErrorInfomation @"未获取到数据！！"

#define kAddressHttps @"AddressHttps"
#define kOneselfInfo @"OneselfInfo"
#define kAddressTXURL @"AddressTXURL"

#define kProcessid @"processid"

#define kUSERNAME @"USERNAME"
#define kPASSWORD @"PASSWORD"
#define kREMBERFLAG @"REMBERFLAG"
#define kDeptInfo @"DeptInfo"

#define IOS9_OR_LATER ( [[[UIDevice currentDevice] systemVersion] compare:@"9.0"] != NSOrderedAscending )
#define IOS8_OR_LATER ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )

#define ShareAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define kEditTextFieldHeight 34
#define kTextFieldHeight 60

#define kCellHeight 56;

#define kTextField @"textField" //显示(只读)文本框
#define kSingleListField @"singleListField" //可选列表框（返回单个值）
#define kMoreListField @"moreListField" //可选列表框（返回多个值）
#define kUploadFileField @"uploadFileField" //可选上传附件
#define kCheckboxField @"checkboxField" //可选复选框
#define kSelectListField @"selectListField" //下拉列表
#define kEditTextField @"editTextField" //可编辑文本框
#define kDateField @"dateField" //可选日期框
#define kTimeField @"timeField" //可选时间框
#define kTableField @"tableField" //可选时间框

#define kFontName @"HelveticaNeue"
#define kFontNameB @"Helvetica-Bold"

//事项列表上“添加”按钮涉及的接口
#define kURL_SelectionModule @"%@/ext/com.cinsea.action.MouAction?action=getModulelist" //选择模块
#define kURL_TypeMatters @"%@/ext/com.cinsea.action.WfdefineAction?action=getWfdefinelist&id=%@" //选择事项类型
#define kURL_AddFormData @"%@/ext/com.cinsea.action.FormAction?action=formviewdata&dowid=%@" //获取新增的表单
#define kURL_AddCommitData @"%@/ext/com.cinsea.action.FormAction?action=createformdata&datas=%@&dowid=%@&type=%@" //提交数据

//报表
#define kURL_ChartList @"%@/ext/com.cinsea.action.MobileReportAction?action=getnewreportlist&pno=1"
#define kURL_ChartDeatails @"%@/chart.jsp?id=%@"

//流程日志
#define kURL_ReportInstructions @"%@/ext/com.cinsea.action.WfprocessAction?action=getwfprocesslog&processid=%@&nodeid=%@"

//工作台
#define kURL_WorkStationList @"%@/ext/com.cinsea.action.WfdefineAction?action=getDirectorylist"
#define kURL_WorkStationDetail @"%@/ext/com.cinsea.action.ProcessAction?action=getprocesslist&processid=%@"

//部门
#define kURL_DeptInfo @"%@/ext/com.cinsea.action.OrgtreeAction?node=%@"
//签到
#define kURL_signed @"%@/ext/com.cinsea.action.ProcessAction?action=signed&didian=%@&jingweidu=%@"
//消息
#define kURL_NotifyAction @"%@/ext/com.cinsea.action.NotifyAction?action=getNotify"

typedef void (^PopViewController)();
typedef void (^PopViewBlock)(id object);



#endif
