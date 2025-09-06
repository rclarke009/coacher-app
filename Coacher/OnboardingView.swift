//
//  OnboardingView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import UIKit

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) private var currentColorScheme
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var morningTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @State private var eveningTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    
    private var buttonText: String {
        return currentPage == pages.count - 1 ? "Get Started" : "Next"
    }
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to Lighter Tomorrow! 👋",
            subtitle: "Let's get you set up in just a minute",
            content: "I'll help you build healthy habits with simple daily routines.",
            icon: "heart.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "What should I call you?",
            subtitle: "This helps personalize your experience",
            content: "",
            icon: "person.fill",
            color: .green,
            showNameInput: true
        ),
        OnboardingPage(
            title: "When would you like reminders?",
            subtitle: "We'll send gentle nudges to help you stay on track",
            content: "",
            icon: "bell.fill",
            color: .orange,
            showTimeInputs: true
        ),
        OnboardingPage(
            title: "Here's how it works",
            subtitle: "Two simple daily routines",
            content: "🌅 Morning Focus: Set your intentions and choose your healthy swap\n\n🌙 Night Prep: Prepare for tomorrow's success",
            icon: "sun.max.fill",
            color: .purple
        ),
        OnboardingPage(
            title: "Your AI Coach",
            subtitle: "Private by default. Your coach works even without internet.",
            content: "🤖 Local Coach: Fast, private, offline\n\n☁️ Enhanced Cloud Coach: Richer conversations (optional)\n\nYou can switch between modes anytime in Settings.",
            icon: "brain.head.profile",
            color: .blue
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(
                        page: pages[index],
                        userName: $userName,
                        morningTime: $morningTime,
                        eveningTime: $eveningTime
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .foregroundColor(.secondary)
                } else {
                    Spacer()
                }
                
                Spacer()
                
                if currentPage > 0 {
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(.secondary)
                } else {
                    Spacer()
                }
                
                Spacer()
                
                Button(buttonText) {
                    if currentPage == pages.count - 1 {
                        completeOnboarding()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(pages[currentPage].color)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    private func completeOnboarding() {
        // Save user preferences
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(morningTime, forKey: "morningFocusTime")
        UserDefaults.standard.set(eveningTime, forKey: "nightPrepTime")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Update reminder times
        Task {
            await ReminderManager.shared.updateReminders()
        }
        
        isPresented = false
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let content: String
    let icon: String
    let color: Color
    let showNameInput: Bool
    let showTimeInputs: Bool
    
    init(title: String, subtitle: String, content: String, icon: String, color: Color, showNameInput: Bool = false, showTimeInputs: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.icon = icon
        self.color = color
        self.showNameInput = showNameInput
        self.showTimeInputs = showTimeInputs
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @Binding var userName: String
    @Binding var morningTime: Date
    @Binding var eveningTime: Date
    @Environment(\.colorScheme) private var currentColorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
            
            // Title and subtitle
            VStack(spacing: 8) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title3)
                    .foregroundColor(currentColorScheme == .dark ? Color.white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Content
            if !page.content.isEmpty {
                Text(page.content)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(currentColorScheme == .dark ? Color.white.opacity(0.8) : .secondary)
                    .padding(.horizontal, 20)
            }
            
            // Name input
            if page.showNameInput {
                VStack(spacing: 16) {
                    TextField("Your name", text: $userName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(currentColorScheme == .dark ? .white : .primary)
                        .background(currentColorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
                        .padding(.horizontal, 40)
                }
            }
            
            // Time inputs
            if page.showTimeInputs {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Morning Focus")
                            .font(.headline)
                            .foregroundColor(currentColorScheme == .dark ? .white : .primary)
                        DatePicker("Time", selection: $morningTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    VStack(spacing: 8) {
                        Text("Night Prep")
                            .font(.headline)
                            .foregroundColor(currentColorScheme == .dark ? .white : .primary)
                        DatePicker("Time", selection: $eveningTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                .padding(.horizontal, 40)
            }
            
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
