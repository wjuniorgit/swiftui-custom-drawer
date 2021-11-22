//
//  CustomDrawer.swift
//  Custom SwiftUI Drawer
//
//  Created by Wellington Soares on 03/08/21.
//

import SwiftUI

@available(iOS 14, *)
public struct CustomDrawer<
  DrawerContent,
  DrawerBackground,
  DrawerOverlay,
  ParentView
>: View
  where DrawerContent: View,
  DrawerBackground: View,
  DrawerOverlay: View,
  ParentView: View {
  // Constructor
  let isPresented: Bool
  let direction: DrawerDirection
  let onDisappear: () -> Void
  let drawerPadding: CGFloat
  let drawerBackground: DrawerBackground
  let drawerOverlay: DrawerOverlay
  let overlayColor: Color
  let parentView: ParentView
  let drawerContent: DrawerContent

  public init(
    isPresented: Bool,
    updateIsPresented: @escaping (Bool) -> Void,
    direction: DrawerDirection,
    onDisappear: @escaping () -> Void,
    onClose: @escaping () -> Void,
    drawerPadding: CGFloat,
    drawerBackground: DrawerBackground,
    drawerOverlay: DrawerOverlay,
    overlayColor: Color,
    parentView: ParentView,
    drawerContent: DrawerContent
  ) {
    self.isPresented = isPresented
    self.direction = direction
    self.onDisappear = onDisappear
    self.drawerPadding = drawerPadding
    self.drawerBackground = drawerBackground
    self.drawerOverlay = drawerOverlay
    self.overlayColor = overlayColor
    self.parentView = parentView
    self.drawerContent = drawerContent
    _viewModel =
      StateObject(
        wrappedValue: CustomDrawerViewModel(
          updateIsPresented: updateIsPresented,
          onClose: onClose
        )
      )
  }

  // States
  @StateObject var viewModel: CustomDrawerViewModel

  // Object that stores the drag gesture value.
  @GestureState private var dragAmount = CGSize.zero

  @State var viewsWarmedUp = false

  public var body: some View {
    parentView
      .background(maxScreenLengthListener)
      .onAppear {
        if isPresented {
          self.viewModel.scheduleTimer {
            self.viewModel.isPresentedUpdated(isPresented)
          }
        }
        if drawerPadding != self.viewModel.state.drawerPadding {
          self.viewModel.updateDrawerPadding(drawerPadding)
        }
      }
      .onChange(of: drawerPadding) { value in
        if value != self.viewModel.state.drawerPadding {
          self.viewModel.updateDrawerPadding(value)
        }
      }
      .onChange(of: isPresented) { value in
        self.viewModel.isPresentedUpdated(value)
      }
      .compositingGroup()
      .blur(radius: CGFloat(self.viewModel.state.openPercentage) * 3)
      .overlay(
        ZStack(alignment: zStackAlignmentForDirection(self.direction)) {
          overlayColor
            .ignoresSafeArea()
            .opacity(self.viewModel.state.openPercentage * 0.4)
            .gesture(drawerDragGesture)
            .onTapGesture {
              withAnimation(.spring()) {
                if self.viewModel.state.isOpen {
                  self.viewModel.updateIsOpen(false)
                }
              }
            }
          ZStack {
            if self.viewModel.state.isOpen {
              if !viewsWarmedUp {
                drawerContent
                  .opacity(0)
                  .background(fullContentLengthListener)
                  .allowsHitTesting(false)
                  .onAppear {
                    self.viewModel.updateIsOpen(
                      false,
                      animated: false,
                      updateExternalState: false
                    )
                    viewsWarmedUp = true
                    self.viewModel.updateIsOpen(
                      true,
                      updateExternalState: false
                    )
                  }
              } else {
                wrappedContent
                  .offset(
                    y: verticalOffsetForDirection(
                      self.viewModel.state.drawerOffset,
                      self.direction
                    )
                  )
                  .onChange(of: dragAmount.height) { value in
                    // gesture ended
                    if value == 0 {
                      self.viewModel.onDragGestureEnded()
                    } else {
                      // is dragging
                      self.viewModel.onDragGesture(
                        value,
                        direction: self.direction
                      )
                    }
                  }
                  .highPriorityGesture(drawerDragGesture)
                  .transition(
                    .drawerMove(
                      direction: self.direction,
                      drawerLength: self.viewModel.state
                        .visibleDrawerLength,
                      isFullscreen: self.viewModel.state.isFullScreen
                    )
                  )
                  .onDisappear {
                    self.viewsWarmedUp = false
                    self.onDisappear()
                  }
              }
            }
          }
        }
      )
  }

  private var drawerDragGesture: some Gesture {
    DragGesture()
      .updating($dragAmount) { value, state, _ in
        // Updates the drag gesture value
        state = value.translation
      }
  }

  var maxScreenLengthListener: some View {
    GeometryReader { parentViewGeo in
      Color.clear
        .onAppear {
          self.viewModel.updateMaxScreenLength(parentViewGeo.size.height)
        }
        .onChange(of: parentViewGeo.size.height) { height in
          if self.viewModel.state.isOpen {
            self.viewModel.updateIsOpen(
              false,
              animated: false,
              updateExternalState: false
            )
            self.viewModel.scheduleTimer {
              self.viewModel.updateIsOpen(true, updateExternalState: false)
            }
          }
          self.viewModel.updateMaxScreenLength(height)
        }
    }
  }

  var fullContentLengthListener: some View {
    GeometryReader { drawerViewGeo in
      Color.clear
        .onChange(of: drawerViewGeo.size.height) { height in
          self.viewModel.updateFullContentLength(height)
        }
        .onAppear {
          self.viewModel.updateFullContentLength(drawerViewGeo.size.height)
        }
    }
  }

  // Wrapped Content //

  var wrappedContent: some View {
    ZStack {
      ZStack {
        drawerContent
          .background(fullContentLengthListener)
          .offset(
            y: verticalOffsetForDirection(
              self.viewModel.state.scrollContentOffset,
              self.direction
            )
          )
          .frameWithDirection(
            direction: self.direction,
            lenght: self.viewModel.state.visibleDrawerLength
          )
          .clipped()
          .background(drawerBackground)
          .overlay(drawerOverlay)
      }
      .compositingGroup()
      .shadow(
        radius: 4,
        x: 0,
        y: 2
      )
    }
    .compositingGroup()
  }
}
