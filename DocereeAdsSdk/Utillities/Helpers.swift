
import UIKit
import AdSupport
import os.log

func getAdSize(for size: String?) -> AdSize {
    switch size {
    case "320 x 50":
        return Banner()
    case "320 x 100":
        return LargeBanner()
    case "468 x 60":
        return FullBanner()
    case "300 x 250":
        return MediumRectangle()
    case "728 x 90":
        return LeaderBoard()
    case "300 x 50":
        return SmallBanner()
    default:
        return Invalid()
    }
}

func getAdTypeBySize(adSize: AdSize) -> AdType {
    let width: Int = Int(adSize.width)
    let height: Int = Int(adSize.height)
    let dimens: String = "\(width)x\(height)"
    switch dimens {
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
    case "300x50":
        return AdType.SMALLBANNER
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

func savePlatformuid(_ newPlatormuid: String) {
    NSKeyedArchiver.archiveRootObject(newPlatormuid, toFile: ArchivingUrl.path)
}

func getIdentifierForAdvertising() -> String? {
    if #available(iOS 14, *){
        if (DocereeMobileAds.trackingStatus == "authorized") {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return UIDevice.current.identifierForVendor?.uuidString
        }
    } else {
        // Fallback to previous versions
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return UIDevice.current.identifierForVendor?.uuidString
        }
    }
}

func getHost(type: EnvironmentType) -> String?{
    switch type {
    case .Dev:
        return "dev-bidder.doceree.com"
    case .Local:
        return "10.0.3.2"
    case .Qa:
        return "qa-bidder.doceree.com"
    case .Prod:
        return "bidder.doceree.com"
    }
}

func getDocTrackerHost(type: EnvironmentType) -> String?{
    switch type {
    case .Dev:
        return "dev-tracking.doceree.com"
    case .Local:
        return "10.0.3.2"
    case .Qa:
        return "qa-tracking.doceree.com"
    case .Prod:
        return "tracking.doceree.com"
    }
}
