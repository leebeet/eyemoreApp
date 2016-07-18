//
//  CMDManager.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/8/25.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#ifndef _DBSmartCameraDemo_CMDManager_h
#define _DBSmartCameraDemo_CMDManager_h

#define kBatchNumber 4


#define CMDDownloadAllFiles               {SDB_GET_BLOCK_NORMAL_PHOTOS,     0,                       self.fileList.paramn[0], 0, {0}}
#define CMDDownloadBatchFiles             {SDB_GET_BLOCK_NORMAL_PHOTOS,     0,                       kBatchNumber,            0, {0}}
#define CMDDownloadRestFiles(count)       {SDB_GET_BLOCK_NORMAL_PHOTOS,     0,                       count,                   0, {0}}
#define CMDSetPhotoToDDR                  {SDB_SET_DEV_WORK_MODE,           DWM_FLASH_PHOTO,         0,                       0, {0}}
#define CMDSetPhotoToSDCard               {SDB_SET_DEV_WORK_MODE,           DWM_NORMAL,              0,                       0, {0}}
#define CMDGetDeviceInfo                  {SDB_GET_DEVICEINFO,              0,                       0,                       0, {0}}
#define CMDGetFileList                    {SDB_GET_NORMAL_PHOTO_COUNT,      0,                       0,                       0, {0}}
#define CMDOpenDataChannel                {SDB_SET_DEV_DATA_CHANNEL,        DWM_OPEN,                0,                       0, {0}}
#define CMDCloseDataChannel               {SDB_SET_DEV_DATA_CHANNEL,        DWM_CLOSE,               0,                       0, {0}}
#define CMDRemoteSnapshot(COUNT)          {SDB_SET_SNAPSHOT,                COUNT,                   0,                       0, {1}}
#define CMDSetStandbyState(STATE)         {SDB_SET_STANDBY_EN,              STATE,                   0,                       0, {0}}
#define CMDGetDebugInfo                   {SDB_GET_DEBUG_INFO,              0,                       0,                       0, {0}}
#define CMDGetDevInfo                     {SDB_GET_DEVICEINFO,              0,                       0,                       0, {0}}
#define CMDSetPowerOffTime(MINUTES)       {SDB_SET_POWER_OFF_TIME,          MINUTES,                 0,                       0, {0}}
#define CMDReceiveOInMode(MODE)           {SDB_SET_RECV_OK      ,           MODE,                    0,                       0, {0}}
#define CMDGetUploadState                 {SDB_GET_UPLOAD_STATE,            0,                       0,                       0, {0}}
#define CMDGetNetworkLogFile              {SDB_GET_LOG_FILE,                0,                       0,                       0, {0}}
#define CMDDeleteAllJPGs                  {SDB_DELETE_ALL_JPEG,             0,                       0,                       0, {0}}

//Lens CMD
#define CMDGetLensStatus                  {SDB_GET_LENS_PARAMS,             0,                       0,                       0, {0}}
#define CMDSetIRISParams(VALUE)           {SDB_SET_IRIS_PARAM,              VALUE,                   0,                       0, {0}}
#define CMDFactoryReset                   {SDB_SET_UPLOAD_ZYNQ_FIRMWARE,    DEV_RESTORE_FACTORY_SET, 0,                       0, {0}}
#define CMDSetLensFocusState(STATE)       {SDB_SET_LENS_FOCUS_PARAM,        STATE,                   0,                       0, {0}}
#define CMDSetBWDisplayParam(STATE)       {SDB_SET_BWDISPLAY_PARAM,         STATE,                   0,                       0, {0}}
#define CMDSetExposureValueParam(VALUE)   {SDB_SET_EXPOSURE_PARAM,          VALUE,                   0,                       0, {0}}
#define CMDSetExposureMode(VALUE)         {SDB_SET_EXPOSURE_MODE,           VALUE,                   0,                       0, {0}}
#define CMDSetShutterParam(VALUE)         {SDB_SET_SHUTTER_PARAM,           VALUE,                   0,                       0, {0}}
#define CMDUploadSingleFileWithData(DATA) {SDB_SET_UPLOAD_ZYNQ_FIRMWARE,    DEV_UPLOAD_NEW,          0,                       0, {(unsigned int)[DATA length]}}
#define CMDUploadSingleFileWithDataWithCheckSum(CHECKSUM, DATA) {SDB_SET_UPLOAD_ZYNQ_FIRMWARE,DEV_UPLOAD_NEW,0,               0, {(unsigned int)[DATA length], CHECKSUM}}
#define CMDUploadGeneralFile              {SDB_UPLOAD_GENFILE,              0,                       0,                       0, {0}}
#define CMDSetStandbyEnable(STATE)        {SDB_SET_STANDBY_EN,              STATE,                   0,                       0, {0}}
#define CMDSetEVFBackLight(VALUE)         {SDB_SET_EVF_BACKLIGHT,           VALUE,                   0,                       0, {0}}
#define CMDSaveParams                     {SDB_SET_SAVE_PARAMS,             0,                       0,                       0, {0}}
#define CMDSetFocusPoint(POINTX, POINTY)  {SDB_SET_FOCUS_POINT,             0,                       0,                       0, {POINTX,POINTY}}
#define CMDGetFocusState                  {SDB_PUSH_FOCUS_STATUS,           0,                       0,                       0, {0}}
#define CMDSetFilterMode(STATE)           {SDB_SET_FILTER_MODE,             STATE,                   0,                       0, {0}}
#define CMDGetFilterMode                  {SDB_GET_FILTER_MODE,             0,                       0,                       0, {0}}

