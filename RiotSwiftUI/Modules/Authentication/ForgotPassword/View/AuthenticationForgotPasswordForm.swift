//
// Copyright 2022 New Vector Ltd
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

import SwiftUI

/// The form shown to enter an email address.
struct AuthenticationForgotPasswordForm: View {
    // MARK: - Properties
    
    // MARK: Private
    
    @Environment(\.theme) private var theme
    
    @State private var isEditingTextField = false
    
    @State private var showOTP = false
    
    // MARK: Public
    
    @ObservedObject var viewModel: AuthenticationForgotPasswordViewModel.Context
    
    // MARK: Views
    
    var body: some View {
        VStack(spacing: 0) {
            if !showOTP{
            header
                .padding(.top, OnboardingMetrics.topPaddingToNavigationBar)
                .padding(.bottom, 36)
            }
            
            mainContent
        }
    }
    
    /// The title, message and icon at the top of the screen.
    var header: some View {
        VStack(spacing: 8) {
            OnboardingIconImage(image: Asset.Images.authenticationEmailIcon)
                .padding(.bottom, 8)
            
            Text(VectorL10n.authenticationForgotPasswordInputTitle)
                .font(theme.fonts.title2B)
                .multilineTextAlignment(.center)
                .foregroundColor(theme.colors.primaryContent)
                .accessibilityIdentifier("titleLabel")
            
            Text(viewModel.viewState.formHeaderMessage)
                .font(theme.fonts.body)
                .multilineTextAlignment(.center)
                .foregroundColor(theme.colors.secondaryContent)
                .accessibilityIdentifier("messageLabel")
        }
    }
    
    /// The text field and submit button where the user enters an email address.
    var mainContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if #available(iOS 15.0, *) {
                if(showOTP){
                    otpField
                        .onSubmit(submit)
                }
                else {
                textField
                    .onSubmit(sendOTP)
                }
            } else {
                if(showOTP){
                 otpField
                }
                else {
                    textField
                }
            }
            
            Button(action: sendOTP) {
                Text(VectorL10n.next)
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(viewModel.viewState.hasInvalidAddress)
            .accessibilityIdentifier("nextButton")
        }
    }
    
    /// The text field, extracted for iOS 15 modifiers to be applied.
    var textField: some View {
        TextField(VectorL10n.authenticationForgotPasswordTextFieldPlaceholder, text: $viewModel.emailAddress) {
            isEditingTextField = $0
        }
        .textFieldStyle(BorderedInputFieldStyle(isEditing: isEditingTextField, isError: false))
        .keyboardType(.emailAddress)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .accessibilityIdentifier("addressTextField")
    }
    
    var otpField: some View {
        TextField("Enter OTP", text: $viewModel.emailAddress) {
            isEditingTextField = $0
        }
        .textFieldStyle(BorderedInputFieldStyle(isEditing: isEditingTextField, isError: false))
        .keyboardType(.default)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .accessibilityIdentifier("addressTextField")
    }
    
    /// Sends the `send` view action so long as a valid email address has been input.
    func submit() {
        guard !viewModel.viewState.hasInvalidAddress else { return }
        viewModel.send(viewAction: .send)
    }
    let loginURL = URL(string: "https://convay.com/services/organizationsettings/v1/forgot-password/app/email")

    
    func sendOTP(){
        let body: [String: Any] = ["email": viewModel.emailAddress]
        let finalData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: loginURL!)
        
        request.httpMethod = "POST"
        request.httpBody = finalData
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("datata==>>>\(data)")
            let response = response as? HTTPURLResponse
            
            let responseCode = response?.statusCode as! Int
            
            if responseCode == 200{
                showOTP = true
                viewModel.emailAddress = ""
            }
                viewModel.emailAddress = ""
        }.resume()
    }
}
