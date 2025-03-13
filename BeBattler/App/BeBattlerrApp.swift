
import SwiftUI

@main
struct BeBattler: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var vm = ViewModel()
    @StateObject private var hapticGenerator = HapticGenerator()
    
    let sound = SoundManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .onAppear {
                    hapticGenerator.prepareHaptics()
                    if vm.musicOn {
                        sound.playSound(.background)
                    }
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        DispatchQueue.main.async {
                            hapticGenerator.prepareHaptics()
                        }
                    }
                }
                .onChange(of: vm.musicOn) { newValue in
                    if newValue == false {
                        sound.stopPlay()
                    } else {
                        sound.playSound(.background)
                    }
                }
            
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    static var asiuqzoptqxbt = UIInterfaceOrientationMask.landscape {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: asiuqzoptqxbt))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if asiuqzoptqxbt == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.asiuqzoptqxbt
    }
}


