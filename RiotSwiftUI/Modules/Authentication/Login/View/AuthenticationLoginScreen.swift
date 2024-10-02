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

import SwiftUI

struct AuthenticationLoginScreen: View {
    // MARK: - Properties
    
    // MARK: Private
    
    @Environment(\.theme) private var theme: ThemeSwiftUI
    
    /// A boolean that can be toggled to give focus to the password text field.
    /// This must be manually set back to `false` when the text field finishes editing.
    @State private var isPasswordFocused = false
    
    @State private var fromDeepLink = false
    
    // MARK: Public
    
    @ObservedObject var viewModel: AuthenticationLoginViewModel.Context
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // header
                //     .padding(.top, OnboardingMetrics.topPaddingToNavigationBar)
                //     .padding(.bottom, 28)
                
                // serverInfo
                //     .padding(.leading, 12)
                //     .padding(.bottom, 16)
                
                // Rectangle()
                //     .fill(theme.colors.quinaryContent)
                //     .frame(height: 1)
                //     .padding(.bottom, 22)
                
                if viewModel.viewState.homeserver.showLoginForm && !fromDeepLink {
                    loginForm
                }

                // if viewModel.viewState.homeserver.showQRLogin {
                //     qrLoginButton
                // }
                
                // if viewModel.viewState.homeserver.showLoginForm, viewModel.viewState.showSSOButtons {
                //     Text(VectorL10n.or)
                //         .foregroundColor(theme.colors.secondaryContent)
                //         .padding(.top, 16)
                // }
                
                // if viewModel.viewState.showSSOButtons {
                //     ssoButtons
                //         .padding(.top, 16)
                // }

                // if !viewModel.viewState.homeserver.showLoginForm, !viewModel.viewState.showSSOButtons {
                //     fallbackButton
                // }
            }
            .readableFrame()
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(theme.colors.background.ignoresSafeArea())
        .alert(item: $viewModel.alertInfo) { $0.alert }
        .accentColor(theme.colors.accent)
         .onAppear(){
//             DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: submit)
//              viewModel.username = "mak"
//             self.loadData()
         }
         .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("Login-Name"))) { (output) in
             fromDeepLink = true
             let usernameval:String = output.object as! String
             viewModel.username=usernameval
             viewModel.password="Asdf@1234#123"
             MXLog.debug("Output is ----->\(usernameval)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: submit)
         }
         .navigationBarBackButtonHidden(true)
        
    }
    
    /// The header containing a Welcome Back title.
    var header: some View {
        Text(VectorL10n.authenticationLoginTitle)
            .font(theme.fonts.title2B)
            .multilineTextAlignment(.center)
            .foregroundColor(theme.colors.primaryContent)
    }
    
    /// The sever information section that includes a button to select a different server.
    var serverInfo: some View {
        AuthenticationServerInfoSection(address: viewModel.viewState.homeserver.address,
                                        flow: .login) {
            viewModel.send(viewAction: .selectServer)
        }
    }
    
    /// The form with text fields for username and password, along with a submit button.
    var loginForm: some View {
        VStack(spacing: 14) {
            RoundedBorderTextField(placeHolder: VectorL10n.authenticationLoginUsername,
                                   text: $viewModel.username,
                                   isFirstResponder: false,
                                   configuration: UIKitTextInputConfiguration(returnKeyType: .next,
                                                                              autocapitalizationType: .none,
                                                                              autocorrectionType: .no),
                                   onEditingChanged: usernameEditingChanged,
                                   onCommit: { isPasswordFocused = true })
                .accessibilityIdentifier("usernameTextField")
                .padding(.bottom, 7)
            
            RoundedBorderTextField(placeHolder: VectorL10n.authPasswordPlaceholder,
                                   text: $viewModel.password,
                                   isFirstResponder: isPasswordFocused,
                                   configuration: UIKitTextInputConfiguration(returnKeyType: .done,
                                                                              isSecureTextEntry: true),
                                   onEditingChanged: passwordEditingChanged,
                                   onCommit: submit)
                .accessibilityIdentifier("passwordTextField")
            
            Button { viewModel.send(viewAction: .forgotPassword) } label: {
                Text(VectorL10n.authenticationLoginForgotPassword)
                    .font(theme.fonts.body)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 8)
            
            Button(action: loadData) {
                Text(VectorL10n.next)
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(!viewModel.viewState.canSubmit)
            .accessibilityIdentifier("nextButton")
        }
    }

    /// A QR login button that can be used for login.
    var qrLoginButton: some View {
        Button(action: qrLogin) {
            Text(VectorL10n.authenticationLoginWithQr)
        }
        .buttonStyle(SecondaryActionButtonStyle(font: theme.fonts.bodySB))
        .padding(.vertical)
        .accessibilityIdentifier("qrLoginButton")
    }
    
    /// A list of SSO buttons that can be used for login.
    var ssoButtons: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.viewState.homeserver.ssoIdentityProviders) { provider in
                AuthenticationSSOButton(provider: provider) {
                    viewModel.send(viewAction: .continueWithSSO(provider))
                }
                .accessibilityIdentifier("ssoButton")
            }
        }
    }

    /// A fallback button that can be used for login.
    var fallbackButton: some View {
        Button(action: fallback) {
            Text(VectorL10n.login)
        }
        .buttonStyle(PrimaryActionButtonStyle())
        .accessibilityIdentifier("fallbackButton")
    }
    
    /// Parses the username for a homeserver.
    func usernameEditingChanged(isEditing: Bool) {
        guard !isEditing, !viewModel.username.isEmpty else { return }
        
        viewModel.send(viewAction: .parseUsername)
    }
    
    /// Resets the password field focus.
    func passwordEditingChanged(isEditing: Bool) {
        guard !isEditing else { return }
        isPasswordFocused = false
    }
    
    /// Sends the `next` view action so long as the form is ready to submit.
    func submit() {
        guard viewModel.viewState.canSubmit else { return }
        viewModel.send(viewAction: .next)
    }
    
    let loginURL = URL(string: "https://convay.com/services/organizationsettings/api/v1/user_authentication_for_app")
    
    func loadData(){
        let body: [String: Any] = ["userid": viewModel.username,
                                   "password": viewModel.password]
        let finalData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: loginURL!)
        
        request.httpMethod = "POST"
        request.httpBody = finalData
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: String] {
                let tokenValue:String = responseJSON["token"] as! String

                print(tokenValue)
            }
        }.resume()
    }

    /// Sends the `fallback` view action.
    func fallback() {
        viewModel.send(viewAction: .fallback)
    }

    /// Sends the `qrLogin` view action.
    func qrLogin() {
        viewModel.send(viewAction: .qrLogin)
    }
}

// MARK: - Previews

@available(iOS 15.0, *)
struct AuthenticationLogin_Previews: PreviewProvider {
    static let stateRenderer = MockAuthenticationLoginScreenState.stateRenderer
    static var previews: some View {
        stateRenderer.screenGroup(addNavigation: true)
            .navigationViewStyle(.stack)
    }
}
