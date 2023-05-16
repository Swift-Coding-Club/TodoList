//
//  Font.swift
//  TodoList
//
//  Created by 서원지 on 2022/08/06.
//

import SwiftUI

struct Fonts {
    static let mainFont: String = "나눔손글씨 둥근인연"
    static let subFont: String = "나눔손글씨 맛있는체"
}

enum FontType: String, CaseIterable {
    case mainFont = "나눔손글씨 둥근인연"
    case subFont = "나눔손글씨 맛있는체"
}

class FontSettings: ObservableObject {
    @Published var selectedFont: FontType {
        didSet {
            UserDefaults.standard.set(selectedFont.rawValue, forKey: "SelectedFont")
        }
    }
    
    init() {
        let savedFont = UserDefaults.standard.string(forKey: "SelectedFont") ?? FontType.mainFont.rawValue
        selectedFont = FontType(rawValue: savedFont) ?? .mainFont
    }
}
