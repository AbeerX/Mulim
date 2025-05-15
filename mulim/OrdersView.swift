import SwiftUI
import SwiftData
import Speech
import AVFoundation

// ✅ كلاس التعرف على الصوت
class SpeechRecognizer: ObservableObject {
    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var task: SFSpeechRecognitionTask?

    @Published var recognizedText = ""

    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition not authorized.")
            }
        }
    }

    func startRecording() {
        recognizedText = ""
        stopRecording()

        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        request = SFSpeechAudioBufferRecognitionRequest()

        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()

            task = recognizer?.recognitionTask(with: request) { result, _ in
                if let result = result {
                    DispatchQueue.main.async {
                        self.recognizedText = result.bestTranscription.formattedString
                    }
                }
            }
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        task?.cancel()
        task = nil
        audioEngine.stop()
        request.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

// ✅ الصفحة الرئيسية
struct OrdersView: View {
    @Binding var selectedTab: String // ✅ مضاف هنا

    @Query var orders: [Order]
    @Query var products: [Product]
    @State private var searchText: String = ""
    @State private var isRecording = false

    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // العنوان وزر الإضافة
                HStack {
                    NavigationLink(destination: NewOrder()) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("C1"))
                    }

                    Spacer()
                    Text(NSLocalizedString("Orders", comment: ""))
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    Spacer()
                    Spacer()
                        .frame(width: 44)
                }
                .padding(.horizontal)
                .padding(.top,-20)
                // حقل البحث + زر المايك أو زر الإيقاف
                TextField(NSLocalizedString("Search", comment: ""), text: $searchText)
                    .padding(10)
                    .frame(height: 36)
                    .frame(minWidth: 12)
                
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Spacer()
                            if isRecording {
                                Image(systemName: "stop.circle.fill")
                                    .foregroundColor(.red)
                                    .padding(.trailing, 19)
                                    .onTapGesture {
                                        speechRecognizer.stopRecording()
                                        isRecording = false
                                    }
                            } else {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 19)
                                    .onTapGesture {
                                        speechRecognizer.startRecording()
                                        isRecording = true
                                    }
                            }
                        }
                    )
                    .padding(.horizontal)

                // ✅ التبويبات مع الحفاظ على selectedTab بقيم ثابتة
                HStack {
                    Button(action: { selectedTab = "Current" }) {
                        Text(NSLocalizedString("CurrentOrders", comment: ""))
                            .font(.system(size: 15))
                            .foregroundColor(selectedTab == "Current" ? .black : Color(hex: "#A8A8A8"))
                    }

                    Spacer()

                    Button(action: { selectedTab = "Previous" }) {
                        Text(NSLocalizedString("PreviousOrders", comment: ""))
                            .font(.system(size: 15))
                            .foregroundColor(selectedTab == "Previous" ? .black : Color(hex: "#A8A8A8"))
                    }
                }
                .padding(.horizontal, 30)

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))

                .onChange(of: speechRecognizer.recognizedText) { newValue in
                    searchText = newValue
                }
                .onAppear {
                    speechRecognizer.requestPermission()
                }

                let filteredOrders = orders.filter { order in
                    let status = order.selectedStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    
                    let matchesTab: Bool
                    if selectedTab == "Current" {
                        matchesTab = status == "open"
                    } else {
                        matchesTab = status == "closed" || status == "canceled"
                    }

                    let matchesSearch = searchText.isEmpty ||
                        order.clientName.localizedCaseInsensitiveContains(searchText) ||
                        order.customerNumber.localizedCaseInsensitiveContains(searchText)

                    return matchesTab && matchesSearch
                }

                // عرض الطلبات
                if filteredOrders.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 186, height: 231.01)

                        Text(NSLocalizedString("NoOrdersYet", comment: ""))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredOrders) { order in
                                NavigationLink(destination: OrderDetailsView(order: order, products: products, selectedTab: $selectedTab)) {
                                    orderSummaryView(order)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.top, 24)
            .navigationBarBackButtonHidden(true)
        }
    }

    // ✅ عرض الطلب الواحد كمربع مرتب
    @ViewBuilder
    func orderSummaryView(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text")
                    .font(.system(size: 14))
                Text(order.productType)
                    .font(.system(size: 12, weight: .bold))
                Spacer()
                statusBadge(for: order.selectedStatus)
            }

            HStack {
                Image(systemName: "person")
                    .font(.system(size: 14))
                Text(order.clientName)
                    .font(.system(size: 12))
            }

            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 14))
                Text("‏\(NSLocalizedString("Delivery_time:", comment: "")) \(order.deliveryDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 12, weight: .bold))
            }

            HStack {
                Image(systemName: "creditcard")
                    .font(.system(size: 14))
                Text("\(order.totalPrice, specifier: "%.2f") SR")
                    .font(.system(size: 12))
            }
        }
        .foregroundColor(Color(hex: "#393939"))
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#00BCD4"), lineWidth: 1)
        )
    }

    func statusBadge(for status: String) -> some View {
        let color: Color = switch status {
        case "Canceled": Color(hex: "#FFC835")
        case "Closed": Color(hex: "#FF5722")
        default: Color(hex: "#00BCD4")
        }

        return Text(NSLocalizedString("status_\(status.lowercased())", comment: ""))
            .font(.system(size: 12))
            .foregroundColor(.black)
            .frame(minWidth: 55)
            .padding(.horizontal, 13)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color, lineWidth: 1.5)
                    )
            )
    }
}

#Preview {
    OrdersView(selectedTab: .constant("Current"))
        .modelContainer(for: [Order.self, Product.self])
}
