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

struct LicenseText: View {
    @ScaledMetric var fontSize: CGFloat = 15
    
    var body: some View {
        VStack(spacing: fontSize / 2) {
            Link("libsecp256k1",
                 destination: URL(string: "https://github.com/bitcoin-core/secp256k1/")!)
            
            format {
                Text(
                    """
https://github.com/bitcoin-core/secp256k1/COPYING
May 9, 2013

Copyright (c) 2013 Pieter Wuille


"""
                )
                + Text(self.text)
            }
            .padding(.bottom, 50)

            Link("Swift NIO",
                 destination: URL(string: "https://github.com/apple/swift-nio")!)

            format {
                Text(self.textNIO)
            }
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
}



extension LicenseText {
    func format(_ text: @escaping () -> Text) -> some View {
        text()
            .font(.system(size: fontSize, weight: .regular, design: .monospaced))
            .lineLimit(.max)
            .lineSpacing(self.fontSize / 2)
            .allowsTightening(true)
            .minimumScaleFactor(0.5)
            .foregroundColor(Color("newGray"))
    }
    
    func compact(_ text: String) -> String {
        text
            .components(separatedBy: CharacterSet.newlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var text: String {
        let strings: [String] = [
            compact(
                """
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
"""
            ), compact(
                """
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
"""
            ), compact(
                """
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
""")]
        
        return strings.joined(separator: "\n\n")
    }
}

extension LicenseText {
    
    var textNIO: String {
        let string: [String] = ["""
        The SwiftNIO Project
        ====================

Please visit the SwiftNIO web site for more information:

* https://github.com/apple/swift-nio

Copyright 2017, 2018 The SwiftNIO Project

""",
            compact("""
The SwiftNIO Project licenses this file to you under the Apache License,
version 2.0 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at:
"""),
            """

https://www.apache.org/licenses/LICENSE-2.0

""",
            compact("""
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.
"""),
            compact("""
Also, please refer to each LICENSE.<component>.txt file, which is located in
the 'license' directory of the distribution file, for the license terms of the
components that this product depends on.
"""),
                    
            """
-------------------------------------------------------------------------------

This product is heavily influenced by Netty.

* LICENSE (Apache License 2.0):
* https://github.com/netty/netty/blob/4.1/LICENSE.txt
* HOMEPAGE:
* https://netty.io

---

This product contains a derivation of the Tony Stone's 'process_test_files.rb'.

* LICENSE (Apache License 2.0):
* https://www.apache.org/licenses/LICENSE-2.0
* HOMEPAGE:
* https://github.com/tonystone/build-tools/commit/6c417b7569df24597a48a9aa7b505b636e8f73a1
* https://github.com/tonystone/build-tools/blob/master/source/xctest_tool.rb

---

This product contains NodeJS's http-parser.

* LICENSE (MIT):
* https://github.com/nodejs/http-parser/blob/master/LICENSE-MIT
* HOMEPAGE:
* https://github.com/nodejs/http-parser

---

This product contains "cpp_magic.h" from Thomas Nixon & Jonathan Heathcote's uSHET

* LICENSE (MIT):
* https://github.com/18sg/uSHET/blob/master/LICENSE
* HOMEPAGE:
* https://github.com/18sg/uSHET

---

This product contains "sha1.c" and "sha1.h" from FreeBSD (Copyright (C) 1995, 1996, 1997, and 1998 WIDE Project)

* LICENSE (BSD-3):
* https://opensource.org/licenses/BSD-3-Clause
* HOMEPAGE:
* https://github.com/freebsd/freebsd/tree/master/sys/crypto

---

This product contains a derivation of Fabian Fett's 'Base64.swift'.

* LICENSE (Apache License 2.0):
* https://github.com/fabianfett/swift-base64-kit/blob/master/LICENSE
* HOMEPAGE:
* https://github.com/fabianfett/swift-base64-kit]
""",]

        return string.joined(separator: "\n\n")
    }
}

struct LicenseText_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LicenseText()
        }
    }
}

