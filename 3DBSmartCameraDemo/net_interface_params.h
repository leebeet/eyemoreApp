#ifndef __NET_INTERFACE_PARAMS_H__
#define __NET_INTERFACE_PARAMS_H__

typedef struct{
//    char	      dev_version[20];
//    unsigned int  evf_backlight_value;
//    unsigned int  power_off_time;
//    unsigned char arm_standby;
//    unsigned char temp[3];
//    
//    unsigned char id[28];
//    
//    unsigned char temp1[8];
//	unsigned char reserved[12];
    
    char	      dev_version[20]; /*固件版本*/
    unsigned int  evf_backlight_value;  /*evf屏幕亮度*/
    unsigned int  power_off_time;    /*自动关机时间*/
    unsigned char arm_standby;   /*arm是否待机*/
    unsigned char temp[3];
    
    unsigned char id[28];
    
    unsigned char temp1[8];
    unsigned int datasocketstatus;    /*增加数据socket连接状态指示，为了防止数据socket已经断开手机侧不知道*/
    unsigned char reserved[8];

    
} DEV_INFO;

enum DEV_LENS_TYPE
{
	DEV_UNKNOWN= 0,		//no lens or manual lens
	DEV_ELECTRIC_LENS,				//electric lens
};

typedef enum _DEV_LENS_FOCUS_STATE
{
	FOCUS_UNKNOWN= 0,		//
	FOCUS_AF,				//af
	FOCUS_MF,				//mf
}DEV_LENS_FOCUS_STATE;

typedef enum _DEV_BWDISPLAY_STATE
{
    DISPLAY_UNKNOWN = 0,
    DISPLAY_BLACKANDWHITE,
    DISPLAY_COLOR,
    DISPLAY_SOFT,
    DISPLAY_LONG_EXPOSURE
    
}DEV_BWDISPLAY_STATE;

typedef enum _LENS_EXPOSURE_MODE
{
    MODE_UNKNOWN = 0,
    MODE_P,
    MODE_S,
    MODE_A,
    MODE_M,
}LENS_EXPOSURE_MODE;

typedef enum _LENS_IRIS_VALE
{
	IRIS_F1P2=0,				//
	IRIS_F1P4,				//
	IRIS_F1P7,
	IRIS_F1P8,
	IRIS_F2,	//4
	IRIS_F2P2,
	IRIS_F2P5,
	IRIS_F2P8,
	IRIS_F3P2,	//8
	IRIS_F3P5,
	IRIS_F4,	//10
	IRIS_F4P5,//.....
	IRIS_F5,
	IRIS_F5P6,//.....
	IRIS_F6P3,
	IRIS_F7P1,//.....
	IRIS_F8,	//16
	IRIS_F9,//.....
	IRIS_F10,
	IRIS_F11,//.....
	IRIS_F13,
	IRIS_F14,
	IRIS_F16,
	IRIS_F18,
	IRIS_F20,
	IRIS_F22,	//25
}LENS_IRIS_VALE;

typedef enum _LENS_EXPOSURE_VALUE
{
    EVN10P0 = 0,
    EVN9P0,
    EVN8P0,
    EVN7P0,
    EVN6P0,
    EVN5P0,
    EVN4P0,
    EVN3P0,
    EVN2P0,
    EVN1P0,
    EVP0P0,
    EVP1P0,
    EVP2P0,
    EVP3P0,
    EVP4P0,
    EVP5P0,
    EVP6P0,
    EVP7P0,
    EVP8P0,
    EVP9P0,
    EVP10P0,
    
}LENS_EXPOSURE_VALUE;

typedef enum _LENS_SHUTTER_VALUE
{
    SHUTTER_UNKNOWN = 0,
    SHUTTER_1_25,
    SHUTTER_1_50,
    SHUTTER_1_75,
    SHUTTER_1_100,
    SHUTTER_1_125,
    SHUTTER_1_150,
    SHUTTER_1_200,
    SHUTTER_1_500,
    SHUTTER_1_1000,
    SHUTTER_1_2000,
    SHUTTER_1_4000,
    SHUTTER_1_8000,

}LENS_SHUTTER_VALUE;


