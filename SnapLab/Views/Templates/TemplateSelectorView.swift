import SwiftUI

public struct TemplateSelectorView: View {
    @Binding var selectedTemplate: WatermarkTemplate
    @Binding var templates: [WatermarkTemplate]
    let onCustomize: (WatermarkTemplate) -> Void
    let onDismiss: () -> Void
    
    @ObservedObject var loc = LocalizationManager.shared
    @State private var selectedCategory: WatermarkCategory? = nil
    
    public var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(loc.t("templateDrawerTitle"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    onCustomize(selectedTemplate)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text(loc.t("customize"))
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.snapAccentOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.snapAccentOrange.opacity(0.18))
                    .cornerRadius(8)
                }
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Category Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryPill(title: loc.t("all"), isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    
                    ForEach(WatermarkCategory.allCases) { cat in
                        categoryPill(title: cat.localizedName(in: loc.currentLanguage), isSelected: selectedCategory == cat) {
                            selectedCategory = cat
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // Horizontal Carousel of Templates
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(filteredTemplates) { template in
                        templateCard(template: template)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color.snapCardDark.opacity(0.96))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.snapBorderDark, lineWidth: 1)
        )
    }
    
    private var filteredTemplates: [WatermarkTemplate] {
        if let cat = selectedCategory {
            return templates.filter { $0.category == cat }
        }
        return templates
    }
    
    private func categoryPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .black : .white.opacity(0.85))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.white : Color.white.opacity(0.12))
                .cornerRadius(16)
        }
    }
    
    private func templateCard(template: WatermarkTemplate) -> some View {
        let isSelected = selectedTemplate.id == template.id
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTemplate = template
            }
        }) {
            VStack(alignment: .leading, spacing: 6) {
                // Miniature Badge Mockup
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.6))
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(template.colorTheme.primaryColor)
                                .frame(width: 6, height: 6)
                            Text(template.name)
                                .font(.system(size: 10.5, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        
                        Text(template.category.localizedName(in: loc.currentLanguage))
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundColor(template.colorTheme.primaryColor)
                        
                        Divider().background(Color.white.opacity(0.2))
                        
                        Text("• " + loc.t("timeLabel"))
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.75))
                        Text("• GPS + " + loc.t("coordinatesLabel"))
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.75))
                        if template.showAntiCounterfeitQR {
                            Text("• " + loc.t("scanQuery"))
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Color.snapNeonGreen)
                        }
                    }
                    .padding(8)
                }
                .frame(width: 150, height: 95)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? template.colorTheme.primaryColor : Color.white.opacity(0.15), lineWidth: isSelected ? 2.5 : 1)
                )
                
                // Card Title
                HStack {
                    Image(systemName: template.category.iconName)
                        .font(.system(size: 11))
                        .foregroundColor(template.colorTheme.primaryColor)
                    
                    Text(template.name)
                        .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                        .lineLimit(1)
                }
            }
            .frame(width: 150)
        }
    }
}
