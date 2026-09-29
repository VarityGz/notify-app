import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var message: String = ""
    @State private var count: Int = 1
    @State private var status: String = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                Text("Notify")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 8) {
                    Text("MESSAGE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    TextField("Type what the notification says", text: $message)
                        .padding(14)
                        .background(Color(white: 0.95))
                        .cornerRadius(12)
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("HOW MANY (1–60)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    HStack {
                        Text("\(count)")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(minWidth: 50, alignment: .leading)
                        Spacer()
                        Stepper("", value: $count, in: 1...60)
                            .labelsHidden()
                    }
                    Slider(value: Binding(
                        get: { Double(count) },
                        set: { count = Int($0.rounded()) }
                    ), in: 1...60, step: 1)
                    .tint(.black)
                }

                Button(action: sendNotifications) {
                    Text("Send")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(14)
                }

                if !status.isEmpty {
                    Text(status)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding(24)
        }
        .preferredColorScheme(.light)
        .onTapGesture { hideKeyboard() }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    private func sendNotifications() {
        hideKeyboard()
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                guard granted else {
                    status = "Notifications are turned off. Enable them in Settings > Notify."
                    return
                }

                let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
                let body = trimmed.isEmpty ? "Hello!" : trimmed
                let total = count

                // Start fresh so old scheduled ones don't pile up.
                center.removeAllPendingNotificationRequests()

                for i in 1...total {
                    let content = UNMutableNotificationContent()
                    content.title = "Notify"
                    content.body = body
                    content.sound = .default

                    // First one after 1 second, then one every 2 seconds.
                    let delay = 1.0 + Double(i - 1) * 2.0
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                        content: content,
                                                        trigger: trigger)
                    center.add(request)
                }

                status = "Sending \(total) notification\(total == 1 ? "" : "s")…"
            }
        }
    }
}