typedef struct{
 
    unsigned char lens_type;
    unsigned char focus_mode;
    unsigned char zoom_state;
    unsigned char current_iris_value;
    
    unsigned char current_shutter_value;
    unsigned char current_exposure_value;
    unsigned char bwdisplay_state;
    unsigned char iris_max_value;
    
    unsigned char iris_min_value;
    unsigned char temp[3];
    
    unsigned char lens_name[34];

} LENS_PARAMS;

typedef struct{
	unsigned char cmd;
	unsigned char param0;
	unsigned char param1;
	unsigned char state;

	unsigned int paramn[20];
} CTL_MESSAGE_PACKET;	//84 byte


//<Guid("CE1D42C0-EB5E-44DD-AB92-66F8E2D1947A")>
typedef struct{
	char id[40];

	unsigned char htype;    /* client hardware type */
    unsigned char hlen;     /* hardware address length */
	unsigned short unused;

    unsigned long xid;      /* transaction ID */
    unsigned long client_ip_addr;   /* client IP address */
    unsigned long server_ip_addr;   /* server IP address */
    unsigned long gateway_ip_addr;   /* gateway IP address */
    char client_mac_addr[16];        /* client hardware address */
} HB_PACKET;

typedef struct{
    int x;
    int y;
}FOCUS_POINT;

enum DEV_WORK_MODE
{
	DWM_NORMAL= 0,		//SAVE JPG to sd card
	DWM_FLASH_PHOTO,	//save jpg in ddr
	DWM_BLOCK_DOWN_LOAD,
};

typedef enum _STADNDBY_MODE_STATE
{
    STADNDBY_UNKNOWN= 115,		//
    STADNDBY_ENABLE,				//af
    STADNDBY_DISABLE,				//mf
    
}STADNDBY_MODE_STATE;

enum DEV_UP_MODE
{
	DEV_UNKNOW = 0,
	DEV_UPLOAD_NEW,		       //
	DEV_RESTORE_FACTORY_SET,	//
};

enum SDB_UPLOAD_STATE
{
    SDB_STATE_UPLOAD_UNKNOWN= 0,
    SDB_STATE_TRANSMITTING,
    SDB_STATE_TRANSMIT_SUCCESS,
    SDB_STATE_TRANSMIT_FAILED,
    SDB_STATE_CHECKING,
    SDB_STATE_CHECK_SUCCESS,
    SDB_STATE_CHECK_FAILED,
    SDB_STATE_SAVING,
    SDB_STATE_SAVE_SUCCESS,
    SDB_STATE_SAVE_FAILED,
    SDB_STATE_RECHECKING,
    SDB_STATE_RECHECK_SUCCESS,
    SDB_STATE_RECHECK_FAILED,
    SDB_STATE_UPLOAD_SUCCESS,
    SDB_STATE_UPLOAD_RESET
};

enum DEV_WORK_SATE
{
	DWM_UNKNOWN= 111,		
	DWM_START,	
	DWM_STOP,
	DWM_OPEN,
	DWM_CLOSE,
};

enum JPG_EXIF_PARAMS
{
    JPG_EXIF_FILE_ID=100,
    JPG_EXIF_SN,
};

typedef enum _SDB_STATE
{
	SDB_STATE_UNKNOWN= 0,		
	SDB_STATE_SUCCESS,	//1
	SDB_STATE_FAILED,//2
	SDB_STATE_PARAMS_ERROR,//3
	SDB_STATE_FILE_NOT_EXIST,//4
	SDB_DATA_SOCKET_NOT_EXIST,//5
	SDB_DATA_TRANSFOR_NOT_END,//6
	SDB_SERVER_NOT_READY,//7
	SDB_STATE_NOT_SUPPT_IRIS_VALUE,//8
    
}SDB_STATE;

