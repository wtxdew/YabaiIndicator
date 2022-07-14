//
//  ContentView.swift
//  YabaiIndicator
//
//  Created by Max Zhao on 26/12/2021.
//

import SwiftUI


struct LayoutButton : View {
    @AppStorage("buttonStyle") private var buttonStyle = ButtonStyle.numeric
    var actspace: ActSpace
    func getText() -> String {
        let layout = actspace.type
        if layout == "bsp" {
            return "[]="
        } else if layout == "float" {
            return "><>"
        } else if layout == "stack"{
            return "[\(actspace.windows.count)]"
        } else {
            return "ERR"
        }
    }
    
    func changeButtonStyle() {
        if buttonStyle == .numeric {
            buttonStyle = .windows
        } else {
            buttonStyle = .numeric
        }
    }
    
    var body: some View {
        Image(nsImage: generateImage(symbol: getText() as NSString, layout: true))
            .onTapGesture { changeButtonStyle() }
            .frame(width:24, height: 16)
    }
}

struct SpaceButton : View {
    var space: Space
    var yabaispace: [ActSpace]
    
    func getText() -> String {
        switch space.type {
        case .standard:
            let id = space.yabaiIndex
            var label : String = "\(id)"
            if yabaispace.indices.contains(0){
                if yabaispace[0].windows.count > 0 { label += "º" }
            }
            return label
        case .fullscreen:
            return "F"
        case .divider:
            return ""
        }
    }
    
    func getText_icon() -> String {
        let spaceIcon = ["0", "</>", "G", "3", "4", "5", "6", "7", "8", "9"]
        switch space.type {
        case .standard:
            let id = space.yabaiIndex
            var output: String = ""
            if spaceIcon.indices.contains(id){
                output = spaceIcon[id]
            }
            return "\(output)"
        case .fullscreen:
            return "F"
        case .divider:
            return ""
        }
    }
    
    func switchSpace() {
        if !space.active && space.yabaiIndex > 0 {
            gYabaiClient.focusSpace(index: space.yabaiIndex)
        }        
    }
    
    var body: some View {
        if space.type == .divider {
            Divider().background(Color(.systemGray)).frame(height: 14)
        } else {
            Image(nsImage: generateImage(symbol: getText() as NSString, active: space.active, visible: space.visible))
                .onTapGesture { switchSpace() }
                .frame(width:24, height: 16)
        }
    }
}

struct WindowSpaceButton : View {
    var space: Space
    var windows: [Window]
    var displays: [Display]
    
    func switchSpace() {
        if !space.active && space.yabaiIndex > 0 {
            gYabaiClient.focusSpace(index: space.yabaiIndex)
        }
    }
    
    var body : some View {
        switch space.type {
        case .standard:
            Image(nsImage: generateImage(active: space.active, visible: space.visible, windows: windows, display: displays[space.display-1])).onTapGesture {
                switchSpace()
            }.frame(width:24, height: 16)
        case .fullscreen:
            Image(nsImage: generateImage(symbol: "F" as NSString, active: space.active, visible: space.visible)).onTapGesture {
                switchSpace()
            }
        case .divider:
            Divider().background(Color(.systemGray)).frame(height: 14)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var spaceModel: SpaceModel
    @AppStorage("showDisplaySeparator") private var showDisplaySeparator = true
    @AppStorage("showCurrentSpaceOnly") private var showCurrentSpaceOnly = false
    @AppStorage("buttonStyle") private var buttonStyle: ButtonStyle = .numeric
    
    private func generateSpaces() -> [Space] {
        var shownSpaces:[Space] = []
        var lastDisplay = 0
        for space in spaceModel.spaces {
            if lastDisplay > 0 && space.display != lastDisplay {
                if showDisplaySeparator {
                    shownSpaces.append(Space(spaceid: 0, uuid: "", visible: true, active: false, display: 0, index: 0, yabaiIndex: 0, type: .divider))
                }
            }
            if space.visible || !showCurrentSpaceOnly{
                shownSpaces.append(space)
            }
            lastDisplay = space.display
        }
        return shownSpaces
    }
    
    private func getActiveSpace() -> ActSpace {
        var focusSpace : ActSpace = ActSpace(id: 0, uuid: "nil", index: 0, type: "nil", windows: [], active: false)
        for actspace in spaceModel.actspace {
            if actspace.active {
                focusSpace = actspace
                break
            }
        }
        return focusSpace
    }
    
    var body: some View {
        HStack (spacing: 4) {
            if buttonStyle == .numeric || spaceModel.displays.count > 0 {
                let activeSpace = getActiveSpace()
                LayoutButton(actspace: activeSpace)
                ForEach(generateSpaces(), id: \.self) {space in
                    switch buttonStyle {
                    case .numeric:
                        SpaceButton(space: space, yabaispace: spaceModel.actspace.filter{$0.index == space.yabaiIndex})
                    case .windows:
                        WindowSpaceButton(space: space, windows: spaceModel.windows.filter{$0.spaceIndex == space.yabaiIndex}, displays: spaceModel.displays)
                    }
                }
            }
        }.padding(2)
    }
}
