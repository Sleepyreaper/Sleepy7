import Foundation

enum AssetOptimizationGuide {
    static let recommendedVectorAssets: [String] = [
        "Back",
        "Freeze",
        "SecondChance"
    ]

    static let notes: [String] = [
        "For simple iconographic assets, replace PNG sets with single-scale PDF vector assets preserving vector data.",
        "Prefer SF Symbols where brand distinctiveness is not required.",
        "Keep bitmap assets only for richly textured card faces that genuinely benefit from raster detail.",
        "Avoid shipping duplicated 1x/2x/3x raster variants for simple geometric art."
    ]
}