typedef struct{
    
    unsigned char fpga_temp;
    unsigned char bq24192_registers[10];//hex 8bit
    unsigned short Control;	//hex 16bit
    unsigned short Temperature;//hex 16bit
    unsigned short Voltage;	//dec 16bit
    unsigned short NominalAvailableCapacity;//dec 16bit
    unsigned short FullAvailableCapacity;//dec 16bit
    unsigned short RemainingCapacity;//dec 16bit
    unsigned short FullChargeCapacity;//dec 16bit
    unsigned short AverageCurrent;//dec 16bit
    unsigned short StandbyCurrent;//dec 16bit
    unsigned short MaxLoadCurrent;//dec 16bit
    unsigned short AveragePower;//dec 16bit
    unsigned short StateOfCharge;//dec 16bit
    unsigned short IntTemperature;//hex 16bit
    unsigned short StateOfHealth;//dec 16bit
    char stm32_version[10];
    unsigned char temp[31];
    
} DEBUG_INFO;

/*
 Start from T2.02
 DebugInfo.StateOfCharge
 bit15:1-> 充电中，0->未充电
 bit14:1-> 红色，  0->绿色
 bit[7:0]: 电量   0~100%
 */

typedef struct{
    
    BOOL isCharging;
    int  powerValue;
    
} BAT_INFO;

typedef struct{
    unsigned int year;
    unsigned int month;
    unsigned int day;
    unsigned int hours;
    unsigned int minutes;
    unsigned int senconds;
    
    unsigned int UpdateTimes;
}DateTime;

typedef struct {
    
    int size;
    char pathname[64];
    
}UPLOAD_GFILE_STRUCT;


enum VEDIO_RECORD_RESOLUTION{
    RESOLUTION_480_270,
    RESOLUTION_960_540,
    RESOLUTION_1920_1080
};

