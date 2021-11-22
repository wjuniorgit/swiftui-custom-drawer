//
//  CustomDrawerViewModel.swift
//  
//
//  Created by Wellington Soares on 03/08/21.
//


import SwiftUI
import Foundation
import UIKit

class CustomDrawerViewModel: ObservableObject {
  @Published private(set) var state: DrawerViewState
  // Timer for delayed events
  private var timer: Timer?
  private let updateIsPresented: (Bool) -> Void
  private let onClose: () -> Void
  
  init(
    updateIsPresented: @escaping (Bool) -> Void,
    onClose: @escaping () -> Void
  ) {
    self.updateIsPresented = updateIsPresented
    self.onClose = onClose
    state = .init(
      drawerOffset: 0,
      isOpen: false,
      maxScreenLength: 0,
      fullContentLength: 0,
      lastScrollDrag: 0,
      isFullScreen: false,
      scrollContentOffset: 0,
      initialOffset: 0,
      drawerPadding: 0
    )
  }
  
  func scheduleTimer(callback: @escaping () -> Void) {
    timer?.invalidate()
    timer = nil
    timer = Timer.scheduledTimer(
      withTimeInterval: 0.3,
      repeats: false
    ) { _ in
      callback()
      self.timer?.invalidate()
    }
  }
  
  func updateMaxScreenLength(_ newValue: CGFloat) {
    let isFullScreen = checkIfIsFullscreen(newValue)
    let newState = state.copyWith(
      maxScreenLength: newValue,
      isFullScreen: isFullScreen
    )
    publishNewState(newState)
  }
  
  func updateFullContentLength(_ newValue: CGFloat) {
    let newState = state.copyWith(
      fullContentLength: newValue
    )
    publishNewState(newState)
  }
  
  func isPresentedUpdated(_ newValue: Bool) {
    if newValue != state.isOpen {
      updateIsOpen(newValue)
    }
  }
  
  func updateIsOpen(
    _ newValue: Bool,
    animated: Bool = true,
    updateExternalState: Bool = true
  ) {
    let newState = state.copyWith(
      isOpen: newValue,
      scrollContentOffset: !newValue
        ? 0
        : state.scrollContentOffset
    )
    publishNewState(
      newState,
      animated: animated,
      updateExternalState: updateExternalState
    )
  }
  
  func updateDrawerPadding(_ newValue: CGFloat) {
    let newState = state.copyWith(drawerPadding: newValue)
    publishNewState(newState, animated: false)
  }
  
  func onDragGesture(_ value: CGFloat, direction: DrawerDirection) {
    var newState = state.copyWith()
    
    if newState.fullContentLength < newState.maxDrawerLength {
      var newOffset: CGFloat = 0
      switch direction {
        case .bottom:
          newOffset = value
        case .top:
          newOffset = -1 * value
      }
      if newOffset < 0 {
        newState = newState.copyWith(drawerOffset: newOffset)
      }
      // If drawer content is lengthier than available space
      // This is used to scroll the drawer content alongside the drawer
    } else {
      switch direction {
        case .bottom:
          let newOffset = newState.initialOffset + value
          
          if checkIfShouldScrollDrawerContent(
            newOffset,
            newState.fullContentLength,
            newState.maxDrawerLength
          ) {
            //  withAnimation(.linear) {
            newState = newState.copyWith(
              lastScrollDrag: value,
              scrollContentOffset: newOffset
            )
            //  }
          } else {
            let newDrawerOffset = (value - newState.lastScrollDrag)
            if newDrawerOffset < 0 {
              newState = newState.copyWith(drawerOffset: newDrawerOffset)
            }
          }
          
        case .top:
          let newOffset = newState.initialOffset + (-1 * value)
          
          if checkIfShouldScrollDrawerContent(
            newOffset,
            newState.fullContentLength,
            newState.maxDrawerLength
          ) {
            //   withAnimation(.linear) {
            newState = newState.copyWith(
              lastScrollDrag: value,
              scrollContentOffset: newOffset
            )
            
            //   }
          } else {
            let newDrawerOffset =
              (-1 * (value - newState.lastScrollDrag))
            if newDrawerOffset < 0 {
              newState = newState.copyWith(drawerOffset: newDrawerOffset)
            }
          }
      }
    }
    
    func checkIfShouldScrollDrawerContent(
      _ newOffset: CGFloat,
      _ fullContentLenght: CGFloat,
      _ maxDrawerLenght: CGFloat
    ) -> Bool {
      newOffset <= (fullContentLenght - maxDrawerLenght) +
        maxDrawerLenght * 0.05 && newOffset >=
        -(maxDrawerLenght * 0.05)
    }
    
    publishNewState(newState, animated: false)
  }
  
  func onDragGestureEnded() {
    var newState = state.copyWith()
    
    // Decides if should close or keep drawer open
    //  withAnimation(.spring()) {
    let newIsOpen = newState.drawerOffset > -newState
      .visibleDrawerLength / 3 ? true : false
    newState = newState.copyWith(drawerOffset: 0, isOpen: newIsOpen)
    //  }
    
    // Scrolls the content of the drawer back to the end when stretched
    if newState.scrollContentOffset >
        (newState.fullContentLength - newState.maxDrawerLength) {
      //   withAnimation(.spring()) {
      let newScrollContentOffset = newState.fullContentLength -
        newState.maxDrawerLength
      newState = newState.copyWith(
        lastScrollDrag: 0,
        scrollContentOffset: newScrollContentOffset
      )
      //  }
    }
    
    // Scrolls the content of the drawer back to the beggining when stretched
    if newState.scrollContentOffset < 0 {
      //   withAnimation(.spring()) {
      newState = newState.copyWith(
        lastScrollDrag: 0,
        scrollContentOffset: 0
      )
      //   }
    }
    
    // Stores the current drawer content scroll offset for the next gesture
    newState = newState.copyWith(initialOffset: newState.scrollContentOffset)
    publishNewState(newState)
  }
  
  private func publishNewState(
    _ newState: DrawerViewState,
    animated: Bool = true,
    updateExternalState: Bool = true
  ) {
    if state.isOpen,
       !newState.isOpen,
       updateExternalState {
      onClose()
      updateIsPresented(false)
    }
    
    if newState != state {
      withAnimation(animated ? .spring() : nil) {
        state = newState
      }
    }
  }
  
  func checkIfIsFullscreen(
    _ maxDrawerLength: CGFloat
  ) -> Bool {
    guard let screen = UIApplication.shared.windows.first else {
      return false
    }
    
    let safeAreas = screen.safeAreaInsets.top + screen.safeAreaInsets.bottom
    let screenLength = UIScreen.main.bounds.size.height
    return screenLength - safeAreas == maxDrawerLength
  }
}
