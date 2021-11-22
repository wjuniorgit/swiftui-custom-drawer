//
//  CustomDrawerModifier.swift
//  
//
//  Created by Wellington Soares on 11/20/21.
//

import SwiftUI

extension View {
  func customDrawer<
    DrawerContent,
    DrawerBackground,
    DrawerOverlay
  >(
    isPresenting: Binding<Bool>,
    direction: DrawerDirection = .top,
    onDisappear: @escaping () -> Void = {},
    onClose: @escaping () -> Void = {},
    drawerPadding: CGFloat = 0,
    drawerBackground: DrawerBackground,
    drawerOverlay: DrawerOverlay,
    overlayColor: Color = Color.white,
    @ViewBuilder drawerContent: @escaping () -> DrawerContent
  ) -> some View where
    DrawerContent: View,
    DrawerBackground: View,
    DrawerOverlay: View {
    modifier(
      CustomDrawerIsPresenting(
        isPresenting: isPresenting,
        direction: direction,
        onDisappear: onDisappear,
        onClose: onClose,
        drawerPadding: drawerPadding,
        drawerBackground: drawerBackground,
        drawerOverlay: drawerOverlay,
        overlayColor: overlayColor,
        drawerContent: drawerContent
      )
    )
  }
}

struct CustomDrawerIsPresenting<
  DrawerContent,
  DrawerBackground,
  DrawerOverlay
>: ViewModifier where
  DrawerContent: View,
  DrawerBackground: View,
  DrawerOverlay: View {
  @Binding var isPresenting: Bool
  let direction: DrawerDirection
  let onDisappear: () -> Void
  let onClose: () -> Void
  let drawerPadding: CGFloat
  let drawerBackground: DrawerBackground
  let drawerOverlay: DrawerOverlay
  let overlayColor: Color
  @ViewBuilder var drawerContent: () -> DrawerContent
  
  func body(content: Content) -> some View {
    CustomDrawer(
      isPresented: isPresenting,
      updateIsPresented: { if isPresenting != $0 { isPresenting = $0 } },
      direction: direction,
      onDisappear: { onDisappear() },
      onClose: { onClose() },
      drawerPadding: drawerPadding,
      drawerBackground: drawerBackground,
      drawerOverlay: drawerOverlay,
      overlayColor: overlayColor,
      parentView: content,
      drawerContent: drawerContent()
    )
  }
}
