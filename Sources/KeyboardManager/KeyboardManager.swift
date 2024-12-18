// The Swift Programming Language
// https://docs.swift.org/swift-book
//

import Foundation
import UIKit

///
/// 시스템 키보드 관련 관리 클래스
///
/// - Parameters:
/// - Returns:
///
public class KeyboardManager {
    /// 콜백
    var callback: KeyboardManangerProtocol?
    
    /// 키보드 활성화 유무
    public var isKeyboardShown: Bool = false
    
    /// 키보드 높이
    public var keyboardHeight: CGFloat?
    
    /// 키보드 감지 활성화 유무 = 여러번 호출되는것을 방지하기위함 Bool 타입의 변수
    public var isMonitoringStart: Bool = false
    
    /// 키보드 활성화 유무
    public var requestKeyboardHidden: Bool = false
    ///
    /// 키보드 이벤트 감지 모니터링 시작
    ///
    /// - Parameters:
    /// - Returns:
    ///
    
    public init() {
    }
    
    deinit {
        print("KeyboardManager deinit")
    }
    
    public func unreference() {
        self.hideKeyboard()
        self.callback = nil
        self.stopMonitoring()
    }
    
    public func startMonitoring() {
        if isMonitoringStart { return }
        isMonitoringStart = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        print("키보드 모니터링 시작")
    }
    
    
    
    ///
    /// 키보드 이벤트 감지 모니터링 종료
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func stopMonitoring() {
        if !isMonitoringStart { return }
        isMonitoringStart = false
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        callback = nil
        print("키보드 모니터링 해제")
    }
    
    ///
    /// 프로토콜을 통한 감지 이벤트 콜백등록
    ///
    /// - Parameters:
    ///    - <#파라미터#> ( <#타입#> ) : <#설명#>
    /// - Returns:
    ///
    public func setCallback(callback: KeyboardManangerProtocol) {
        startMonitoring()
        self.callback = callback
    }
    
    public func removeCallback () {
        self.callback = nil
        stopMonitoring()
    }
    
    
    ///
    /// 키보드 활성화 콜백이벤트
    ///
    /// - Parameters:
    /// - Returns:
    ///
    @objc func keyBoardWillShow(notification: NSNotification) {
        if isKeyboardShown { return }
        isKeyboardShown = true
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue)
            .cgRectValue.height
        
        self.keyboardHeight = keyboardHeight
        callback?.keyBoardWillShow(notification: notification, keyboardHeight: keyboardHeight)
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        if !isKeyboardShown { return }
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue)
            .cgRectValue.height
        if self.keyboardHeight != keyboardHeight {
            self.keyboardHeight = keyboardHeight
            callback?.keyBoardWillShow(notification: notification, keyboardHeight: keyboardHeight)
        }
    }


    ///
    /// 키보드 비활성화 콜백이벤트
    ///
    /// - Parameters:
    /// - Returns:
    ///
    @objc func keyBoardWillHide(notification: NSNotification) {
        if !isKeyboardShown { return }
        isKeyboardShown = false
        
        callback?.keyBoardWillHide(notification: notification)
        self.requestKeyboardHidden = false
    }
    
    
    ///
    /// 시스템 키보드 수동으로 여는 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func showKeyboard() {
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder),
                                            to: nil,
                                            from: nil,
                                            for: nil)
        }
    }
    
    
    ///
    /// 시스템 키보드 수동으로 닫는 함수
    ///
    /// - Parameters:
    /// - Returns:
    ///
    public func hideKeyboard() {
        self.requestKeyboardHidden = true
        DispatchQueue.main.async {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil,
                                            from: nil,
                                            for: nil)
        }
        
    }
}