typedef enum _SDB_COMM_SIG_TYPE
{
	SDB_UNKNOWN	= 0,

	SDB_GET_DEVICEINFO,//~{;qH!Ih18PEO"#,1HHgND<~W\J}!"4f4"H]A?5H#,WT<:6(ReJ}>]=a99~}
	SDB_GET_DEVICEINFO_ACK,//~{7~NqFw75;XIOJvPEO"~}

	SDB_GET_NORMAL_PHOTO_COUNT,//~{;qH!4f4"TZ~}sd~{?(@o5DND<~8vJ}~}
	SDB_GET_NORMAL_PHOTO_COUNT_ACK,//~{75;XC|An=a9{#,ND<~8vJ}~}

	SDB_GET_FLASH_PHOTO,//~{GkGsOBTX5%8vND<~~}
	SDB_GET_FLASH_PHOTO_ACK,//~{75;XC|An=a9{#,7"KM5%8vND<~~}

	SDB_GET_BLOCK_NORMAL_PHOTOS,//~{GkGsOBTXKySPND<~~}
	SDB_GET_BLOCK_NORMAL_PHOTOS_ACK,//~{75;XC|An=a9{#,7"KMKySPND<~~}

	SDB_GET_LIVEMEDIA,//~{GkGsJ5J1JSF5Aw#(0|@(4+:s<47Y:MJ5J1T$@@6<JtSZUb8v763k#)~}
	SDB_GET_LIVEMEDIA_ACK,//~{75;XJ5J1JSF5AwC|An4&@m=a9{~}
	
    SDB_SET_UPLOAD_ZYNQ_FIRMWARE,//~{JV;zIO4+5%8vND<~5=Ih18~}
	SDB_SET_UPLOAD_ZYNQ_FRIMWARE_ACK,//~{75;XC|An=a9{#,7"KM5%8vND<~~}

	SDB_SET_DEV_WORK_MODE,
	SDB_SET_DEV_WORK_MODE_ACK,

	SDB_SET_DEV_DATA_CHANNEL,
	SDB_SET_DEV_DATA_CHANNEL_ACK,

	SDB_SET_DEV_CTL_CHANNEL,
	SDB_SET_DEV_CTL_CHANNEL_ACK,

	SDB_FLASH_PHOTO_RECEIVED,
	SDB_FLASH_PHOTO_RECEIVED_ACK,

	SDB_BLOCK_PHOTO_RECEIVED,       //21
	SDB_BLOCK_PHOTO_RECEIVED_ACK,

	SDB_GET_LENS_PARAMS,
	SDB_GET_LENS_PARAMS_ACK,

	SDB_SET_IRIS_PARAM,
	SDB_SET_IRIS_PARAM_ACK,

    SDB_SET_BWDISPLAY_PARAM,
    SDB_SET_BWDISPLAY_PARAM_ACK,
    
    SDB_SET_EXPOSURE_PARAM,
    SDB_SET_EXPOSURE_PARAM_ACK,
    
    SDB_SET_EXPOSURE_MODE,          //31
    SDB_SET_EXPOSURE_MODE_ACK,
    
    SDB_SET_SHUTTER_PARAM,
    SDB_SET_SHUTTER_PARAM_ACK,
    
    SDB_SET_LENS_FOCUS_PARAM,
    SDB_SET_LENS_FOCUS_PARAM_ACK,

    SDB_SET_SNAPSHOT,
    SDB_SET_SNAPSHOT_ACK,
    
    SDB_SET_STANDBY_EN,
    SDB_SET_STANDBY_EN_ACK,
    
    SDB_GET_DEBUG_INFO,             //41
    SDB_GET_DEBUG_INFO_ACK,
    
    SDB_SET_POWER_OFF_TIME,
    SDB_SET_POWER_OFF_TIME_ACK,
    
    SDB_SET_EVF_BACKLIGHT,
    SDB_SET_EVF_BACKLIGHT_ACK,
    
    SDB_SET_SAVE_PARAMS,
    SDB_SET_SAVE_PARAMS_ACK,
    
    SDB_GET_UPLOAD_STATE,
    SDB_GET_UPLOAD_STATE_ACK,
    
    SDB_DELETE_ALL_JPEG       = 51,
    SDB_DELETE_ALL_JPEG_ACK   = 52,
    
    SDB_UPLOAD_GENFILE,      // 53
    SDB_UPLOAD_GENFILE_ACK,  // 54
    
    SDB_SET_SOUND_ENABLE,    // 55
    SDB_SET_SOUND_ENABLE_ACK,// 56
    
    SDB_GET_SOUND_ENABLE,    // 57
    SDB_GET_SOUND_ENABLE_ACK,// 58
    
    SDB_SET_SOUND_VOLUME,    // 59
    SDB_SET_SOUND_VOLUME_ACK,// 60
    
    SDB_GET_SOUND_VOLUME,    // 61
    SDB_GET_SOUND_VOLUME_ACK,// 62
    
    SDB_SET_SOUND_RECORD_VOLUME,
    SDB_SET_SOUND_RECORD_VOLUME_ACK,
    
    SDB_GET_SOUND_RECORD_VOLUME,
    SDB_GET_SOUND_RECORD_VOLUME_ACK,
    
    SDB_SET_JPG_EXIF_PARAMS,
    SDB_SET_JPG_EXIF_PARAMS_ACK,
    
    SDB_SET_FOCUS_POINT,
    SDB_SET_FOCUS_POINT_ACK,
    
    SDB_PUSH_FOCUS_STATUS,
    SDB_PUSH_FOCUS_STATUS_ACK,
    
    SDB_GET_LIVE_FRAME,
    SDB_GET_LIVE_FRAME_ACK,
    
    SDB_SET_FILTER_MODE,
    SDB_SET_FILTER_MODE_ACK,
    
    SDB_GET_FILTER_MODE,
    SDB_GET_FILTER_MODE_ACK,
    
    SDB_GET_SOUND_FILE_EXIST,
    SDB_GET_SOUND_FILE_EXIST_ACK,
    
    SDB_SET_RECV_OK = 100,
    SDB_SET_RECV_OK_ACK = 101,
    
    SDB_GET_LOG_FILE = 110,
    SDB_GET_LOG_FILE_ACK=111,
    
    
    SDB_BEGIN_RECORD = 150,
    SDB_BEGIN_RECORD_ACK,
    
    SDB_END_RECORD,
    SDB_END_RECORD_ACK,
    
    SDB_GET_RECORD_NUM,
    SDB_GET_RECORD_NUM_ACK,
    
    SDB_GET_RECORD_DES,
    SDB_GET_RECORD_DES_ACK,
    
    SDB_GET_FILE_HEAD,
    SDB_GET_FILE_HEAD_ACK,
    
    SDB_GET_FIRST_FRAME,   //160
    SDB_GET_FIRST_FRAME_ACK,
    
    SDB_GET_FRAME,
    SDB_GET_FRAME_ACK,
    
    SDB_GET_FRAME_MULTI,
    SDB_GET_FRAME_MULTI_ACK,
    
    SDB_DELETE_VIDEO,
    SDB_DELETE_VIDEO_ACK,
    
    SDB_GET_AUDIO,
    SDB_GET_AUDIO_ACK
    
}SDB_COMM_SIG_TYPE;

