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

struct WordsView: View {
    let words: [String]?
    
    var close: (Bool) -> Void
    
    init(words: [String]?, close: @escaping (Bool) -> Void) {
        guard let words = words,
              words.count == 12
                || words.count == 16
                || words.count == 20
                || words.count == 24
        else {
            self.words = nil
            self.close = close
            return
        }
        
        self.words = words
        self.close = close
    }
    
    var body: some View {
        Group {
            if let words = words {
                WordsGridView(words: words, close: close)
            } else {
                NoWordsView(close: close)
            }
        }
        .background(NewFltrViewBackground().ignoresSafeArea())
    }
}

struct WordsView_Previews: PreviewProvider {
    static var previews: some View {
        OrientationView {
            WordsView(words: ["one", "two", "three", "four", "five", "six",
                              "seven", "eight", "nine", "ten", "eleven", "twelve"]) { _ in 
                ()
            }
        }
        
        LetterBox("first:")
    }
}


