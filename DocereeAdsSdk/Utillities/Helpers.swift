
import UIKit

func getAdTypeBySize(adSize: AdSize) -> AdType {
    let width: Int = Int(adSize.width)
    let height: Int = Int(adSize.height)
    let dimens: String = "\(width)x\(height)"
    switch dimens{
    case "320x50":
        return AdType.BANNER
    case "300x250":
        return AdType.MEDIUMRECTANGLE
    case "320x100":
        return AdType.LARGEBANNER
    case "468x60":
        return AdType.FULLSIZE
    case "728x90":
        return AdType.LEADERBOARD
    default:
        return AdType.INVALID
    }
}

func compareIfSame(presentValue: String, expectedValue: String) -> Bool {
    return presentValue.caseInsensitiveCompare(expectedValue) == ComparisonResult.orderedSame
}

func clearPlatformUid() {
    do {
        try FileManager.default.removeItem(at: ArchivingUrl)
    } catch{}
}