//      cmd                                     param0                        param1                    state              paramn

//	SDB_UNKNOWN	= 0,
//
//	1  SDB_GET_DEVICEINFO,                           0                            0                         0                 {0}
//	2  SDB_GET_DEVICEINFO_ACK,                       0                        sizeof(DEV_INFO)            SDB_STATE           DEV_INFO
//
//	3  SDB_GET_NORMAL_PHOTO_COUNT,                   0                            0                         0                 {0}
//	4  SDB_GET_NORMAL_PHOTO_COUNT_ACK,               0                        file count                 SDB_STATE            {0}
//
//	5  SDB_GET_FLASH_PHOTO,                          0                            0                         0                 {0}
//	6  SDB_GET_FLASH_PHOTO_ACK,                      0                            0                      SDB_STATE            {(unsigned int file length)}
//
//	7  SDB_GET_BLOCK_NORMAL_PHOTOS,                  block_offset             file count                    0                 {0}
//	8  SDB_GET_BLOCK_NORMAL_PHOTOS_ACK,              block_offset             file count                 SDB_STATE            {file count x (unsigned int file length)}  //file count <= 20
//
//	9  SDB_GET_LIVEMEDIA,                           0                             0                         0                 {0}
//	10 SDB_GET_LIVEMEDIA_ACK,                       0                             0                       SDB_STATE           {0}
//
//
//  11 SDB_SET_UPLOAD_ZYNQ_FIRMWARE,           enum(DEV_UP_MODE)                  0                         0                 {(unsigned int file length)}
//	12 SDB_SET_UPLOAD_ZYNQ_FRIMWARE_ACK,       enum(DEV_UP_MODE)                  0                       SDB_STATE           {0}
//
//	13 SDB_SET_DEV_WORK_MODE,                  enum(DEV_WORK_MODE~{#)~}           0                         0                 {0}
//	14 SDB_SET_DEV_WORK_MODE_ACK,              enum(DEV_WORK_MODE~{#)~}           0                       SDB_STATE           {0}
//
//  15 SDB_SET_DEV_DATA_CHANNEL,               DWM_OPEN/ DWM_CLOSE                0                         0                 {0}
//  16 SDB_SET_DEV_DATA_CHANNEL_ACK,           DWM_OPEN/ DWM_CLOSE                0                       SDB_STATE           {0}
//
//  17 SDB_SET_DEV_CTL_CHANNEL,                 DWM_CLOSE                         0                         0                 {0}
//  18 SDB_SET_DEV_CTL_CHANNEL_ACK,             DWM_CLOSE                         0                       SDB_STATE           {0}

//  19 SDB_GET_LENS_PARAMS,                        0                              0                         0,                {0}
//	20 SDB_GET_LENS_PARAMS_ACK,					   0							  0                       SDB_STATE          LENS_PARAMS

//	21 SDB_SET_IRIS_PARAM,                    enum(LENS_IRIS_VALE~{#)~}           0                       0                   {0}
//	22 SDB_SET_IRIS_PARAM_ACK                 enum(LENS_IRIS_VALE??               0                       SDB_STATE           {0}

//	23 SDB_SET_BWDISPLAY_PARAM,               enum(DEV_BWDISPLAY_STATE)           0                       0                   {0}
//	24 SDB_SET_BWDISPLAY_PARAM_ACK            enum(DEV_BWDISPLAY_STATE)           0                       SDB_STATE           {0}

