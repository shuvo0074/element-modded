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
    @State private var showRESET = false
    
    @State private var otpValue = ""
    @State private var newPassValue = ""
    @State private var errorMessage = ""
    
    // MARK: Public
    
    @ObservedObject var viewModel: AuthenticationForgotPasswordViewModel.Context
    
    // MARK: Views
    
    var body: some View {
        VStack(spacing: 0) {
            if !showOTP && !showRESET{
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
            if errorMessage.count > 0{
                Text("Error! \(errorMessage)")
                    .font(theme.fonts.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.colors.alert)
                    .accessibilityIdentifier("messageLabel")
            }

            if showRESET{
                Text("Email is \(viewModel.emailAddress)")
                    .font(theme.fonts.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.colors.secondaryContent)
                    .accessibilityIdentifier("messageLabel")
            }
            
            if #available(iOS 15.0, *) {
                if(showOTP){
                    otpField
                        .onSubmit(verifyOTP)
                }
                else if showRESET {
                newPasswordField
                    .onSubmit(changePASS)
                }else {
                textField
                    .onSubmit(sendOTP)
                }
            } else {
                if(showOTP){
                 otpField
                }
                else if showRESET {
                    newPasswordField
                }
                else {
                    textField
                }
            }
            
            Button{
                if showOTP {
                    verifyOTP()
                } else if showRESET {
                    changePASS()
                } else {
                    sendOTP()
                }
            } label: {
                Text(VectorL10n.next)
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(viewModel.viewState.hasInvalidAddress || (showOTP && otpValue.count<4)||(showRESET&&newPassValue.isEmpty))
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
        TextField("Enter OTP", text: $otpValue) {
            isEditingTextField = $0
        }
        .textFieldStyle(BorderedInputFieldStyle(isEditing: isEditingTextField, isError: false))
        .keyboardType(.numberPad)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .accessibilityIdentifier("addressTextField")
    }
    var newPasswordField: some View {
        TextField("Enter password", text: $newPassValue) {
            isEditingTextField = $0
        }
        .textFieldStyle(BorderedInputFieldStyle(isEditing: isEditingTextField, isError: false))
        .keyboardType(.numberPad)
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
    let otpURL = URL(string: "https://convay.com/services/organizationsettings/v1/forgot-password/app/match-otp")
    let resetURL = URL(string: "https://convay.com/services/organizationsettings/v1/forgot-password/app/reset")

    
    func sendOTP(){
        let body: [String: Any] = ["email": viewModel.emailAddress]
        let finalData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: loginURL!)
        
        request.httpMethod = "POST"
        request.httpBody = finalData
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let response = response as? HTTPURLResponse
            
            let responseCode = response?.statusCode as! Int
            
            if responseCode == 200{
                showOTP = true
                errorMessage = ""
            }
            else {
                viewModel.emailAddress = ""
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                let resObj = responseJSON as! [String: Any]
                let errorMSG  = resObj["message"] as! String
                errorMessage = errorMSG

            }
        }.resume()
    }
    
    func verifyOTP(){
        let body: [String: Any] = [
            "email": viewModel.emailAddress,
            "otp": otpValue
        ]
        let finalData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: otpURL!)
        
        request.httpMethod = "POST"
        request.httpBody = finalData
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            let resData = data 
            
            let response = response as? HTTPURLResponse
            
            let responseCode = response?.statusCode as! Int
            
            if responseCode == 200{
                showOTP = false
                showRESET = true
                errorMessage = ""
            }
            else {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                let resObj = responseJSON as! [String: Any]
                let errorMSG  = resObj["message"] as! String
                errorMessage = errorMSG
            }
        }.resume()
    }
    
    func changePASS(){
        let body: [String: Any] = [
            "email": viewModel.emailAddress,
            "password": newPassValue,
            "otp": otpValue
        ]
        let finalData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: resetURL!)
        
        request.httpMethod = "POST"
        request.httpBody = finalData
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            
            let response = response as? HTTPURLResponse

            
            let responseCode = response?.statusCode as! Int
            
            if responseCode == 200{
                showOTP = false
                showRESET = false
                otpValue = ""
                newPassValue = ""
                errorMessage = ""
                viewModel.send(viewAction: .cancel)
                
            }
            else {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                let resObj = responseJSON as! [String: Any]
                let errorMSG  = resObj["message"] as! String
                errorMessage = errorMSG

            }
        }.resume()
    }
}
