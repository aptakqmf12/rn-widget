// SharedDataManager.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SharedDataManager, NSObject)

// 기존 데이터 저장 함수
RCT_EXTERN_METHOD(saveTodosToSharedDefaults:(NSString *)todosJsonString)

// ⭐️ 새로 추가된 위젯 리로드 함수
RCT_EXTERN_METHOD(reloadWidgetTimelines)

// (선택 사항) 데이터 가져오는 함수 (Promise로 변경할 수 있습니다)
 RCT_EXTERN_METHOD(getTodosFromSharedDefaults
                   resolver:(RCTPromiseResolveBlock)resolve
                   rejecter:(RCTPromiseRejectBlock)reject)

@end