//video CMD
#define CMDBeginRecordConifg(RESOLUTION, FPS) {SDB_BEGIN_RECORD,            0,                       0,                       0, {RESOLUTION, FPS}}
#define CMDTimeLapseRecordConifg(RESOLUTION, FPS, MULTI, FRAMECOUNT) {SDB_BEGIN_RECORD,              0,                       0,  0, {RESOLUTION, FPS, MULTI, FRAMECOUNT}}

#define CMDEndingRecord                   {SDB_END_RECORD,                  0,                       0,                       0, {0}}
#define CMDGetRecordNum                   {SDB_GET_RECORD_NUM,              0,                       0,                       0, {0}}
#define CMDGetRecordDESWithID(NO)         {SDB_GET_RECORD_DES,              0,                       0,                       0, {NO}}
#define CMDGetVideoHeadWithID(NO)         {SDB_GET_FILE_HEAD,               0,                       0,                       0, {NO}}
#define CMDGetFirstFrameWithID(NO)        {SDB_GET_FIRST_FRAME,             0,                       0,                       0, {NO}}
#define CMDGetFrameWithIDWithStartIndexWithAmount(NO,INDEX,NUM) {SDB_GET_FRAME,   0,                 0,                       0, {NO,INDEX,NUM}}
#define CMDDeleteVideoWithID(NO)          {SDB_DELETE_VIDEO,                0,                       0,                       0, {NO}}
#define CMDGetLiveFrameWithIndex(INDEX)   {SDB_GET_LIVE_FRAME,              0,                       0,                       0, {INDEX}}
#define CMDGetCurrentRecordNum            {SDB_CURRENT_RECORD_NUM,          0,                       0,                       0, {0}}

//Sound CMD
#define CMDSetSoundEnable(ENABLE)         {SDB_SET_SOUND_ENABLE,            ENABLE,                  0,                       0, {0}}
#define CMDSetSoundVolume(VALUE)          {SDB_SET_SOUND_VOLUME,            VALUE,                   0,                       0, {0}}
#define CMDSetSoundRecordVolume(VALUE)    {SDB_SET_SOUND_RECORD_VOLUME,     VALUE,                   0,                       0, {0}}
#define CMDGetSoundEnable                 {SDB_GET_SOUND_ENABLE,            0,                       0,                       0, {0}}
#define CMDGetSoundVolume                 {SDB_GET_SOUND_VOLUME,            0,                       0,                       0, {0}}
#define CMDGetSoundRecordVolume           {SDB_GET_SOUND_RECORD_VOLUME,     0,                       0,                       0, {0}}
#define CMDGetSoundIfExsit                {SDB_GET_SOUND_FILE_EXIST,        0,                       0,                       0, {0}}

//Photo CMD
#define CMDCleanPhotoInfo                 {SDB_SET_JPG_EXIF_PARAMS,         JPG_EXIF_FILE_ID,        0,                       0, {0}}

#endif