//	25 SDB_SET_EXPOSURE_PARAM,                enum(LENS_EXPOSURE_VALUE)           0                       0                   {0}
//	26 SDB_SET_EXPOSURE_PARAM_ACK             enum(LENS_EXPOSURE_VALUE)           0                       SDB_STATE           {0}

//	27 SDB_SET_EXPOSURE_MODE,                 enum(LENS_EXPOSURE_MODE)            0                       0                   {0}
//	28 SDB_SET_EXPOSURE_MODE_ACK              enum(LENS_EXPOSURE_MODE)            0                       SDB_STATE           {0}

//	29 SDB_SET_SHUTTER_PARAM,                 enum(LENS_SHUTTER_VALUE)            0                       0                   {0}
//	30 SDB_SET_SHUTTER_PARAM_ACK              enum(LENS_SHUTTER_VALUE)            0                       SDB_STATE           {0}

//	31 SDB_SET_LENS_FOCUS_PARAM,              enum(DEV_LENS_FOCUS_STATE)          0                       0                   {0}
//	32 SDB_SET_LENS_FOCUS_PARAM_ACK           enum(DEV_LENS_FOCUS_STATE)          0                       SDB_STATE           {0}

//  33 SDB_SET_SNAPSHOT,                      COUNT                               0                       0,                  {0}
//  34 SDB_SET_SNAPSHOT_ACK,                  COUNT                               0                       0,                  {0}

//  35 SDB_SET_POWER_OFF_TIME,                minutes                             0                       0,                  {0}
//  36 SDB_SET_POWER_OFF_TIME_ACK,            minutes                             0                       SDB_STATE,          {0}

//  37 SDB_SET_EVF_BACKLIGHT,                 evf led value(1~31)                 0                       0,                  {0}
//  38 SDB_SET_EVF_BACKLIGHT_ACK,             evf led value(1~31)                 0                       SDB_STATE,          {0}

//  39 SDB_SET_SAVE_PARAMS,                      0                                0                       0,                  {0}
//  40 SDB_SET_SAVE_PARAMS_ACK,                  0                                0                       SDB_STATE,          {0}

// SDB_GET_UPLOAD_STATE,                         0                                0                        0,                 {0}
// SDB_GET_UPLOAD_STATE_ACK,                     0                                0                       SDB_UPLOAD_STATE,   {0}

// SDB_SET_SOUND_ENABLE,                    static int audio_play_enable=1;    /*0/1*/
// SDB_SET_SOUND_ENABLE_ACK,
//
// SDB_GET_SOUND_ENABLE,
// SDB_GET_SOUND_ENABLE_ACK,
//
// SDB_SET_SOUND_VOLUME,                    static int audio_sound_volume = 0; /*0~79*/
// SDB_SET_SOUND_VOLUME_ACK,
//
// SDB_GET_SOUND_VOLUME,
// SDB_GET_SOUND_VOLUME_ACK,
//
// SDB_SET_SOUND_RECORD_VOLUME,             static int audio_record_volume = 0; /*0~47*/
// SDB_SET_SOUND_RECORD_VOLUME_ACK,
//
// SDB_GET_SOUND_RECORD_VOLUME,
// SDB_GET_SOUND_RECORD_VOLUME_ACK,
// SDB_SET_FOCUS_POINT                           0                                  0                     SDB_STATE            {x,y}
// SDB_PUSH_FOCUS_STATUS                         0                                  0                     0                    {0}
// SDB_PUSH_FOCUS_STATUS_ACK                    0/1                                 0                     SDB_STATE            {0}

// SDB_SET_FILTER_MODE                          DEV_BWDISPLAY_STATE                 0                     0                     0
// SDB_GET_FILTER_MODE                           0                                  0                     0                    {0}
// SDB_GET_FILTER_MODE_ACK                      DEV_BWDISPLAY_STATE                 0                     0                    {0}

#define SERVER_CTL_PORT       5102
#define SERVER_DATA_PORT      5103
#define SERVER_BROADCAST_PORT 7787
#define SERVER_LIVEVIEW_PORT  61001

#endif
