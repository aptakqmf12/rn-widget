// swift 개발환경인 경우 .swift 클래스에 코드 구현부 작성 후 .m 클래스를 통해 Objective-C인 ReactNative 환경에서 사용할 수 있도록 연결해주어야 한다.
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SharedDataManager, NSObject)

// 기존 데이터 저장 함수
RCT_EXTERN_METHOD(saveTodosToSharedDefaults:(NSString *)todosJsonString
               resolver:(RCTPromiseResolveBlock)resolve
               rejecter:(RCTPromiseRejectBlock)reject)

// ⭐️ 새로 추가된 위젯 리로드 함수 (이 부분이 현재는 Promise 없음)
// RCT_EXTERN_METHOD(reloadWidgetTimelines) // 주석 처리 또는 제거

// (선택 사항) 데이터 가져오는 함수 (Promise로 변경할 수 있습니다)
RCT_EXTERN_METHOD(getTodosFromSharedDefaults
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
