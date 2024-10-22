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


/// Light theme colors.
public class LightColors {
    private static let values = ColorValues(
        accent: UIColor(red: 0.219607843, green: 0.17254902, blue: 0.51372549, alpha: 1),
        alert: UIColor(rgb:0xFF4B55),
        primaryContent: UIColor(red: 0.0823529412, green: 0.0941176471, blue: 0.11372549, alpha: 1),
        secondaryContent: UIColor(rgb:0x737D8C),
        tertiaryContent: UIColor(rgb:0x8D97A5),
        quarterlyContent: UIColor(rgb:0xC1C6CD),
        quinaryContent: UIColor(rgb:0xE3E8F0),
        separator: UIColor(red: 0.176470588, green: 0.176470588, blue: 0.176470588, alpha: 1),
        system: UIColor(rgb:0xF4F6FA),
        tile: UIColor(red: 0.470588235, green: 0.439215686, blue: 0.670588235, alpha: 1),
        navigation: UIColor(rgb:0xF4F6FA),
        background: UIColor(rgb:0xFFFFFF),
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





