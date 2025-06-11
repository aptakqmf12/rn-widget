// swift 개발환경인 경우 .swift 클래스에 코드 구현부 작성 후 .m 클래스를 통해 Objective-C인 ReactNative 환경에서 사용할 수 있도록 연결해주어야 한다.
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(SharedDataManager, NSObject)

RCT_EXTERN_METHOD(saveTodosToSharedDefaults:(NSString *)todosJsonString
               resolver:(RCTPromiseResolveBlock)resolve
               rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getTodosFromSharedDefaults
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
