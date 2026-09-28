import SwiftUI

public struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("snaplab_format") private var imageFormat = "JPEG (Chất lượng cao)"
    @AppStorage("snaplab_coord_format") private var coordFormat = "DMS (Độ Phút Giây)"
    @AppStorage("snaplab_temp_unit") private var tempUnit = "Celsius (°C)"
    @AppStorage("snaplab_auto_save_album") private var autoSaveAlbum = true
    @AppStorage("snaplab_sound_shutter") private var soundShutter = true
    
    public var body: some View {
        NavigationView {
            Form {
                // Section 1: Capture Quality
                Section(header: Text("Chất lượng ảnh & Định dạng").font(.system(size: 13, weight: .bold))) {
                    Picker("Định dạng xuất ảnh", selection: $imageFormat) {
                        Text("JPEG (95% Giữ nguyên chi tiết)").tag("JPEG (Chất lượng cao)")
                        Text("HEIC (Tối ưu dung lượng Apple)").tag("HEIC")
                    }
                    
                    Toggle("Tự động lưu vào Album 'SnapLab'", isOn: $autoSaveAlbum)
                    Toggle("Âm thanh chụp ảnh", isOn: $soundShutter)
                }
                
                // Section 2: Watermark Units
                Section(header: Text("Định dạng dữ liệu Watermark").font(.system(size: 13, weight: .bold))) {
                    Picker("Hiển thị Tọa độ GPS", selection: $coordFormat) {
                        Text("DMS (Ví dụ: 10°46'37\"N 106°41'55\"E)").tag("DMS (Độ Phút Giây)")
                        Text("Thập phân (Ví dụ: 10.77694, 106.70093)").tag("Decimal")
                    }
                    
                    Picker("Đơn vị Nhiệt độ", selection: $tempUnit) {
                        Text("Độ C (°C)").tag("Celsius (°C)")
                        Text("Độ F (°F)").tag("Fahrenheit (°F)")
                    }
                }
                
                // Section 3: Anti-Counterfeiting Security
                Section(header: Text("Bảo mật chống làm giả (Anti-Counterfeiting)").font(.system(size: 13, weight: .bold))) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(Color.snapNeonGreen)
                            Text("Chữ Ký Số SHA-256 & QR Code")
                                .font(.system(size: 14, weight: .bold))
                        }
                        Text("Mỗi bức ảnh được chụp từ SnapLab được gắn mã băm cryptographic SHA-256 từ cảm biến camera gốc cùng tọa độ thời gian thực. Bất kỳ sự can thiệp nào bằng Photoshop hoặc phần mềm chỉnh sửa đều bị phát hiện ngay khi quét đối soát.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // Section 4: About & Compatibility
                Section(header: Text("Thông tin ứng dụng").font(.system(size: 13, weight: .bold))) {
                    HStack {
                        Text("Tên ứng dụng")
                        Spacer()
                        Text("SnapLab ‑ Camera & Filter")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text("2.4.0 (Build 6751682117)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Nền tảng hỗ trợ")
                        Spacer()
                        Text("iOS 16+ & macOS Catalyst")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Bản quyền")
                        Spacer()
                        Text("SnapLab Technologies")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Cài Đặt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.snapAccentOrange)
                }
            }
        }
    }
}
