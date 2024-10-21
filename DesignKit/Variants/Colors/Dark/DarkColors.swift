// 
// Copyright 2021 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit
import SwiftUI

/// Dark theme colors.
public class DarkColors {
    private static let values = ColorValues(
        accent: UIColor(rgb:0x0DBD8B),
        alert: UIColor(rgb:0xFF4B55),
        primaryContent: UIColor(rgb:0xFFFFFF),
        secondaryContent: UIColor(rgb:0xA9B2BC),
        tertiaryContent: UIColor(rgb:0x8E99A4),
        quarterlyContent: UIColor(rgb:0x6F7882),
        quinaryContent: UIColor(rgb:0x394049),
        separator: UIColor(red: 0.176470588, green: 0.176470588, blue: 0.176470588, alpha: 1),
        system: UIColor(rgb:0x21262C),
        tile: UIColor(red: 0.470588235, green: 0.439215686, blue: 0.670588235, alpha: 1),
        navigation: UIColor(rgb:0x21262C),
        background: UIColor(rgb:0x15191E),
        ems: UIColor(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1),
        links: UIColor(rgb: 0x0086E6),
        namesAndAvatars: [
            UIColor(rgb:0x368BD6),
            UIColor(rgb:0xAC3BA8),
            UIColor(rgb:0x03B381),
            UIColor(rgb:0xE64F7A),
            UIColor(rgb:0xFF812D),
            UIColor(rgb:0x2DC2C5),
            UIColor(rgb:0x5C56F5),
            UIColor(rgb:0x74D12C)
        ],
        disabledText: UIColor(red: 0.450980392, green: 0.454901961, blue: 0.466666667, alpha: 1)
    )
    
    public static var uiKit = ColorsUIKit(values: values)
    public static var swiftUI = ColorSwiftUI(values: values)
}
