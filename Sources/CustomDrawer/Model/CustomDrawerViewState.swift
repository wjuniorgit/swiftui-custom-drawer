//
//  CustomDrawerViewState.swift
//  
//
//  Created by Wellington Soares on 03/08/21.
//

import Foundation
import SwiftUI

struct DrawerViewState: Equatable {
  // The current position of the drawer on the screen, 0 is fully open.
  let drawerOffset: CGFloat
  // Drawer open or closed state.
  let isOpen: Bool
  // Maximum lenght of the drawer on the screen.
  let maxScreenLength: CGFloat
  // Full drawer content lenght visible or not.
  let fullContentLength: CGFloat
  // Used when drawer content is lengthier than available area.
  // Last scrolled position inside the drawer
  let lastScrollDrag: CGFloat
  // Flag for fullscreen drawer
  let isFullScreen: Bool
  // The current offset of the drawer content
  let scrollContentOffset: CGFloat
  // The stored offset of the drawer content for the next gesture
  let initialOffset: CGFloat
  // Drawer gat between  end of drawer and screen
  let drawerPadding: CGFloat
  
  // The current length of the drawer
  var maxDrawerLength: CGFloat {
    maxScreenLength - drawerPadding
  }
  
  // The current length of the drawer
  var visibleDrawerLength: CGFloat {
    fullContentLength > maxDrawerLength ?
      maxDrawerLength : fullContentLength
  }
  
  // 0 .. 1 proportionally to how open the drawer is
  var openPercentage: Double {
    let difference = visibleDrawerLength - abs(drawerOffset)
    let value = Double(difference / visibleDrawerLength)
    return !isOpen
      ? 0
      : value < 0
      ? 0
      : value > 1
      ? 1
      : value
  }
  
  func copyWith(
    drawerOffset: CGFloat? = nil,
    isOpen: Bool? = nil,
    maxScreenLength: CGFloat? = nil,
    fullContentLength: CGFloat? = nil,
    lastScrollDrag: CGFloat? = nil,
    isFullScreen: Bool? = nil,
    scrollContentOffset: CGFloat? = nil,
    initialOffset: CGFloat? = nil,
    drawerPadding: CGFloat? = nil
  ) -> DrawerViewState {
    let drawerOffset: CGFloat = drawerOffset ?? self.drawerOffset
    let isOpen: Bool = isOpen ?? self.isOpen
    let maxScreenLength: CGFloat = maxScreenLength ?? self.maxScreenLength
    let fullContentLength: CGFloat = fullContentLength ?? self.fullContentLength
    let lastScrollDrag: CGFloat = lastScrollDrag ?? self.lastScrollDrag
    let isFullScreen: Bool = isFullScreen ?? self.isFullScreen
    let scrollContentOffset: CGFloat = scrollContentOffset ?? self
      .scrollContentOffset
    let initialOffset: CGFloat = initialOffset ?? self.initialOffset
    let drawerPadding: CGFloat = drawerPadding ?? self.drawerPadding
    return DrawerViewState(
      drawerOffset: drawerOffset,
      isOpen: isOpen,
      maxScreenLength: maxScreenLength,
      fullContentLength: fullContentLength,
      lastScrollDrag: lastScrollDrag,
      isFullScreen: isFullScreen,
      scrollContentOffset: scrollContentOffset,
      initialOffset: initialOffset,
      drawerPadding: drawerPadding
    )
  }
}
