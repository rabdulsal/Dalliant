//  iradio
//
//  Created by studio76 on 22.08.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		COLOR_NAVBAR_TITLE					HEXCOLOR(0xFFFFFFFF)
#define		COLOR_NAVBAR_BUTTON					HEXCOLOR(0xFFFFFFFF)
#define		COLOR_NAVBAR_BACKGROUND				HEXCOLOR(0x19C5FF00)

#define		COLOR_TABBAR_LABEL					HEXCOLOR(0xFFFFFFFF)
#define		COLOR_TABBAR_BACKGROUND				HEXCOLOR(0x19C5FF00)

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		PF_USER_CLASS_NAME					@"_User"
#define		PF_USER_OBJECTID					@"objectId"
#define		PF_USER_USERNAME					@"username"
#define		PF_USER_PASSWORD					@"password"
#define		PF_USER_EMAIL						@"email"
#define		PF_USER_EMAILCOPY					@"emailCopy"
#define		PF_USER_FULLNAME					@"username"
#define		PF_USER_NICKNAME					@"nickname"
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"
#define		PF_USER_FACEBOOKID					@"facebookId"
#define		PF_USER_PICTURE						@"avatarUser"
#define		PF_USER_THUMBNAIL					@"thumbnail"

#define		PF_CHAT_CLASS_NAME					@"Chat"
#define		PF_CHAT_ROOM						@"room"
#define		PF_CHAT_USER						@"user"
#define		PF_CHAT_TEXT						@"text"
#define		PF_CHAT_CREATEDAT					@"createdAt"

#define		PF_CHATROOMS_CLASS_NAME				@"ChatRooms"
#define		PF_CHATROOMS_ROOM					@"room"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"
