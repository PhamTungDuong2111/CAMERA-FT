import SwiftUI

public struct TemplateEditorSheet: View {
    @Binding var template: WatermarkTemplate
    let onSave: (WatermarkTemplate) -> Void
    let onDismiss: () -> Void
    
    @State private var workingCopy: WatermarkTemplate
    @StateObject private var locationManager = LocationWeatherManager.shared
    
    public init(template: Binding<WatermarkTemplate>, onSave: @escaping (WatermarkTemplate) -> Void, onDismiss: @escaping () -> Void) {
        self._template = template
        self.onSave = onSave
        self.onDismiss = onDismiss
        self._workingCopy = State(initialValue: template.wrappedValue)
    }
    
    public var body: some View {
        NavigationView {
            Form {
                // Section 1: Live Interactive Preview
                Section(header: Text("Xem trước Watermark").font(.system(size: 13, weight: .bold))) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.14, green: 0.18, blue: 0.24))
                            .frame(height: 240)
                        
                        WatermarkOverlayView(
                            template: workingCopy,
                            locationManager: locationManager,
                            verificationRecord: VerificationRecord(id: "SL-PREVIEW-9921"),
                            onEditTapped: {}
                        )
                        .frame(height: 240)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 8)
                }
                
                // Section 2: Watermark Text Fields
                Section(header: Text("Nội dung thông tin hiện trường").font(.system(size: 13, weight: .bold))) {
                    TextField("Tiêu đề dấu (vd: TIÊU CHUẨN XÂY DỰNG)", text: $workingCopy.titleText)
                    TextField("Tên dự án / Công trình", text: $workingCopy.projectName)
                    TextField("Hạng mục công việc", text: $workingCopy.workItem)
                    TextField("Đơn vị thi công / Nhà thầu", text: $workingCopy.contractorName)
                    TextField("Người thực hiện / Giám sát", text: $workingCopy.inspectorName)
                    TextField("Ghi chú bổ sung", text: $workingCopy.customNotes)
                }
                
                // Section 3: Information Toggles
                Section(header: Text("Trường dữ liệu tự động").font(.system(size: 13, weight: .bold))) {
                    Toggle("Hiển thị ngày giờ thực", isOn: $workingCopy.showTime)
                    if workingCopy.showTime {
                        Toggle("Hiển thị đến từng giây", isOn: $workingCopy.showSeconds)
                    }
                    Toggle("Hiển thị địa chỉ thực tế", isOn: $workingCopy.showLocation)
                    Toggle("Hiển thị tọa độ GPS chính xác", isOn: $workingCopy.showCoordinates)
                    Toggle("Hiển thị cao độ địa hình (Altitude)", isOn: $workingCopy.showAltitude)
                    Toggle("Hiển thị thời tiết & nhiệt độ", isOn: $workingCopy.showWeather)
                    Toggle("Hiển thị la bàn & hướng nhìn", isOn: $workingCopy.showCompass)
                    Toggle("Hiển thị thông tin thiết bị", isOn: $workingCopy.showDeviceInfo)
                    Toggle("Mã QR chống giả mạo (Anti-Counterfeit)", isOn: $workingCopy.showAntiCounterfeitQR)
                }
                
                // Section 4: Style & Visuals
                Section(header: Text("Giao diện & Vị trí").font(.system(size: 13, weight: .bold))) {
                    Picker("Vị trí đặt dấu", selection: $workingCopy.position) {
                        ForEach(WatermarkPosition.allCases) { pos in
                            Text(pos.rawValue).tag(pos)
                        }
                    }
                    
                    Picker("Kiểu khung nền", selection: $workingCopy.badgeStyle) {
                        ForEach(WatermarkBadgeStyle.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    
                    Picker("Tông màu chủ đạo", selection: $workingCopy.colorTheme) {
                        ForEach(WatermarkColorTheme.allCases) { color in
                            HStack {
                                Circle().fill(color.primaryColor).frame(width: 12, height: 12)
                                Text(color.rawValue)
                            }
                            .tag(color)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Độ mờ (Opacity)")
                            Spacer()
                            Text("\(Int(workingCopy.opacity * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $workingCopy.opacity, in: 0.3...1.0, step: 0.05)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Kích thước (Scale)")
                            Spacer()
                            Text(String(format: "%.1fx", workingCopy.scale))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $workingCopy.scale, in: 0.7...1.3, step: 0.05)
                    }
                }
            }
            .navigationTitle("Tùy Chỉnh Mẫu Dấu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy", action: onDismiss)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Áp dụng") {
                        onSave(workingCopy)
                        onDismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.snapAccentOrange)
                }
            }
        }
    }
}
