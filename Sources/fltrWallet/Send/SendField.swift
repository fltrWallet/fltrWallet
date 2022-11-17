//===----------------------------------------------------------------------===//
//
// This source file is part of the fltrWallet open source project
//
// Copyright (c) 2022 fltrWallet AG and the fltrWallet project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import SwiftUI

struct SendTextFieldStyle: TextFieldStyle {
    let placeholder: String
    let error: String?
    let isActive: Bool
    @State var yOffset: CGFloat = .zero
    @ScaledMetric(relativeTo: .headline) var fontSize: CGFloat = 20
    @ScaledMetric(relativeTo: .headline) var scale: CGFloat = 1

    func _body(configuration: TextField<_Label>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            ZStack(alignment: .leading) {
                
                Text(placeholder)
                    .offset(x: isActive ? 0 : 10, y: isActive ? -28 - fontSize/2.4 : 0)
                    .font(.system(size: isActive ? fontSize * 0.9 : fontSize, weight: .light))
                    .foregroundColor(isActive ? Color.secondary : Color.gray)
                    .animation(.default)
                
                configuration
                    .foregroundColor(isActive ? Color("newGray") : Color.clear)
                    .font(.system(size: fontSize, weight: .light))
                    .padding(.bottom, 9)
                    .background(
                        UnderlineShape()
                            .stroke()
                            .foregroundColor(Color("newGray"))
                    )
            }
            .padding(.bottom, 5)

            Text(error.map({ "* \($0)" }) ?? " ")
                .allowsTightening(true)
                .lineLimit(1)
                .font(.system(size: max(fontSize * 0.5, 11), weight: .light))
                .opacity(error == nil ? 0 : 1)
                .foregroundColor(Color("newGray"))
                .padding(.leading, 10)
                .animation(.default)
                .padding(.bottom, 5)
            
        }
        .frame(height: fontSize * 1.8 + 50)
    }
}

struct SendField: View {
    let placeholder: String
    @Binding var data: String
    let error: String?
    @State var isActive: Bool = false
    var fontSize: CGFloat = 20
    var fieldType: FieldType = .text
    
    
    enum FieldType {
        case number
        case password
        case text
        case url
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .number:
                return .decimalPad
            case .password:
                return .default
            case .text:
                return .default
            case .url:
                return .URL
            }
        }
        
        var contentType: UITextContentType? {
            switch self {
            case .password:
                return .password
            case .url:
                return .URL
            case .number, .text:
                return nil
            }
        }
        
        var autoDisable: Bool {
            switch self {
            case .number, .password, .url:
                return true
            case .text:
                return false
            }
        }
    }
    
    var body: some View {
        TextField("", text: $data) {
            self.isActive = $0
        }
        onCommit: {
            self.isActive = false
        }
        .keyboardType(fieldType.keyboardType)
        .textContentType(fieldType.contentType)
        .disableAutocorrection(fieldType.autoDisable)
        .autocapitalization(fieldType.autoDisable ? .none : .sentences)
        .textFieldStyle(
            SendTextFieldStyle(placeholder: placeholder,
                               error: error,
                               isActive: !self.data.isEmpty || isActive,
                               fontSize: fontSize))
    }
}

struct SendField_Previews: PreviewProvider {
    struct PreviewView: View {
        @State var data1: String = "First"
        @State var data2: String = ""
        @State var data3: String = ""
        
        var body: some View {
            VStack(alignment: .leading) {
                SendField(placeholder: "First string", data: $data1, error: nil, fontSize: 30)
                    .background(Color.green.opacity(0.5))
                SendField(placeholder: "Password string", data: $data2, error: nil, fieldType: .password)
                    .background(Color.blue.opacity(0.5))
                SendField(placeholder: "Third string", data: $data3, error: data3.isEmpty ? nil : "Stop typing very long string")
                    .background(Color.gray.opacity(0.5))
            }
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}
